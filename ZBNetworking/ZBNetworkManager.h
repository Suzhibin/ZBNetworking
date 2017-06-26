//
//  ZBNetworkManager.h
//  ZBNetworkingDemo
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

@property (nonatomic,strong) ZBURLRequest *request;

@property (nonatomic, copy)requestSuccess success;
@property (nonatomic, copy)requestFailed failed;
@property (nonatomic, copy)progressBlock progres;
/**
 *  用于标识不同类型的方法
 */
@property (nonatomic,assign) MethodType methodType;

/**
 返回单例对象
 
 @return  ZBNetworkManager 对象
 */
+ (ZBNetworkManager *)sharedInstance;

/**
 *   请求会话管理,取消请求任务
 *  Invalidates the managed session, optionally canceling pending tasks.
 *
 *  @param cancelPendingTask Whether or not to cancel pending tasks.
 */
+ (void)requestToCancel:(BOOL)cancelPendingTask;

/**
 *  网络状态监测
 */
+ (NSInteger)startNetWorkMonitoring;

/**
 *  离线下载 请求方法
 *
 *  @param downloadArray    请求列队
 *  @param type             用于直接区分不同的request对象 离线下载 为 ZBRequestTypeOffline
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void)offlineDownload:(NSMutableArray *)downloadArray apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed;

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
 *  实例请求方法 get/post
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void)requestWithConfig:(requestConfig)config success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  实例请求方法 get/post
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void)requestWithConfig:(requestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed;
/**
 *  实例请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void)GET:(NSString *)urlString success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  实例请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的参数
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void)GET:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  实例请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的参数
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void)GET:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  实例请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的参数
 *  @param type             请求类型
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void)GET:(NSString *)urlString parameters:(id)parameters apiType:(apiType)type progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  类请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (ZBNetworkManager *)GET:(NSString *)urlString success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  类请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的参数
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (ZBNetworkManager *)GET:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  类请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的参数
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (ZBNetworkManager *)GET:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  类请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的参数
 *  @param type             请求类型
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (ZBNetworkManager *)GET:(NSString *)urlString parameters:(id)parameters apiType:(apiType)type  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  实例请求 post
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的参数
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void)POST:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  实例请求 post
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的参数
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void)POST:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  类请求方法 post
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的参数
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (ZBNetworkManager *)POST:(NSString *)urlString parameters:(NSDictionary*)parameters success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  类请求方法 post
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的参数
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (ZBNetworkManager *)POST:(NSString *)urlString parameters:(NSDictionary*)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed;

@end
