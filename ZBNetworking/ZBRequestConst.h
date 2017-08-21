//
//  ZBRequestConst.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#ifndef ZBRequestConst_h
#define ZBRequestConst_h
@class ZBURLRequest;

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
    /** 重新请求 ,不读取缓存，重新请求*/
    ZBRequestTypeRefresh,
    /** 有缓存,读取缓存 无缓存，重新请求*/
    ZBRequestTypeCache,
    /** 加载更多 ,不读取缓存，重新请求*/
    ZBRequestTypeRefreshMore,
    /** 加载更多 ,有缓存,读取缓存 无缓存，重新请求*/
    ZBRequestTypeCacheMore,
    /** 详情    ,有缓存,读取缓存 无缓存，重新请求*/
    ZBRequestTypeDetailCache,
    /** 离线    ,不读取缓存，重新请求*/
    ZBRequestTypeOffline,
    /** 自定义  ,有缓存,读取缓存 无缓存，重新请求*/
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
    ZBSerializerHTTP,
};

/** 请求配置的Block */
typedef void (^requestConfig)(ZBURLRequest * _Nullable request);
/** 请求成功的Block */
typedef void (^requestSuccess)(id _Nullable responseObj,apiType type);
/** 请求失败的Block */
typedef void (^requestFailed)(NSError * _Nullable error);
/** 请求进度的Block */
typedef void (^progressBlock)(NSProgress * _Nullable progress);
/** 请求取消的Block */
typedef void (^cancelCompletedBlock)(NSString * _Nullable urlString);


#endif /* ZBRequestConst_h */
