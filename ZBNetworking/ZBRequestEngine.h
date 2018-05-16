//
//  ZBRequestEngine.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ZBRequestConst.h"
/*
    硬性设置：
    1.服务器返回的数据 必须是二进制
    2.证书设置
    3.开启菊花
 */
@interface ZBRequestEngine : AFHTTPSessionManager

+ (instancetype)defaultEngine;

/**
 发起网络请求

 @param request ZBURLRequest
 @param zb_progress 进度
 @param success 成功回调
 @param failure 失败回调
 @return task
 */
- (NSURLSessionDataTask *)dataTaskWithMethod:(ZBURLRequest *)request
                             zb_progress:(void (^)(NSProgress * _Nonnull))zb_progress
                              success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 上传文件

 @param request ZBURLRequest
 @param zb_progress 进度
 @param success 成功回调
 @param failure 失败回调
 @return task
 */
- (NSURLSessionDataTask *)uploadWithRequest:(ZBURLRequest *)request
                                zb_progress:(void (^)(NSProgress * _Nonnull))zb_progress
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 下载文件

 @param request ZBURLRequest
 @param downloadProgressBlock 进度
 @param completionHandler 回调
 @return task
 */
- (NSURLSessionDownloadTask *)downloadWithRequest:(ZBURLRequest *)request
                                         progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

/**
 取消请求任务
 
 @param urlString           协议接口
 */
- (void)cancelRequest:(NSString *)urlString  completion:(cancelCompletedBlock)completion;


@end
