//
//  offlineDownloadViewController.h
//  ZBNetworkingDome
//
//  Created by NQ UEC on 16/9/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "RootViewController.h"
@protocol offlineDelegate <NSObject>

- (void)Finished;
- (void)progressSize:(double)size;

@end

@interface offlineDownloadViewController : RootViewController
@property (nonatomic,weak)id<offlineDelegate>delegate;

@end
