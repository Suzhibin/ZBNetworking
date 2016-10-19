//
//  RootViewController.h
//  ZBNetworking
//
//  Created by NQ UEC on 16/6/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import <UIKit/UIKit.h>
#define home_URL @"http://api.dotaly.com/lol/api/v1/authors?iap=0"

#define details_URL @"http://api.dotaly.com/lol/api/v1/shipin/latest?author=%@&iap=0jb=0&limit=50&offset=0"
@interface RootViewController : UIViewController
//title 设置btn的标题; selector点击btn实现的方法; isLeft 标记btn的位置
- (void)addItemWithTitle:(NSString *)title selector:(SEL)selector location:(BOOL)isLeft;
//title提示框的标题; andMessage提示框的描述
- (void)alertTitle:(NSString *)title andMessage:(NSString *)message isother:(NSString *)other;

@end
