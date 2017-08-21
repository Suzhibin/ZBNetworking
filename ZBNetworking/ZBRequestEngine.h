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
    3.过期时间默认为15秒 ，有暴露方法 可以自定义设置。
    4.开启菊花
    5.忽略系统缓存
 */
@interface ZBRequestEngine : AFHTTPSessionManager


+ (instancetype)defaultEngine;

/**
 取消请求任务
 
 @param urlString           协议接口
 */
- (NSString *)cancelRequest:(NSString *)urlString;


@end
