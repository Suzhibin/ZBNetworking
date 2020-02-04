//
//  RootViewController.h
//  ZBNetworking
//
//  Created by NQ UEC on 16/6/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import <UIKit/UIKit.h>
#define server_URL @"http://api.dotaly.com/lol/api/v1/"
#define list_URL @"authors"

#define details_URL @"shipin/latest"

//屏幕宽
#define SCREEN_WIDTH                ([UIScreen mainScreen].bounds.size.width)
//屏幕高
#define SCREEN_HEIGHT               ([UIScreen mainScreen].bounds.size.height)
@interface RootViewController : UIViewController
//title 设置btn的标题; selector点击btn实现的方法; isLeft 标记btn的位置
- (void)addItemWithTitle:(NSString *)title selector:(SEL)selector location:(BOOL)isLeft;
- (void)customItemWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle selector:(SEL)selector location:(BOOL)isLeft;
//title提示框的标题; andMessage提示框的描述
- (void)alertTitle:(NSString *)title andMessage:(NSString *)message;

@end
