//
//  ZBRequestManager.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBRequestEngine.h"
@interface ZBRequestManager : NSObject

/**
 *  请求方法 get/post
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (void)requestWithConfig:(requestConfig)config  success:(requestSuccess)success failure:(requestFailure)failure;

/**
 *  请求方法 get/post
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 *  @param finished          请求失败的 Block
 */
+ (void)requestWithConfig:(requestConfig)config  success:(requestSuccess)success failure:(requestFailure)failure finished:(requestFinished)finished;

/**
 *  请求方法 get/post/Upload/DownLoad
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (void)requestWithConfig:(requestConfig)config  progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure;

/**
 *  请求方法 get/post/Upload/DownLoad
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (void)requestWithConfig:(requestConfig)config  progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure finished:(requestFinished)finished;

/**
 *  批量请求方法 get/post
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (ZBBatchRequest *)sendBatchRequest:(batchRequestConfig)config success:(requestSuccess)success failure:(requestFailure)failure;

/**
 *  批量请求方法 get/post/Upload/DownLoad
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (ZBBatchRequest *)sendBatchRequest:(batchRequestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure;

/**
 取消请求任务
 
 @param URLString           协议接口
 @param completion          后续操作
 */
+ (void)cancelRequest:(NSString *)URLString completion:(cancelCompletedBlock)completion;

@end
