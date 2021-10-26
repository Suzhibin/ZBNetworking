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
#import "SettingViewController.h"
@interface CustomTabBarController ()

@end

@implementation CustomTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    HomeViewController *homeVC=[[HomeViewController alloc]init];
    [self setupChildViewController:homeVC title:@"首页" image:@"equal.square" selectedImage:@"equal.square.fill"];
    SettingViewController *settingVC=[[SettingViewController alloc]init];
    [self setupChildViewController:settingVC title:@"缓存设置" image:@"seal" selectedImage:@"seal.fill"];
    
    MethodViewController *methodVC=[[MethodViewController alloc]init];
    [self setupChildViewController:methodVC title:@"方法展示" image:@"tray.full" selectedImage:@"tray.full.fill"];
}
- (void)setupChildViewController:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    vc.title = title;
    if (@available(iOS 13.0, *)) {
          vc.tabBarItem.image=[[UIImage systemImageNamed:image]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
          vc.tabBarItem.selectedImage=[[UIImage systemImageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
      }
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
