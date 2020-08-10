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
 *  用于标识不同类型的request状态
 */
@property (nonatomic,assign) ZBApiType apiType;

/**
 *  用于标识不同类型的request
 */
@property (nonatomic,assign) ZBMethodType methodType;

/**
 *  多次请求一个URL 保留第一次或最后一次请求结果 只在请求时有用  读取缓存无效果
 */
@property (nonatomic,assign) ZBResponseKeepType keepType;

/**
 *  请求参数的类型
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
 *  请求失败,设置自动重试 请求次数 默认是0.
 */
@property (nonatomic, assign) NSUInteger retryCount;

/**
 *  当前请求的信息，可以用来区分具有相同上下文的请求
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

#pragma mark - 获取信息

/**
 *  ZBURLRequest对象唯一标识符
 */
@property (nonatomic, assign) NSUInteger identifier;

/**
 *  缓存key  读取缓存 返回
 */
@property (nonatomic,copy,readonly) NSString * cacheKey;

/**
 *  缓存路径文件 读取沙盒缓存返回，内存缓存无
 */
@property (nonatomic,copy,readonly) NSString * filePath;

/**
 *  是否使用了缓存 只有得到响应数据时 才是准确的
 */
@property (nonatomic,assign,readonly) BOOL isCache;

/**
 *  获取 服务器响应信息
 */
@property (nullable, copy) NSURLResponse *response;

#pragma mark - 内部调用
@property (nonatomic,assign) BOOL consoleLog;
@property (nonatomic,assign) BOOL isRequestSerializer;
@property (nonatomic,assign) BOOL isResponseSerializer;

@property (nonatomic, weak, readonly, nullable) id<ZBURLRequestDelegate> delegate;

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
@property (nonatomic, copy) NSString * name;

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
*/
@property (nonatomic, copy, nullable) NSString *baseURL;

/**
 *  参数
*/
@property (nonatomic, strong, nullable) NSDictionary *parameters;

/**
 *  请求头
*/
@property (nonatomic, strong, nullable) NSDictionary *headers;

/**
 *  请求的信息，可以用来注释和判断使用
*/
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

/**
 *  过滤parameters 里的随机参数
 */
@property (nonatomic, strong, nullable) NSArray *filtrationCacheKey;
/**
 *  超时时间
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  是否开启打印控制台log
 */
@property (nonatomic, assign) BOOL consoleLog;

/**
 *  请求参数的类型
 */
@property (nonatomic, assign) ZBRequestSerializerType requestSerializer;

/**
 *  响应数据的类型
 */
@property (nonatomic, assign) ZBResponseSerializerType responseSerializer;

/**
 *  请求失败,设置自动重试 请求次数 默认是0.
 */
@property (nonatomic, assign) NSUInteger retryCount;

/**
 *  添加响应数据 内容类型
 */
@property (nonatomic, strong, nullable)NSArray *responseContentTypes;

//===========内部调用===============
@property (nonatomic, assign) BOOL isRequestSerializer;
@property (nonatomic, assign) BOOL isResponseSerializer;
NS_ASSUME_NONNULL_END
@end

