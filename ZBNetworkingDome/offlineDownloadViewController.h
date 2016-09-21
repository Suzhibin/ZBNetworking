//
//  offlineDownloadViewController.h
//  ZBNetworkingDome
//
//  Created by NQ UEC on 16/9/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "RootViewController.h"
@protocol offlineDelegate <NSObject>

/**
 *  数据请求成功调用的方法
 *
 *  @param request
 */
- (void)refreshSize;


@end

@interface offlineDownloadViewController : RootViewController
@property (nonatomic,weak)id<offlineDelegate>delegate;

@end
