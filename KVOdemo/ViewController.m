//
//  ViewController.m
//  KVOdemo
//
//  Created by 张晓烨 on 2018/3/12.
//  Copyright © 2018年 zxy. All rights reserved.
//

#import "ViewController.h"
#import "KVO_systemViewController.h"
#import "KVO_customizeViewController.h"
#import "KVO_Pass_value_fistViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"KVO";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"NameIdentifier"];

    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"NameIdentifier";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier
                             forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        
        cell.textLabel.text = @"系统KVO的实现";

    }else if (indexPath.row == 1) {
        
        cell.textLabel.text = @"自定义KVO的实现";

    }else{
        
        cell.textLabel.text = @"利用KVO实现页面中传值";

    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        KVO_systemViewController *vc= [[KVO_systemViewController alloc]init];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if(indexPath.row == 1){
        KVO_customizeViewController *vc= [[KVO_customizeViewController alloc]init];
                
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
     
        KVO_Pass_value_fistViewController *vc = [[KVO_Pass_value_fistViewController alloc]init];
        
        [self.navigationController pushViewController:vc animated:YES];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
