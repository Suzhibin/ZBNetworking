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

/**
 用于标识不同类型的请求
 默认为重新请求.  default:ZBRequestTypeRefresh
 */
typedef NS_ENUM(NSInteger,ZBApiType) {
    /**
     重新请求:   不读取缓存，不存储缓存
     没有缓存需求的，单独使用
     */
    ZBRequestTypeRefresh,
    
    /**
     重新请求:   不读取缓存，但存储缓存
     可以与 ZBRequestTypeCache 配合使用
     */
    ZBRequestTypeRefreshAndCache,
    /**
     读取缓存:   有缓存,读取缓存--无缓存，重新请求并存储缓存
     可以与ZBRequestTypeRefreshAndCache 配合使用
     */
    ZBRequestTypeCache,
    /**
     重新请求：  上拉加载更多业务，不读取缓存，不存储缓存
     用于区分业务 可以不用
     */
    ZBRequestTypeRefreshMore,
};
/**
 HTTP 请求类型.
 默认为GET请求.   default:ZBMethodTypeGET
 */
typedef NS_ENUM(NSInteger,ZBMethodType) {
    /**GET请求*/
    ZBMethodTypeGET,
    /**POST请求*/
    ZBMethodTypePOST,
    /**Upload请求*/
    ZBMethodTypeUpload,
    /**DownLoad请求*/
    ZBMethodTypeDownLoad,
    /**PUT请求*/
    ZBMethodTypePUT,
    /**PATCH请求*/
    ZBMethodTypePATCH,
    /**DELETE请求*/
    ZBMethodTypeDELETE
};
/**
 请求参数的格式.
 默认为HTTP.   default:ZBJSONRequestSerializer
 */
typedef NS_ENUM(NSUInteger, ZBRequestSerializerType) {
    /** 设置请求参数为JSON格式*/
    ZBJSONRequestSerializer,
    /** 设置请求参数为二进制格式*/
    ZBHTTPRequestSerializer,
};
/**
 返回响应数据的格式.
 默认为JSON.  default:ZBJSONResponseSerializer
 */
typedef NS_ENUM(NSUInteger, ZBResponseSerializerType) {
    /** 设置响应数据为JSON格式*/
    ZBJSONResponseSerializer,
    /** 设置响应数据为二进制格式*/
    ZBHTTPResponseSerializer
};
/**
 相同的URL 多次网络请求,请求结果没有响应的时候。可以指定使用第一次或最后一次请求结果。
 如果请求结果响应了，会终止此过程。
 默认不做任何操作.  default:ZBResponseKeepNone
 */
typedef NS_ENUM(NSUInteger, ZBResponseKeepType) {
    /** 不进行任何操作*/
    ZBResponseKeepNone,
    /** 使用第一次请求结果*/
    ZBResponseKeepFirst,
    /** 使用最后一次请求结果*/
    ZBResponseKeepLast

};
/** 批量请求配置的Block */
typedef void (^ZBBatchRequestConfigBlock)(ZBBatchRequest * _Nonnull batchRequest);
/** 请求配置的Block */
typedef void (^ZBRequestConfigBlock)(ZBURLRequest * _Nonnull request);
/** 请求成功的Block */
typedef void (^ZBRequestSuccessBlock)(id _Nullable responseObject,ZBURLRequest * _Nullable request);
/** 请求失败的Block */
typedef void (^ZBRequestFailureBlock)(NSError * _Nullable error);
/** 请求进度的Block */
typedef void (^ZBRequestProgressBlock)(NSProgress * _Nullable progress);
/** 请求取消的Block */
typedef void (^ZBRequestFinishedBlock)(id _Nullable responseObject,NSError * _Nullable error);
/** 批量请求完成的Block */
typedef void (^ZBBatchRequestFinishedBlock)(NSArray<id> * _Nullable responseObjects);

typedef void (^ZBResponseProcessBlock)(ZBURLRequest * _Nullable request, id _Nullable responseObject, NSError * _Nullable __autoreleasing * _Nullable error);

#endif /* ZBRequestConst_h */
