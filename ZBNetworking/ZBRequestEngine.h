//
//  ZBRequestEngine.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ZBURLRequest.h"
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
 发起请求
 
 @param request     ZBURLRequest 对象
 @param progress    下载进度
 @param success     请求成功
 @param failed      请求失败
 */
- (void)sendRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed;
/**
 取消请求任务
 
 @param urlString    协议接口
 @param completion   后续操作
 */
- (void)cancelRequest:(NSString *)urlString completion:(cancelCompletedBlock)completion;


@end
