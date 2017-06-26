//
//  ZBURLSessionManager.h
//  ZBURLSessionManager
//
//  Created by NQ UEC on 16/5/13.
//  Copyright © 2016年 Suzhibin. All rights reserved.
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
#import "ZBURLRequest.h"

@protocol ZBURLSessionDelegate <NSObject>

@required
/**
 *  数据请求成功调用的方法
 *
 *  @param request ZBURLRequest
 */
- (void)urlRequestFinished:(ZBURLRequest *)request;
@optional
/**
 *  数据请求失败调用的方法
 *
 *  @param request  ZBURLRequest
 */
- (void)urlRequestFailed:(ZBURLRequest *)request;

@end

@interface ZBURLSessionManager : NSObject<NSURLSessionDelegate>

@property (nonatomic,copy)NSURLSession *urlSession;

@property (nonatomic,strong) ZBURLRequest *request;

@property (nonatomic, copy) requestSuccess success;

@property (nonatomic, copy) requestFailed failed;
/**
 *  delegate 赋值为实现协议的对象
 */
@property (nonatomic,weak) id<ZBURLSessionDelegate>delegate;

/**
 返回单例对象

 @return  “ZBURLSessionManager”对象
 */
+ (ZBURLSessionManager *)sharedInstance;

/**
 *  设置请求头 请在请求前使用该方法 如果在请求后使用 则不会起作用。
 *  Sets the value for the HTTP headers set in request objects made by the HTTP client. If `nil`, removes the existing value for that header.
 *
 *  @param value  The value set as default for the specified header.
 *  @param field  The HTTP header to set a default value for
 
 */
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 *  Returns the value for the HTTP headers set in the request Operation
 *
 *  @param field The HTTP header to retrieve the default value for
 *
 *  @return The value set as default for the specified header.
 */
- (NSString *)valueForHTTPHeaderField:(NSString *)field;

/**
 *  请求会话管理,取消请求任务
 *  Invalidates the managed session, optionally canceling pending tasks.
 *
 *  @param cancelPendingTasks Whether or not to cancel pending tasks.
 */
+ (void)requestToCancel:(BOOL)cancelPendingTasks;

/**
 *  类请求方法 get/post
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (void)requestWithConfig:(requestConfig)config success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  实例请求方法 get/post
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void)requestWithConfig:(requestConfig)config  success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  实例请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param delegate         代理  传实现协议的对象
 *
 */
- (void)GET:(NSString *)urlString parameters:(id)parameters target:(id<ZBURLSessionDelegate>)delegate;

/**
 *  实例请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param delegate         代理 传实现协议的对象
 *  @param type             用于直接区分不同的request对象 默认类型为 ZBRequestTypeDefault
 *
 */
- (void )GET:(NSString *)urlString parameters:(id)parameters target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type;

/**
 *  实例请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param type             用于直接区分不同的request对象 默认类型为 ZBRequestTypeDefault
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
- (void )GET:(NSString *)urlString parameters:(id)parameters apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  离线下载 请求方法
 *
 *  @param downloadArray    请求列队
 *  @param delegate         代理  传实现协议的对象
 *  @param type             用于直接区分不同的request对象 离线下载 为 ZBRequestTypeOffline
 */
- (void)offlineDownload:(NSMutableArray *)downloadArray target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type;

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
 *  类请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param delegate         代理  传实现协议的对象
 *
 */
+ (ZBURLSessionManager *)GET:(NSString *)urlString parameters:(id)parameters target:(id<ZBURLSessionDelegate>)delegate;

/**
 *  类请求 get
 *
 *  @param urlString        请求的协议地址
 *  @param delegate         代理 传实现协议的对象
 *  @param type             用于直接区分不同的request对象 默认类型为 ZBRequestTypeDefault
 *
 */
+ (ZBURLSessionManager *)GET:(NSString *)urlString parameters:(id)parameters target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type;

/**
 *  实例请求 post
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的字典
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 *
 */
- (void)POST:(NSString *)urlString parameters:(NSDictionary*)parameters success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  实例请求 post
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的字典
 *  @param delegate         代理 传实现协议的对象
 *
 */
- (void)POST:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<ZBURLSessionDelegate>)delegate;

/**
 *  类请求 post
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的字典
 *  @param delegate         代理 传实现协议的对象
 *
 */
+ (ZBURLSessionManager *)POST:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<ZBURLSessionDelegate>)delegate;

/**
 *  类请求 post
 *
 *  @param urlString        请求的协议地址
 *  @param parameters       请求所用的字典
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 *
 */
+ (ZBURLSessionManager *)POST:(NSString *)urlString parameters:(NSDictionary*)parameters success:(requestSuccess)success failed:(requestFailed)failed;


@end




