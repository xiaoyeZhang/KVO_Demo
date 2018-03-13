//
//  KVO_systemViewController.m
//  KVOdemo
//
//  Created by 张晓烨 on 2018/3/12.
//  Copyright © 2018年 zxy. All rights reserved.
//

#import "KVO_systemViewController.h"
#import "KVO_Model.h"

@interface KVO_systemViewController ()
{
    KVO_Model *model;
}

@property (nonatomic, copy) NSString *titleText;

@end

@implementation KVO_systemViewController

- (void)dealloc{
    
    [model removeObserver:self forKeyPath:@"num" context:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //第一个参数 observer：观察者 （这里观察self.myKVO对象的属性变化）
    //第二个参数 keyPath： 被观察的属性名称(这里观察 model 中 num 属性值的改变)
    //第三个参数 options： 观察属性的新值、旧值等的一些配置（枚举值，可以根据需要设置，例如这里可以使用两项）
    /*
        NSKeyValueObservingOptionOld 以字典的形式提供 “初始对象数据”;
        NSKeyValueObservingOptionNew 以字典的形式提供 “更新后新的数据”;
        NSKeyValueObservingOptionInitial：观察最初的值（在注册观察服务时会调用一次触发方法）
        NSKeyValueObservingOptionPrior：分别在值修改前后触发方法（即一次修改有两次触发）
     */
    //第四个参数 context： 上下文，可以为 KVO 的回调方法传值（例如设定为一个放置数据的字典）
    
    
    model = [[KVO_Model alloc]init];
    
    [model addObserver:self forKeyPath:@"num" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionPrior context:nil];
    
}

//keyPath:属性名称
//object:被观察的对象
//change:变化前后的值都存储在 change 字典中
//context:注册观察者时，context 传过来的值
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
 
    if([keyPath isEqualToString:@"num"] && object == model) {
        // 响应变化处理：UI更新（label文本改变）
        self.label.text = [NSString stringWithFormat:@"当前的num值为：%@",
                           [change valueForKey:@"new"]];
        
        //change的使用：上文注册时，枚举为2个，因此可以提取change字典中的新、旧值的这两个方法
//        NSLog(@"\\noldnum:%@ newnum:%@",[change valueForKey:@"old"],
//              [change valueForKey:@"new"]);
        for (NSString *key in  change) {
            NSLog(@"\\key :%@ key_value:%@",key,
                  [change valueForKey:key]);
        }
        
    }
    
}
- (IBAction)changeNum:(UIButton *)sender {
    
    //按一次，使num的值+1
    model.num = model.num + 1;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
