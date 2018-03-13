//
//  NSObject+KVO.m
//  KVOdemo
//
//  Created by 张晓烨 on 2018/3/12.
//  Copyright © 2018年 zxy. All rights reserved.
//

#import "NSObject+KVO.h"
#import <objc/runtime.h>
//#import <stdlib.h>
#import <objc/message.h>

NSString *const kZXYKVOClassPrefix = @"ZXYKVOClassPrefix_";
NSString *const kZXYKVOAssociatedObservers = @"kZXYKVOAssociatedObservers";


#pragma mark ---- ZXYVObservationInfo  观察者信息
@interface ZXYVObservationInfo:NSObject

@property (nonatomic,weak)NSObject *observer;
@property (nonatomic,copy)NSString *key;
@property (nonatomic,copy)ZXYObservingBlock block;

@end

@implementation ZXYVObservationInfo

- (instancetype)initWithObserver:(NSObject *)observer
                             key:(NSString *)key
                           block:(ZXYObservingBlock )block
{
    if (self = [super init]) {
        _observer = observer;
        _key = key;
        _block = block;
    }
    return self;
}


@end

#pragma mark ---- Debug Help Methods
// 获取某个类中 所有的方法名称并放在一个数组中
static NSArray *ClassMethodNames(Class c)
{
    NSMutableArray *array = [NSMutableArray array];
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(c, &methodCount);
    unsigned int i;
    for (i = 0; i<methodCount; i++) {
        SEL sel = method_getName(methodList[i]);
        NSString *methodName = NSStringFromSelector(sel);
        [array addObject:methodName];
    }
    free(methodList);

    return array;
}

// 打印某个类的描述 根据名称 和 Obj
static void PrintDescription(NSString *name,id obj)
{
    NSString *str = [NSString stringWithFormat:
                     @"%@: %@\n\tNSObject class %s\n\tRuntime class %s\n\timplements methods <%@>\n\n",
                     name,
                     obj,
                     class_getName([obj class]),
                     class_getName(object_getClass(obj)),
                     [ClassMethodNames(object_getClass(obj)) componentsJoinedByString:@", "]];
    printf("%s\n", [str UTF8String]);
}

#pragma mark ---- Helpers

/*
 根据 setter 获取 getter 的名称

 @param setter setter description
 @return return value description
 */

static NSString *getterForSetter(NSString *setter)
{
    // 判断是否是正式的方法
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }

    //
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *key = [setter substringWithRange:range];

    // lower case the first letter
    NSString *firstLetter = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                       withString:firstLetter];

    return key;
}

/**
 根据  getter  方法 获取 setter方法

 @param getter getter description
 @return return value description
 */
static NSString *setterForGetter(NSString *getter)
{
    if (getter.length <= 0) {
        return nil;
    }

    // upper case the first letter
    NSString *firstLetter = [[getter substringToIndex:1] uppercaseString];
    NSString *remainingLetters = [getter substringFromIndex:1];

    // add 'set' at the begining and ':' at the end
    NSString *setter = [NSString stringWithFormat:@"set%@%@:", firstLetter, remainingLetters];

    return setter;
}

#pragma mark ---- Overridden Methods  重写Setter 方法替换原来的运行时方法
#pragma mark ---- 很明显这个 setter 方法 和getter 方法 只是 写了id 类型 的没写 基础类型的 比如int float 等  笔者要加上这些类型  Thread 1: EXC_BAD_ACCESS (code=1, address=0x2)
static void kvo_setter(id self,SEL _cmd,id newValue)
{
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = getterForSetter(setterName);

    if (!getterName) {  // 没有获取到name 甩出异常
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have setter %@", self, setterName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
        return;
    }

    //
    id  oldValue = [self valueForKey:getterName];
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };

    // cast our pointer so the compiler won't complain
    void (*objc_msgSendSuperCasted) (void *,SEL,id) = (void *)objc_msgSendSuper;
    // call super's setter, which is original class's setter method
    objc_msgSendSuperCasted(&superClazz,_cmd,newValue);
    // look up observers and call the blocks
    // Cast of Objective-C pointer type 'NSString *' to C pointer type 'const void *' requires a bridged cast  这里使用了 __bridge 类型
    // look up observers and call the blocks
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kZXYKVOAssociatedObservers));
    for (ZXYVObservationInfo *each in observers){
        //
        if ([each.key isEqualToString:getterName]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                each.block(self, getterName, oldValue, newValue);
            });
        }

    }
}

