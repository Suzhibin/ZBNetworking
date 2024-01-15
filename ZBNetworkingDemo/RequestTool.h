//
//  RequestTool.h
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2020/6/2.
//  Copyright © 2020 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>
//#define server_URL @"http://api.dotaly.com"
#define url_server @"http://h5.jp.51wnl.com/"
//#define list_URL @"/lol/api/v1/authors"
#define url_path @"wnl/tag/page"
//#define details_URL @"/lol/api/v1/shipin/latest"

NS_ASSUME_NONNULL_BEGIN

@interface RequestTool : NSObject
+ (instancetype)sharedInstance;
- (void)setupPublicParameters;
@end

NS_ASSUME_NONNULL_END
