//
//  CustomTabBarController.m
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2018/10/12.
//  Copyright © 2018年 Suzhibin. All rights reserved.
//

#import "CustomTabBarController.h"
#import "HomeViewController.h"
#import "MethodViewController.h"
@interface CustomTabBarController ()

@end

@implementation CustomTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    HomeViewController *HomeVC=[[HomeViewController alloc]init];
    [self setupChildViewController:HomeVC title:@"缓存展示"];
    MethodViewController *MethodVC=[[MethodViewController alloc]init];
    [self setupChildViewController:MethodVC title:@"方法展示"];
}
- (void)setupChildViewController:(UIViewController *)vc title:(NSString *)title
{
    vc.title = title;
    [self addChildViewController:[[UINavigationController alloc] initWithRootViewController:vc]];
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
