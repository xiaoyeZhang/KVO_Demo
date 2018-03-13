//
//  KVO_customizeViewController.m
//  KVOdemo
//
//  Created by 张晓烨 on 2018/3/12.
//  Copyright © 2018年 zxy. All rights reserved.
//

#import "KVO_customizeViewController.h"
#import "NSObject+KVO.h"
#import "KVO_Model.h"

@interface KVO_customizeViewController ()

@property (nonatomic, strong) KVO_Model *model;

@end

@implementation KVO_customizeViewController

- (void)dealloc{
     [self threeRemoveKVO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self threeRegisteKVO];
//    [self threeRemoveKVO];
}

//注册
- (void)threeRegisteKVO
{
    //
    if (!self.model) {
        self.model = [[KVO_Model alloc]init];
        
    }
    
    NSString *key = NSStringFromSelector(@selector(age));
    [self.model ZXY_addObserber:self forKey:key withBlock:^(id observingObject, NSString *observedKey, id oldValue, id newValue) {
        NSLog(@"%@ . %@ is now:%@",observingObject,observedKey,newValue);
//        self.label.text = newValue;
        //异步执行，否则不能同步修改
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = [NSString stringWithFormat:@"当前的值为：%@",newValue];
        });
        
    }];

    int ageValue = arc4random()%10;
    self.model.age = [NSString stringWithFormat:@"%d",ageValue];
}

//移除
- (void)threeRemoveKVO
{
    if (!self.model) {
        self.model = [[KVO_Model alloc]init];
        
    }
    
    NSString *key = NSStringFromSelector(@selector(age));
    [self.model ZXY_removeObserver:self forKey:key];
}

- (IBAction)changeNum:(UIButton *)sender {

    //按一次，使num的值+1
    self.model.age = [NSString stringWithFormat:@"%d",[self.model.age intValue] + 1];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
