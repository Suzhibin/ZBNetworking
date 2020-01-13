//
//  ZBRequestManager.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBRequestEngine.h"

@class ZBConfig;

@interface ZBRequestManager : NSObject

+ (void)setupBaseConfig:(void(^_Nullable)(ZBConfig * _Nullable config))block;
/**
 *  请求方法
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (NSURLSessionTask *_Nullable)requestWithConfig:(requestConfig _Nonnull )config  success:(requestSuccess _Nullable )success failure:(requestFailure _Nullable )failure;

/**
 *  请求方法 进度
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (NSURLSessionTask *_Nullable)requestWithConfig:(requestConfig _Nonnull )config  progress:(progressBlock _Nullable )progress success:(requestSuccess _Nullable )success failure:(requestFailure _Nullable )failure;

/**
 *  批量请求方法
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (void)sendBatchRequest:(batchRequestConfig _Nonnull )config success:(requestSuccess _Nullable )success failure:(requestFailure _Nullable )failure;

/**
 *  批量请求方法
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 *  @param finished         批量请求完成的 Block
*/
+ (void)sendBatchRequest:(batchRequestConfig _Nonnull )config success:(requestSuccess _Nullable )success failure:(requestFailure _Nullable )failure finished:(batchRequestFinished _Nullable )finished;

/**
 *  批量请求方法 进度
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (void)sendBatchRequest:(batchRequestConfig _Nonnull )config progress:(progressBlock _Nullable )progress success:(requestSuccess _Nullable )success failure:(requestFailure _Nullable )failure;

/**
 *  批量请求方法 进度
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 *  @param finished         批量请求完成的 Block
*/
+ (void)sendBatchRequest:(batchRequestConfig _Nonnull )config progress:(progressBlock _Nullable )progress success:(requestSuccess _Nullable )success failure:(requestFailure _Nullable )failure finished:(batchRequestFinished _Nullable )finished;

/**
 取消所有请求任务
*/
+ (void)cancelAllRequest;

@end

