//
//  ZBNetworkManager.h
//  ZBNetworking
//
//  Created by NQ UEC on 17/1/10.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//  ( https://github.com/Suzhibin )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "ZBURLRequest.h"

@interface ZBNetworkManager : NSObject

/**
 *  传参对象
 */
@property (nonatomic,strong) ZBURLRequest *request;

/**
 *  类请求方法 get/post 
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (void)requestWithConfig:(requestConfig)config  success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  类请求方法 get/post
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (void)requestWithConfig:(requestConfig)config  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  离线下载 请求方法 
 *
 *  @param downloadArray    请求列队
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (void)offlineDownload:(NSMutableArray *)downloadArray success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  取消请求任务
 *  Invalidates the managed session.
 *
 *  @param urlString        协议接口
 */
+ (void)cancelRequest:(NSString *)urlString completion:(cancelCompletedBlock)completion;

@end
