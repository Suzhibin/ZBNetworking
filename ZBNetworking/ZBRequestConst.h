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
 默认为JSON.   default:ZBJSONRequestSerializer
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
/**
 操作状态
 */
typedef NS_ENUM(NSUInteger, ZBDownloadState) {
    /** 开始请求*/
    ZBDownloadStateStart,
    /** 暂停请求*/
    ZBDownloadStateStop,
};
/**
 *  当前网络的状态值，
 */
typedef NS_ENUM(NSInteger, ZBNetworkReachabilityStatus) {
    /** Unknown*/
    ZBNetworkReachabilityStatusUnknown          = -1,
    /** NotReachable*/
    ZBNetworkReachabilityStatusNotReachable     = 0,
    /** WWAN*/
    ZBNetworkReachabilityStatusViaWWAN          = 1,
    /** WiFi*/
    ZBNetworkReachabilityStatusViaWiFi          = 2,
};

//==================================================
/** 请求配置的Block */
typedef void (^ZBRequestConfigBlock)(ZBURLRequest * _Nullable request);
/** 请求成功的Block */
typedef void (^ZBRequestSuccessBlock)(id _Nullable responseObject,ZBURLRequest * _Nullable request);
/** 请求失败的Block */
typedef void (^ZBRequestFailureBlock)(NSError * _Nullable error);
/** 请求进度的Block */
typedef void (^ZBRequestProgressBlock)(NSProgress * _Nullable progress);
/** 请求完成的Block 无论成功和失败**/
typedef void (^ZBRequestFinishedBlock)(id _Nullable responseObject,NSError * _Nullable error,ZBURLRequest * _Nullable request);
//==================================================
/** 批量请求配置的Block */
typedef void (^ZBBatchRequestConfigBlock)(ZBBatchRequest * _Nonnull batchRequest);
/** 批量请求 全部完成的Block 无论成功和失败*/
typedef void (^ZBBatchRequestFinishedBlock)(NSArray * _Nullable responseObjects,NSArray<NSError *> * _Nullable errors,NSArray<ZBURLRequest *> *_Nullable requests);
//==================================================
/** 请求 处理逻辑的方法 Block */
typedef void (^ZBRequestProcessBlock)(ZBURLRequest * _Nullable request,id _Nullable __autoreleasing * _Nullable setObject);
/** 响应 处理逻辑的方法 Block */
typedef id _Nullable (^ZBResponseProcessBlock)(ZBURLRequest * _Nullable request, id _Nullable responseObject, NSError * _Nullable __autoreleasing * _Nullable error);
/** 错误 处理逻辑的方法 Block */
typedef void (^ZBErrorProcessBlock)(ZBURLRequest * _Nullable request, NSError * _Nullable error);
//==================================================
/** Request协议*/
@protocol ZBURLRequestDelegate <NSObject>
@required
/** 请求成功的 代理方法*/
- (void)requestSuccess:(ZBURLRequest *_Nullable)request responseObject:(id _Nullable)responseObject ;
@optional
/** 请求失败的 代理方法*/
- (void)requestFailed:(ZBURLRequest *_Nullable)request error:(NSError *_Nullable)error;
/** 请求进度的 代理方法*/
- (void)requestProgress:(NSProgress * _Nullable)progress;
/** 请求完成的 代理方法 无论成功和失败**/
- (void)requestFinished:(ZBURLRequest *_Nullable)request responseObject:(id _Nullable)responseObject error:(NSError *_Nullable)error;
/** 批量请求 全部完成的 代理方法，无论成功和失败*/
- (void)requestBatchFinished:(NSArray<ZBURLRequest *> *_Nullable)requests responseObjects:(NSArray * _Nullable) responseObjects errors:(NSArray<NSError *> * _Nullable)errors;
@end

#endif /* ZBRequestConst_h */
