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

/**
 *  公共配置方法
 *
 *  @param block           请求配置  Block
*/
+ (void)setupBaseConfig:(void(^_Nullable)(ZBConfig * _Nullable config))block;

/**
 *  自定义 请求、响应 处理逻辑的方法
 *  custom processing the response data.
 *  @param requestHandler           处理请求前的逻辑 Block
 *  @param responseHandler          处理响应结果的逻辑 Block
 */
+ (void)requestProcessHandler:(ZBRequestProcessBlock _Nullable )requestHandler responseProcessHandler:(ZBResponseProcessBlock _Nullable )responseHandler;

/**
 *  请求方法
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (NSURLSessionTask *_Nullable)requestWithConfig:(ZBRequestConfigBlock _Nonnull )config  success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure;

/**
 *  请求方法 进度
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (NSURLSessionTask *_Nullable)requestWithConfig:(ZBRequestConfigBlock _Nonnull )config  progress:(ZBRequestProgressBlock _Nullable )progress success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure;

/**
 *  批量请求方法
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (void)sendBatchRequest:(ZBBatchRequestConfigBlock _Nonnull )config success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure;

/**
 *  批量请求方法
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 *  @param finished         批量请求完成的 Block
*/
+ (void)sendBatchRequest:(ZBBatchRequestConfigBlock _Nonnull )config success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure finished:(ZBBatchRequestFinishedBlock _Nullable )finished;

/**
 *  批量请求方法 进度
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (void)sendBatchRequest:(ZBBatchRequestConfigBlock _Nonnull )config progress:(ZBRequestProgressBlock _Nullable )progress success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure;

/**
 *  批量请求方法 进度
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 *  @param finished         批量请求完成的 Block
*/
+ (void)sendBatchRequest:(ZBBatchRequestConfigBlock _Nonnull )config progress:(ZBRequestProgressBlock _Nullable )progress success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure finished:(ZBBatchRequestFinishedBlock _Nullable )finished;

/**
 * 取消所有请求任务
 */
+ (void)cancelAllRequest;

/**
 * 获取网络状态 是否可用
 */
+ (BOOL)isNetworkReachable;

@end

