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
#import <UIKit/UIKit.h>
@class ZBURLSessionManager;



//用于标识不同类型的请求
typedef NS_ENUM(NSInteger,apiType) {
    
    ZBRequestTypeDefault,   //默认类型
    ZBRequestTypeRefresh,   //重新请求 （不读缓存）
    ZBRequestTypeLoadMore,  //加载更多
    ZBRequestTypeDetail,    //详情
    ZBRequestTypeLocation,  //位置

} ;


@protocol ZBURLSessionDelegate <NSObject>
@required
/**
 *  数据请求成功调用的方法
 *
 *  @param request
 */
- (void)urlRequestFinished:(ZBURLSessionManager *)request;
@optional
/**
 *  数据请求失败调用的方法
 *
 *  @param request
 */
- (void)urlRequestFailed:(ZBURLSessionManager *)request;

@end


@interface ZBURLSessionManager : NSObject<NSURLSessionDelegate>


@property (nonatomic,copy)NSURLSession *session;

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@property (nonatomic, strong) NSMutableURLRequest *request;

@property (nonatomic, copy) void (^FinishedBlock)(ZBURLSessionManager *);
@property (nonatomic, copy) void (^FailedBlock)(ZBURLSessionManager *);
/**
 *  接口(请求地址)
 */
@property (nonatomic,copy) NSString *requestString;

/**
 *  数据,提供给外部使用
 */
@property (nonatomic,retain) NSMutableData *downloadData;

/**
 *  delegate 赋值为实现协议的对象
 */
@property (nonatomic,assign) id<ZBURLSessionDelegate>delegate;

/**
 *  用于标识不同类型的request
 */
@property (nonatomic,assign) apiType apiType;

/**
 *  请求错误
 */
@property (nonatomic,strong)NSError *error;

/**
 *  设置超时时间  默认15秒
 *   The timeout interval, in seconds, for created requests. The default timeout interval is 15 seconds.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  创建并返回一个“ZBURLSessionManager”对象
 *  Creates and returns an `ZBURLSessionManager` object
 */
+ (instancetype)manager;

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

//- (void)getRequestWithUrlString:(NSString *)requestString completion:(void (^)(ZBURLSessionManager *))finished completion:(void (^)(ZBURLSessionManager *))Failed;
/**
 *  get请求
 *
 *  @param requestString 请求的协议地址
 *  @param delegate      代理  传实现协议的对象
 *
 */
- (void)getRequestWithUrlString:(NSString *)requestString target:(id<ZBURLSessionDelegate>)delegate;

/**
 *  get请求
 *
 *  @param requestString 请求的协议地址
 *  @param delegate      代理 传实现协议的对象
 *  @param type          用于直接区分不同的request对象 比如:kRefreshType 默认为kDefaultType
 *
 */
- (void )getRequestWithUrlString:(NSString *)requestString target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type;

/**
 *  post 请求
 *
 *  @param requestString 请求的协议地址
 *  @param dict          请求所用的字典
 *  @param delegate      代理 传实现协议的对象
 *
 */
- (void)postRequestWithUrlString:(NSString *)requestString dict:(NSDictionary*)dict target:(id<ZBURLSessionDelegate>)delegate;

/**
 *  get请求
 *
 *  @param requestString 请求的协议地址
 *  @param delegate      代理  传实现协议的对象
 *
 */
+(ZBURLSessionManager *)getRequestWithUrlString:(NSString *)requestString target:(id<ZBURLSessionDelegate>)delegate;

/**
 *  get请求
 *
 *  @param requestString 请求的协议地址
 *  @param delegate      代理 传实现协议的对象
 *  @param type          用于直接区分不同的request对象 比如:kRefreshType 默认为kDefaultType
 *
 */
+(ZBURLSessionManager *)getRequestWithUrlString:(NSString *)requestString target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type;

/**
 *  post 请求
 *
 *  @param requestString 请求的协议地址
 *  @param dict          请求所用的字典
 *  @param delegate      代理 传实现协议的对象
 *
 */
+(ZBURLSessionManager *)postRequestWithUrlString:(NSString *)requestString dict:(NSDictionary*)dict target:(id<ZBURLSessionDelegate>)delegate;




@end




