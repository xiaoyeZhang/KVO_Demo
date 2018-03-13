//
//  NSObject+KVO.h
//  KVOdemo
//
//  Created by 张晓烨 on 2018/3/12.
//  Copyright © 2018年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^ZXYObservingBlock)(id observingObject,NSString *observedKey,id oldValue,id newValue);

@interface NSObject (KVO)

- (void)ZXY_addObserber:(NSObject *)observer
                forKey:(NSString *)key
             withBlock:(ZXYObservingBlock)block;


- (void)ZXY_removeObserver:(NSObject *)observer
                   forKey:(NSString *)key;


@end
