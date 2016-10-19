//
//  WebViewController.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 16/10/17.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "RootViewController.h"
@protocol WebViewControllerDelegate <NSObject>

- (void)reloadData;
@end

@interface WebViewController : RootViewController

@property (nonatomic,copy)NSString *weburl;
@property (nonatomic,weak)id<WebViewControllerDelegate>delegate;

@end
