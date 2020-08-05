//
//  RequestTool.h
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2020/6/2.
//  Copyright © 2020 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>
#define server_URL @"http://api.dotaly.com/lol/api/v1/"
#define list_URL @"authors"

#define details_URL @"shipin/latest"
NS_ASSUME_NONNULL_BEGIN

@interface RequestTool : NSObject
+ (void)setupPublicParameters;
@end

NS_ASSUME_NONNULL_END
