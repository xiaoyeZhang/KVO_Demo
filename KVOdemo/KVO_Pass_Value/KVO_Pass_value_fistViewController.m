//
//  KVO_Pass_value_fistViewController.m
//  KVOdemo
//
//  Created by 张晓烨 on 2018/3/13.
//  Copyright © 2018年 zxy. All rights reserved.
//

#import "KVO_Pass_value_fistViewController.h"
#import "KVO_Pass_Value_secondViewController.h"

@interface KVO_Pass_value_fistViewController ()

@end

@implementation KVO_Pass_value_fistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (IBAction)button:(UIButton *)sender {
    
    KVO_Pass_Value_secondViewController *vc = [[KVO_Pass_Value_secondViewController alloc]init];
    
    [vc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    KVO_Pass_Value_secondViewController *vc = (KVO_Pass_Value_secondViewController *)object;
    if ([keyPath isEqualToString:@"name"]) {
        
        self.label.text = [NSString stringWithFormat:@"现在的值为：%@",[change valueForKey:@"new"]];
    }
    [vc removeObserver:self forKeyPath:@"name" context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
