//
//  ZBURLRequest.h
//  ZBNetworking
//
//  Created by NQ UEC on 16/12/20.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class  ZBURLRequest;

#define ZBBUG_LOG 0

#if(ZBBUG_LOG == 1)
# define ZBLog(fmt, ...) NSLog((@"[函数名:%s]" " [第 %d 行]\n" fmt),  __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define ZBLog(...);
#endif

/**
 用于标识不同类型的请求
 */
typedef NS_ENUM(NSInteger,apiType) {
    /** 默认类型 ,读取缓存 不请求*/
    ZBRequestTypeDefault,
    /** 重新请求 ,不读取缓存，重新请求*/
    ZBRequestTypeRefresh,
    /** 加载更多 ,不读取缓存，重新请求*/
    ZBRequestTypeRefreshMore,
    /** 加载更多 ,读取缓存，不请求*/
    ZBRequestTypeLoadMore,
    /** 详情    ,读取缓存，不请求*/
    ZBRequestTypeDetail,
    /** 离线    ,不读取缓存，重新请求*/
    ZBRequestTypeOffline,
    /** 自定义  ,读取缓存，不请求*/
    ZBRequestTypeCustom
};
/**
 HTTP 请求类型.
 */
typedef NS_ENUM(NSInteger,MethodType) {
    /**GET请求*/
    GET,
    /**POST请求*/
    POST
};
/**
  请求参数的格式.
 */
typedef NS_ENUM(NSUInteger, requestSerializer) {
    /** 设置请求参数为JSON格式*/
    ZBSerializerJSON,
    /** 设置请求参数为二进制格式*/
    ZBSerializerHTTP,
};

/** 请求配置的Block */
typedef void (^requestConfig)(ZBURLRequest *request);
/** 请求成功的Block */
typedef void (^requestSuccess)(id responseObj,apiType type);
/** 请求失败的Block */
typedef void (^requestFailed)(NSError *error);
/** 请求进度的Block */
typedef void (^progressBlock)(NSProgress * progress);
/** 请求取消的Block */
typedef void (^cancelCompletedBlock)(NSString *urlString);

@interface ZBURLRequest : NSObject

/**
 *  用于标识不同类型的request状态
 */
@property (nonatomic,assign) apiType apiType;

/**
 *  用于标识不同类型的request
 */
@property (nonatomic,assign) MethodType methodType;

/**
 *  请求参数的类型
 */
@property (nonatomic,assign) requestSerializer requestSerializer;

/**
 *  接口(请求地址)
 */
@property (nonatomic,copy) NSString *urlString;

/**
 请求url列队容器
 */
@property (nonatomic,strong) NSMutableArray *urlArray;

/**
 *  提供给外部配置参数使用
 */
@property (nonatomic,strong) id parameters;

/**
 *  数据,提供给外部使用
 */
@property (nonatomic,strong) NSMutableData *responseObj;

/**
 *  设置超时时间  默认15秒
 *   The timeout interval, in seconds, for created requests. The default timeout interval is 15 seconds.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  用于维护 请求头的request对象
 */
@property ( nonatomic, strong) NSMutableDictionary *mutableHTTPRequestHeaders;

/**
 *  添加请求头
 *
 *  @param value value
 *  @param field field
 */
- (void)setValue:(NSString *)value forHeaderField:(NSString *)field;

/**
 *
 *  @param key request 对象
 *
 *  @return request 对象
 */
- (NSString *)objectHeaderForKey:(NSString *)key;

/**
 *  删除请求头的key
 *
 *  @param key key
 */
- (void)removeHeaderForkey:(NSString *)key;

/**
 *  @return urlArray 返回url数组
 */
- (NSMutableArray *)offlineUrlArray;

/**
 *  @return urlArray 返回其他参数数组
 */
- (NSMutableArray *)offlineKeyArray;

/**
 离线下载 将url 添加到请求列队
 
 @param urlString 请求地址
 */
- (void)addObjectWithUrl:(NSString *)urlString;

/**
 离线下载 将url 从请求列队删除
 
 @param urlString 请求地址
 */
- (void)removeObjectWithUrl:(NSString *)urlString;

/**
 离线下载 将栏目其他参数  添加到容器
 
 @param name 栏目名字 或 其他 key
 */
- (void)addObjectWithKey:(NSString *)name;

/**
 离线下载 将栏目其他参数 从容器删除
 
 @param name 请求地址 或 其他 key
 */
- (void)removeObjectWithKey:(NSString *)name;

/**
 离线下载 删除全部请求列队
 */
- (void)removeOfflineArray;

/**
 离线下载 判断栏目url 或 其他参数 是否已添加到请求容器
 
 @param key   请求地址 或 其他参数
 @param isUrl 是否是url
 
 @return 1:0
 */
- (BOOL)isAddForKey:(NSString *)key isUrl:(BOOL)isUrl;

/**
 离线下载 将url 或 其他参数 添加到请求列队
 
 @param key   请求地址 或 其他参数
 @param isUrl 是否是url
 */
- (void)addObjectWithForKey:(NSString *)key isUrl:(BOOL)isUrl;

/**
 离线下载 将url 或 其他参数 从请求列队删除
 
 @param key   请求地址 或 其他参数
 @param isUrl 是否是url
 */
- (void)removeObjectWithForkey:(NSString *)key isUrl:(BOOL)isUrl;




@end
