//
//  ZBRequestEngine.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ZBRequestConst.h"
@class ZBConfig;

@interface ZBRequestEngine : AFHTTPSessionManager
NS_ASSUME_NONNULL_BEGIN
+ (instancetype)defaultEngine;

/**
 公共基础配置
 */
- (void)setupBaseConfig:(void(^)(ZBConfig *config))block;

/**
 公共基础配置与单个请求配置的兼容
 */
- (void)configBaseWithRequest:(ZBURLRequest *)request;

/**
 发起网络请求

 @param request ZBURLRequest
 @param zb_progress 进度
 @param success 成功回调
 @param failure 失败回调
 @return task
 */
- (NSURLSessionDataTask *_Nullable)dataTaskWithMethod:(ZBURLRequest *_Nullable)request
                                          zb_progress:(void (^_Nullable)(NSProgress * _Nullable))zb_progress
                                              success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                              failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

/**
 上传文件

 @param request ZBURLRequest
 @param zb_progress 进度
 @param success 成功回调
 @param failure 失败回调
 @return task
 */
- (NSURLSessionUploadTask *_Nullable)uploadWithRequest:(ZBURLRequest *_Nullable)request
                                zb_progress:(void (^_Nullable)(NSProgress * _Nullable))zb_progress
                                    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

/**
 下载文件

 @param request ZBURLRequest
 @param downloadProgressBlock 进度
 @param completionHandler 回调
 @return task
 */
- (NSURLSessionDownloadTask *_Nullable)downloadWithRequest:(ZBURLRequest *_Nullable)request
                                                  progress:(void (^_Nullable)(NSProgress * _Nullable downloadProgress)) downloadProgressBlock
                                         completionHandler:(void (^_Nullable)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

/**
 管理请求对象的生命周期
 */
- (void)setRequestObject:(id)obj forkey:(NSString *)key;
- (void)removeRequestForkey:(NSString *)key;
- (id _Nullable)objectRequestForkey:(NSString *)key;

/**
 取消所有请求任务
 */
- (void)cancelAllRequest;

NS_ASSUME_NONNULL_END

@end
