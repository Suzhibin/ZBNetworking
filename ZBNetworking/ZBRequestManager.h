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
 *  插件机制
 *  自定义 请求 处理逻辑的方法
 *  @param requestHandler           处理请求前的逻辑 Block
 */
+ (void)setRequestProcessHandler:(ZBRequestProcessBlock _Nullable )requestHandler;
/**
 *  插件机制
 *  自定义 响应 处理逻辑的方法
 *  @param responseHandler          处理响应结果的逻辑 Block
 */
+ (void)setResponseProcessHandler:(ZBResponseProcessBlock _Nullable )responseHandler;
/**
 *  插件机制
 *  自定义 错误 处理逻辑的方法
 *  @param errorHandler          处理响应结果的逻辑 Block
 */
+ (void)setErrorProcessHandler:(ZBErrorProcessBlock _Nullable )errorHandler;

/**
 *  请求方法
 *  @param config           请求配置  Block
 *  @param target         执行代理的对象
 *  @return identifier      请求标识符
 */
+ (NSUInteger)requestWithConfig:(ZBRequestConfigBlock _Nonnull )config target:(id<ZBURLRequestDelegate>_Nonnull)target;

/**
 *  请求方法
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @return identifier      请求标识符
 */
+ (NSUInteger)requestWithConfig:(ZBRequestConfigBlock _Nonnull )config success:(ZBRequestSuccessBlock _Nullable )success;

/**
 *  请求方法
 *  @param config           请求配置  Block
 *  @param failure          请求失败的 Block
 *  @return identifier      请求标识符
 */
+ (NSUInteger)requestWithConfig:(ZBRequestConfigBlock _Nonnull )config failure:(ZBRequestFailureBlock _Nullable )failure;

/**
 *  请求方法
 *  @param config           请求配置  Block
 *  @param finished         请求完成的 Block
 *  @return identifier      请求标识符
 */
+ (NSUInteger)requestWithConfig:(ZBRequestConfigBlock _Nonnull )config finished:(ZBRequestFinishedBlock _Nullable )finished;

/**
 *  请求方法
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 *  @return identifier      请求标识符
 */
+ (NSUInteger)requestWithConfig:(ZBRequestConfigBlock _Nonnull )config  success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure;

/**
 *  请求方法
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 *  @param finished         请求完成的 Block
 *  @return identifier      请求标识符
 */
+ (NSUInteger)requestWithConfig:(ZBRequestConfigBlock _Nonnull )config  success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure finished:(ZBRequestFinishedBlock _Nullable )finished;

/**
 *  请求方法 进度
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 *  @return identifier      请求标识符
 */
+ (NSUInteger)requestWithConfig:(ZBRequestConfigBlock _Nonnull )config  progress:(ZBRequestProgressBlock _Nullable )progress success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure;

/**
 *  请求方法 进度
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 *  @param finished         请求完成的 Block
 *  @return identifier      请求标识符
 */
+ (NSUInteger)requestWithConfig:(ZBRequestConfigBlock _Nonnull)config progress:(ZBRequestProgressBlock _Nullable )progress success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure finished:(ZBRequestFinishedBlock _Nullable )finished;

/**
 *  批量请求方法
 *  @param config           请求配置  Block
 *  @param target           执行代理的对象
 *  @return identifier      请求标识符
 */
+ (ZBBatchRequest *_Nullable)requestBatchWithConfig:(ZBBatchRequestConfigBlock _Nullable )config target:(id<ZBURLRequestDelegate>_Nonnull)target;

/**
 *  批量请求方法
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 *  @param finished         批量请求完成的 Block
 *  @return BatchRequest    批量请求对象
 */
+ (ZBBatchRequest *_Nullable)requestBatchWithConfig:(ZBBatchRequestConfigBlock _Nonnull )config success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure finished:(ZBBatchRequestFinishedBlock _Nullable )finished;

/**
 *  批量请求方法 进度
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 *  @param finished         批量请求完成的 Block
 *  @return BatchRequest    批量请求对象
 */
+ (ZBBatchRequest *_Nullable)requestBatchWithConfig:(ZBBatchRequestConfigBlock _Nonnull )config progress:(ZBRequestProgressBlock _Nullable )progress success:(ZBRequestSuccessBlock _Nullable )success failure:(ZBRequestFailureBlock _Nullable )failure finished:(ZBBatchRequestFinishedBlock _Nullable )finished;

/**
 *  取消单个请求任务
 *  @param identifier        请求identifier
 */
+ (void)cancelRequest:(NSUInteger)identifier;

/**
 *  取消批量请求任务
 *  @param batchRequest       批量请求对象
 */
+ (void)cancelBatchRequest:(ZBBatchRequest *_Nullable)batchRequest;

/**
 *  取消所有请求任务 活跃的请求都会被取消
 */
+ (void)cancelAllRequest;

/**
 *  获取网络状态 是否可用
 */
+ (BOOL)isNetworkReachable;

/**
 *  当前网络的状态值，
 *  -1 表示 `Unknown`，0 表示 `NotReachable，1 表示 `WWAN`，2 表示 `WiFi`
 */
+ (NSInteger)networkReachability;

@end