static Class kvo_class(id self,SEL _cmd)
{
    // 这是一个apple 的一个障眼法 让我们以为 还是原来的类的Class 其实真正的类是class
    return class_getSuperclass(object_getClass(self));
}


#pragma mark ---- KVO Category
@implementation NSObject (KVO)

/**
 实现思路：
 检查对象的类有没有相应的 setter 方法。如果没有抛出异常；
 检查对象 isa 指向的类是不是一个 KVO 类。如果不是，新建一个继承原来类的子类，并把 isa 指向这个新建的子类；
 检查对象的 KVO 类重写过没有这个 setter 方法。如果没有，添加重写的 setter 方法；
 添加这个观察者

 @param observer observer description
 @param key key description
 @param block block description
 */
- (void)ZXY_addObserber:(NSObject *)observer forKey:(NSString *)key withBlock:(ZXYObservingBlock)block
{

    SEL setterSelector = NSSelectorFromString(setterForGetter(key));
    Method setterMehtod = class_getInstanceMethod([self class], setterSelector);
    if (!setterMehtod) {
        // 抛出异常
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have a setter for key %@", self, key];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        return;
    }

    //
    Class clazz = object_getClass(self);
    NSString *clazzName = NSStringFromClass(clazz);

    if (![clazzName hasPrefix:kZXYKVOClassPrefix]) {
        clazz = [self makeKvoClassWithOriginalClassName:clazzName];
        object_setClass(self, clazz);  // 这个类的 isa 指针替换掉
    }

    // add our kvo setter if this class (not superclasses) doesn't implement the setter?
    // 添加 我们设置的 KVO setter 如果这个类没有 实现自定义的 setter
    if (![self hasSelector:setterSelector]) {
        const char *types = method_getTypeEncoding(setterMehtod);
        class_addMethod(clazz, setterSelector, (IMP)kvo_setter, types);
    }

    //
    ZXYVObservationInfo *info = [[ZXYVObservationInfo alloc] initWithObserver:observer key:key block:block];
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kZXYKVOAssociatedObservers));
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void *)(kZXYKVOAssociatedObservers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:info];  // 添加了observer
}

// 移除掉 观察者
- (void)ZXY_removeObserver:(NSObject *)observer forKey:(NSString *)key
{
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kZXYKVOAssociatedObservers));
    ZXYVObservationInfo *infoToRemove;
    for (ZXYVObservationInfo *info in observers){
        if (info.observer == observer && [info.key isEqualToString:key]) {
            infoToRemove = info;
            break;
        }
    }
    [observers removeObject:infoToRemove];
}


#pragma mark ---- 根据原始的类名动态 创建 KVO的 class
// runtime 动态创建的类 这个类不会出现在IDE中 只是运行的时候创建
- (Class )makeKvoClassWithOriginalClassName:(NSString *)originalClazzName
{
    // 这是动态创建的类的类名
    NSString *kvoClazzName = [kZXYKVOClassPrefix stringByAppendingString:originalClazzName];
    Class clazz = NSClassFromString(kvoClazzName);
    if (clazz) {  // 如果有返回
        NSLog(@"之前已经创建过这个 类名的类 ");
        return clazz;
    }

    // class doesn't exist yet, make it  动态创建一个KVO类
    Class originalClazz = object_getClass(self);
    Class kvoClazz = objc_allocateClassPair(originalClazz, kvoClazzName.UTF8String, 0);

    // grab class method's signature so we can borrow it
    Method clazzMethod = class_getInstanceMethod(originalClazz, @selector(class));
    const char *types = method_getTypeEncoding(clazzMethod);
    class_addMethod(kvoClazz, @selector(class), (IMP)kvo_class, types);
    objc_registerClassPair(kvoClazz);

    return  kvoClazz;

}


/**
 是否能执行某个SEL  有返回 YES  没有 返回NO

 @param selector selector description
 @return return value description
 */
- (BOOL)hasSelector:(SEL)selector
{
    // 如果在 class  的method list 中有SEL 那么返回 YES 否则返回NO
    Class clazz = object_getClass(self);
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(clazz, &methodCount);
    for (unsigned int i = 0; i<methodCount; i++) {
        SEL thisSelector = method_getName(methodList[i]);
        if (thisSelector == selector){
            free(methodList);
            return YES;
        }
    }
    //
    free(methodList);
    return NO;
}

@end

