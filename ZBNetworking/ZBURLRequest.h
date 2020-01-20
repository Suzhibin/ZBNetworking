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
/**
 *  用于标识不同类型的request状态
 */
@property (nonatomic,assign) ZBApiType apiType;

/**
 *  用于标识不同类型的request
 */
@property (nonatomic,assign) ZBMethodType methodType;

/**
 *   多次请求一个URL 保留第一次或最后一次请求结果 只在请求时有用  读取缓存无效果
 */
@property (nonatomic,assign) ZBResponseKeepType keepType;

/**
 *  请求参数的类型   baseRequestSerializer 设置有用
 */
@property (nonatomic,assign) ZBRequestSerializerType requestSerializer;

/**
 *  响应数据的类型
 */
@property (nonatomic,assign) ZBResponseSerializerType responseSerializer;

/**
 *  接口(请求地址)
 */
@property (nonatomic,copy) NSString * URLString;

/**
 *  提供给外部配置参数使用
 */
@property (nonatomic,strong,nullable) NSDictionary * parameters;

/**
 *  添加请求头
 */
@property (nonatomic,strong,nullable) NSDictionary * headers;

/**
 *  过滤parameters 里的随机参数
 */
@property (nonatomic,strong,nullable) NSArray *filtrationCacheKey;

/**
 *  设置超时时间  默认30秒
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
  请求失败,设置自动重试 请求次数 默认是0.
 */
@property (nonatomic, assign) NSUInteger retryCount;

/**
  当前请求的信息，可以用来区分具有相同上下文的请求
*/
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

/**
 *  存储路径 只有下载文件方法有用
 */
@property (nonatomic,copy,nullable) NSString *downloadSavePath;

/**
 *  为上传请求提供数据
 */
@property (nonatomic,strong,nullable) NSMutableArray<ZBUploadData *> *uploadDatas;

/**
 *  是否使用了缓存
 */
@property (nonatomic,assign,readonly) BOOL isCache;

@property (nonatomic,assign) BOOL consoleLog;
@property (nonatomic,assign) BOOL isRequestSerializer;
@property (nonatomic,assign) BOOL isResponseSerializer;

@property (nonatomic, copy, readonly, nullable) ZBRequestSuccessBlock successBlock;

@property (nonatomic, copy, readonly, nullable) ZBRequestFailureBlock failureBlock;

@property (nonatomic, copy, readonly, nullable) ZBRequestFinishedBlock finishedBlock;

@property (nonatomic, copy, readonly, nullable) ZBRequestProgressBlock progressBlock;

- (void)cleanAllBlocks;

//============================================================
- (void)addFormDataWithName:(NSString *)name fileData:(NSData *)fileData;
- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData;
- (void)addFormDataWithName:(NSString *)name fileURL:(NSURL *)fileURL;
- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL;
@end

#pragma mark - ZBBatchRequest

@interface ZBBatchRequest : NSObject

/**
 请求url列队容器
 */
@property (nonatomic, strong , nullable) NSMutableArray<ZBURLRequest *> * requestArray;

@property (nonatomic, strong , readonly) NSMutableArray<id> *responseArray;

- (void)requestFinishedResponse:(id)responseObject error:(NSError *)error finished:(ZBBatchRequestFinishedBlock _Nullable )finished;
@end

#pragma mark - ZBUploadData
/**
 上传文件数据的类
 */
@interface ZBUploadData : NSObject

/**
 文件对应服务器上的字段
 */
@property (nonatomic, copy) NSString * name;

/**
 文件名
 */
@property (nonatomic, copy, nullable) NSString *fileName;

/**
 图片文件的类型,例:png、jpeg....
 */
@property (nonatomic, copy, nullable) NSString *mimeType;

/**
 The data to be encoded and appended to the form data, and it is prior than `fileURL`.
 */
@property (nonatomic, strong, nullable) NSData *fileData;

/**
 The URL corresponding to the file whose content will be appended to the form, BUT, when the `fileData` is assigned，the `fileURL` will be ignored.
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
 *   基础URL 域名
*/
@property (nonatomic, copy, nullable) NSString *baseURL;
/**
 *   参数
*/
@property (nonatomic, strong, nullable) NSDictionary *baseParameters;
/**
 *   请求头
*/
@property (nonatomic, strong, nullable) NSDictionary *baseHeaders;

/**
 *   请求的信息，可以用来注释和判断使用
*/
@property (nonatomic, strong, nullable) NSDictionary *baseUserInfo;
/**
 *  过滤parameters 里的随机参数
 */
@property (nonatomic, strong, nullable) NSArray *baseFiltrationCacheKey;
/**
*  超时时间
*/
@property (nonatomic, assign) NSTimeInterval baseTimeoutInterval;
/**
 是否开启打印控制台log
 */
@property (nonatomic, assign)BOOL consoleLog;

/**
 *  请求参数的类型
 */
@property (nonatomic,assign) ZBRequestSerializerType baseRequestSerializer;

/**
 *  响应数据的类型
 */
@property (nonatomic,assign) ZBResponseSerializerType baseResponseSerializer;

/**
  请求失败,设置自动重试 请求次数 默认是0.
 */
@property (nonatomic, assign) NSUInteger baseRetryCount;

@property (nonatomic,assign) BOOL isRequestSerializer;
@property (nonatomic,assign) BOOL isResponseSerializer;
NS_ASSUME_NONNULL_END
@end

