//
//  KVO_Pass_Value_secondViewController.m
//  KVOdemo
//
//  Created by 张晓烨 on 2018/3/13.
//  Copyright © 2018年 zxy. All rights reserved.
//

#import "KVO_Pass_Value_secondViewController.h"

@interface KVO_Pass_Value_secondViewController ()

@property (strong,nonatomic) NSString *name;
@end

@implementation KVO_Pass_Value_secondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

- (IBAction)backButton:(UIButton *)sender {
    
    self.name = self.textfield.text;
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
