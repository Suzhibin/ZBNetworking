//
//  ZBRequestConst.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#ifndef ZBRequestConst_h
#define ZBRequestConst_h
@class ZBURLRequest,ZBBatchRequest;

#define ZBBUG_LOG 0

#if(ZBBUG_LOG == 1)
# define ZBLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
# define ZBLog(...);
#endif

/**
 用于标识不同类型的请求
 */
typedef NS_ENUM(NSInteger,apiType) {
    /** 重新请求,   不读取缓存，重新请求*/
    ZBRequestTypeRefresh,
    /** 读取缓存,   有缓存,读取缓存--无缓存，重新请求*/
    ZBRequestTypeCache,
    /** 加载更多,   不读取缓存，重新请求*/
    ZBRequestTypeRefreshMore,
    /** 加载更多,   有缓存,读取缓存--无缓存，重新请求*/
    ZBRequestTypeCacheMore,
    /** 详情页面,   有缓存,读取缓存--无缓存，重新请求*/
    ZBRequestTypeDetailCache,
    /** 自定义项,   有缓存,读取缓存--无缓存，重新请求*/
    ZBRequestTypeCustomCache
};
/**
 HTTP 请求类型.
 */
typedef NS_ENUM(NSInteger,MethodType) {
    /**GET请求*/
    ZBMethodTypeGET,
    /**POST请求*/
    ZBMethodTypePOST,
    /**Upload请求*/
    ZBMethodTypeUpload,
    /**DownLoad请求*/
    ZBMethodTypeDownLoad
};
/**
 请求参数的格式.
 */
typedef NS_ENUM(NSUInteger, requestSerializer) {
    /** 设置请求参数为JSON格式*/
    ZBSerializerJSON,
    /** 设置请求参数为二进制格式*/
    ZBSerializerHTTP
};

/** 批量请求配置的Block */
typedef void (^batchRequestConfig)(ZBBatchRequest * batchRequest);
/** 请求配置的Block */
typedef void (^requestConfig)(ZBURLRequest * request);
/** 请求成功的Block */
typedef void (^requestSuccess)(id responseObject,apiType type);
/** 请求失败的Block */
typedef void (^requestFailed)(NSError * error);
/** 请求进度的Block */
typedef void (^progressBlock)(NSProgress * progress);
/** 请求取消的Block */
typedef void (^cancelCompletedBlock)(NSString * urlString);


#endif /* ZBRequestConst_h */
