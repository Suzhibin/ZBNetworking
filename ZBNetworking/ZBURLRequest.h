//
//  ZBURLRequest.h
//  ZBNetworking
//
//  Created by NQ UEC on 16/12/20.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBRequestConst.h"
@class ZBUploadData;
@interface ZBURLRequest : NSObject
NS_ASSUME_NONNULL_BEGIN

#pragma mark - 配置请求
/**
 *  用于标识不同类型的request状态   默认为ZBRequestTypeRefresh 不读取缓存，不存储缓存
 */
@property (nonatomic,assign) ZBApiType apiType;

/**
 *  用于标识不同的请求类型
 *  默认请求类型为 GET请求
 *  可在公共配置  setupBaseConfig方法内   更改默认请求类型config.methodType=
 */
@property (nonatomic,assign) ZBMethodType methodType;

/**
 *  下载请求操作状态
 */
@property (nonatomic,assign) ZBDownloadState  downloadState;

/**
 *  请求参数的类型
 *  单次请求设置 请求格式 默认JSON，优先级大于 公共配置，不影响其他请求设置
 */
@property (nonatomic,assign) ZBRequestSerializerType requestSerializer;

/**
 *  响应数据的类型
 *  单次请求设置 响应格式 默认JSON，优先级大于 公共配置，不影响其他请求设置
 */
@property (nonatomic,assign) ZBResponseSerializerType responseSerializer;

/**
 * 请求的服务器地址，例如。"https://github.com/Suzhibin/"，默认为nil。
 * server 优先级大于公共配置 baseServer
 */
@property (nonatomic,copy) NSString *server;

/**
 请求的接口路径，例如。"ZBNetworking/issues"，默认为nil。
 */
@property (nonatomic,copy) NSString *path;

/**
 *  请求的最终URL，由' server '和' path '属性组合而成 例如："https://github.com/Suzhibin/ZBNetworking/issues"  默认为' nil
 *  注意:当你手动设置' url '的值时，' server '和' api '属性将被忽略。
 */
@property (nonatomic,copy) NSString *url;

/**
 *  配置参数
 *  如果是字典类型与公共配置 Parameters 兼容，如果是其他类型（字符串，数组等）与公共配置 Parameters不兼容，会自动屏蔽公共参数
 */
@property (nonatomic,strong,nullable) id parameters;

/**
 *  添加请求头
 *  与公共配置 Headers 兼容
 */
@property (nonatomic,strong,nullable) NSMutableDictionary *headers;

/**
 *  过滤parameters 里的随机参数
 *  与公共配置 filtrationCacheKey 兼容
 */
@property (nonatomic,strong,nullable) NSArray *filtrationCacheKey;

/*
*  设置超时时间
*  优先级 高于 公共配置,不影响其他请求设置
*/
@property (nonatomic,assign) NSTimeInterval timeoutInterval;

/**
 *  请求失败,设置自动重试 请求次数 默认是0.
 *  单次请求 重新连接次数 优先级大于 全局设置，不影响其他请求设置
 *  重试请求不会调用预处理插件setResponseProcessHandler，会调用失败插件setErrorProcessHandler，可在失败插件内重新配置请求对象
 */
@property (nonatomic,assign) NSUInteger retryCount;

/**
 *  当前请求的信息，可以用来区分具有相同上下文的请求，不会传给服务器，
 */
@property (nonatomic,strong,nullable) NSDictionary *userInfo;

/**
 *  是否使用 公共配置的 服务器 默认YES
 */
@property (nonatomic,assign) BOOL isBaseServer;

/**
 *  是否使用 公共配置的 参数 默认YES
 */
@property (nonatomic,assign) BOOL isBaseParameters;

/**
 *  是否使用 公共配置的  请求头 默认YES
 */
@property (nonatomic,assign) BOOL isBaseHeaders;

#pragma mark - 获取信息
/**
 *  NSURLSessionTask对象
 *  不需主动赋值，会自动分配
 */
@property (nonatomic,strong) NSURLSessionTask *_Nullable  task;

/**
 *  ZBURLRequest对象唯一标识符
 *  不需主动赋值，会自动分配
 */
@property (nonatomic,assign) NSUInteger identifier;

/**
 *  缓存key  读取缓存 返回
 */
@property (nonatomic,copy,readonly) NSString *cacheKey;

/**
 *  缓存路径文件 读取沙盒缓存返回，内存缓存无路径
 */
@property (nonatomic,copy,readonly) NSString *filePath;

/**
 *  是否使用了缓存 只有得到响应数据时 才是准确的
 */
@property (nonatomic,assign,readonly) BOOL isCache;

/**
 *  获取 服务器响应信息
 */
@property (nullable, copy,readonly) NSURLResponse *response;

#pragma mark - 内部调用
@property (nonatomic,assign) BOOL consoleLog;
@property (nonatomic,assign) BOOL isRequestSerializer;
@property (nonatomic,assign) BOOL isResponseSerializer;
@property (nonatomic,assign) BOOL isMethodType;
/**
 *  为上传请求提供数据
 */
@property (nonatomic,strong,nullable) NSMutableArray<ZBUploadData *> *uploadDatas;
#if TARGET_OS_IPHONE
@property (nonatomic, weak, readonly, nullable) id<ZBURLRequestDelegate> delegate;
#elif TARGET_OS_MAC
@property (nonatomic, assign, readonly, nullable) id<ZBURLRequestDelegate> delegate;
#endif
@property (nonatomic, copy, readonly, nullable) ZBRequestSuccessBlock successBlock;

