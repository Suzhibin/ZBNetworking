//
//  ZBURLRequest.h
//  ZBNetworkingDemo
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

//用于标识不同类型的请求
typedef NS_ENUM(NSInteger,apiType) {
    
    ZBRequestTypeDefault,   //默认类型
    ZBRequestTypeRefresh,   //重新请求 （有缓存，不读取，重新请求）
    ZBRequestTypeLoadMore,  //加载更多
    ZBRequestTypeDetail,    //详情
    ZBRequestTypeOffline,   //离线    （有缓存，不读取，重新请求）
    ZBRequestTypeCustom     //自定义
    
} ;

typedef NS_ENUM(NSInteger,MethodType) {
    
    ZBMethodTypeGET,
    ZBMethodTypePOST
} ;

typedef void (^requestConfig)(ZBURLRequest *request);

typedef void (^requestSuccess)(id responseObj,apiType type);

typedef void (^requestFailed)(NSError *error);

typedef void (^progressBlock)(NSProgress * progress);

@interface ZBURLRequest : NSObject

/**
 *  用于标识不同类型的request
 */
@property (nonatomic,assign) apiType apiType;
/**
 *  用于标识不同类型的request
 */
@property (nonatomic,assign) MethodType methodType;
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
 *  请求错误
 */
@property (nonatomic,strong)NSError *error;

/**
 *  用于维护多个request对象
 */
@property ( nonatomic, strong) NSMutableDictionary *requestDic;

/**
 *  用于维护 请求头的request对象
 */
@property ( nonatomic, strong) NSMutableDictionary *mutableHTTPRequestHeaders;

/**
 *  用于判断是否有请求头
 */
@property (nonatomic,copy) NSString *value;

+ (ZBURLRequest *)sharedInstance;

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

/**
 *
 *  @param obj request 对象
 *  @param key key
 */
- (void)setRequestObject:(id)obj forkey:(NSString *)key;

/**
 删除对应的key
 
 @param key key
 */
- (void)removeRequestForkey:(NSString *)key;


@end