@property (nonatomic, copy, readonly, nullable) ZBRequestFailureBlock failureBlock;

@property (nonatomic, copy, readonly, nullable) ZBRequestFinishedBlock finishedBlock;

@property (nonatomic, copy, readonly, nullable) ZBRequestProgressBlock progressBlock;

- (void)cleanAllCallback;

#pragma mark - 上传请求参数
//============================================================
- (void)addFormDataWithName:(NSString *)name fileData:(NSData *)fileData;
- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData;
- (void)addFormDataWithName:(NSString *)name fileURL:(NSURL *)fileURL;
- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL;
@end

#pragma mark - ZBBatchRequest

@interface ZBBatchRequest : NSObject

/**
 *  请求url 列队容器
 */
@property (nonatomic, strong , nullable) NSMutableArray<ZBURLRequest *> * requestArray;

/**
 *  响应内容 列队容器 （成功回调返回）
 */
@property (nonatomic, strong , readonly) NSMutableArray<id> *responseArray;

- (void)onFinishedRequest:(ZBURLRequest*)request response:(id)responseObject error:(NSError *)error finished:(ZBBatchRequestFinishedBlock _Nullable )finished;

@end

#pragma mark - ZBUploadData
/**
 *  上传文件数据的类
 */
@interface ZBUploadData : NSObject

/**
 *  文件对应服务器上的字段
 */
@property (nonatomic, copy) NSString *name;

/**
 *  文件名
 */
@property (nonatomic, copy, nullable) NSString *fileName;

/**
 *  图片文件的类型,例:png、jpeg....
 */
@property (nonatomic, copy, nullable) NSString *mimeType;

/**
 *  The data to be encoded and appended to the form data, and it is prior than `fileURL`.
 */
@property (nonatomic, strong, nullable) NSData *fileData;

/**
 *  The URL corresponding to the file whose content will be appended to the form, BUT, when the `fileData` is assigned，the `fileURL` will be ignored.
 */
@property (nonatomic, strong, nullable) NSURL *fileURL;

//注意:“fileData”和“fileURL”中的任何一个都不应该是“nil”，“fileName”和“mimeType”都必须是“nil”，或者同时被分配，

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData;
+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData;
+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL;
+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL;

@end

@interface ZBConfig : NSObject

/**
 *  基础URL 域名
 *  请求不单独设置域名server 时，默认会使用baseServer。
*/
@property (nonatomic, copy, nullable) NSString *baseServer;

/**
 *  公共参数
 *  请求正常情况都会携带此公共参数，但当请求的传参为数组或字符串 不会携带该参数
*/
@property (nonatomic, strong, nullable) NSDictionary *parameters;

/**
 *  公共请求头
 *  与单次请求配置 Headers 兼容
*/
@property (nonatomic, strong, nullable) NSDictionary *headers;

/**
 *  公共请求的信息，可以用来本地注释和判断使用，不会传给服务器，
*/
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

/**
 *  所有请求过滤parameters 里的随机参数
 *  与单次请求配置 filtrationCacheKey 兼容
 */
@property (nonatomic, strong, nullable) NSArray *filtrationCacheKey;
/**
 *  所有请求的超时时间
 *  优先级 小于 单次请求的设置
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  是否开启打印控制台log
 */
@property (nonatomic, assign) BOOL consoleLog;

/**
 *  所有请求参数的类型
 *  全局设置 请求格式 默认JSON
 *  优先级 小于 单次请求的设置
 */
@property (nonatomic, assign) ZBRequestSerializerType requestSerializer;

/**
 *  所有响应数据的类型
 *  全局设置 响应格式 默认JSON
 *  优先级 小于 单次请求的设置
 */
@property (nonatomic, assign) ZBResponseSerializerType responseSerializer;

/**
 *  全局设置 所有请求的 默认请求类型
 *  优先级 小于 单次请求的设置
 *  如果服务器给的接口大多不是get 请求，可以在此更改默认请求类型。单次默认类型的请求，就不用在标明请求类型了。
 */
@property (nonatomic, assign) ZBMethodType defaultMethodType;

/**
 *  所有请求失败,设置自动重试 请求次数 默认是0.
 *  优先级 小于 单次请求的设置
 */
@property (nonatomic, assign) NSUInteger retryCount;

/**
 *  添加响应数据 内容类型
 */
@property (nonatomic, strong, nullable)NSArray *responseContentTypes;

/**
 HTTPMethodsEncodingParametersInURI，用于调整 不同请求类型的参数是否拼接url后 还是峰封装在request body内
 调用请求方法时，AFN会将参数以query string格式拼接到URL后面，默认除了GET，HEAD 和 DELETE 之外的请求方法的参数都将封装在request body内
 */
@property (nonatomic,strong,nullable) NSSet *HTTPMethodsEncodingParametersInURI;

//===========内部调用===============
@property (nonatomic, assign) BOOL isRequestSerializer;
@property (nonatomic, assign) BOOL isResponseSerializer;
@property (nonatomic, assign) BOOL isDefaultMethodType;
NS_ASSUME_NONNULL_END
@end

