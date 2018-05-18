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
@property (nonatomic,assign) requestSerializerType requestSerializerType;

/**
 *  接口(请求地址)
 */
@property (nonatomic,copy) NSString * _Nonnull URLString;

/**
 *  提供给外部配置参数使用
 */
@property (nonatomic,strong) id __nullable parameters;

/**
 过滤parameters 里的随机参数
 */
@property (nonatomic,strong) NSArray *parametersfiltrationCacheKey;

/**
 *  设置超时时间  默认15秒
 *   The timeout interval, in seconds, for created requests. The default timeout interval is 15 seconds.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  存储路径 只有下载文件方法有用
 */
@property (nonatomic,copy,nullable) NSString *downloadSavePath;

/**
 *  为上传请求提供数据
 */
@property (nonatomic, strong, nullable) NSMutableArray<ZBUploadData *> *uploadDatas;

/**
 *  用于维护 请求头的request对象
 */
@property ( nonatomic, strong) NSMutableDictionary * _Nonnull mutableHTTPRequestHeaders;

/**
 *  添加请求头
 *
 *  @param value value
 *  @param field field
 */
- (void)setValue:(NSString *_Nonnull)value forHeaderField:(NSString *_Nonnull)field;

/**
 *
 *  @param key request 对象
 *
 *  @return request 对象
 */
- (NSString *_Nonnull)objectHeaderForKey:(NSString *_Nonnull)key;

/**
 *  删除请求头的key
 *
 *  @param key key
 */
- (void)removeHeaderForkey:(NSString *_Nonnull)key;

//============================================================
- (void)addFormDataWithName:(NSString *_Nonnull)name fileData:(NSData *_Nonnull)fileData;
- (void)addFormDataWithName:(NSString *_Nonnull)name fileName:(NSString *_Nonnull)fileName mimeType:(NSString *_Nonnull)mimeType fileData:(NSData *_Nonnull)fileData;
- (void)addFormDataWithName:(NSString *_Nonnull)name fileURL:(NSURL *_Nonnull)fileURL;
- (void)addFormDataWithName:(NSString *_Nonnull)name fileName:(NSString *_Nonnull)fileName mimeType:(NSString *_Nonnull)mimeType fileURL:(NSURL *_Nonnull)fileURL;
@end

#pragma mark - ZBBatchRequest

@interface ZBBatchRequest : NSObject

/**
 请求url列队容器
 */
@property (nonatomic,strong) NSMutableArray * _Nullable urlArray;

/**
 *  @return urlArray 返回url数组
 */
- (NSMutableArray *_Nonnull)batchUrlArray;

/**
 *  @return urlArray 返回其他参数数组
 */
- (NSMutableArray *_Nonnull)batchKeyArray;

/**
 离线下载 将url 添加到请求列队
 
 @param urlString 请求地址
 */
- (void)addObjectWithUrl:(NSString *_Nonnull)urlString;

/**
 离线下载 将url 从请求列队删除
 
 @param urlString 请求地址
 */
- (void)removeObjectWithUrl:(NSString *_Nonnull)urlString;

/**
 离线下载 将栏目其他参数  添加到容器
 
 @param name 栏目名字 或 其他 key
 */
- (void)addObjectWithKey:(NSString *_Nonnull)name;

/**
 离线下载 将栏目其他参数 从容器删除
 
 @param name 请求地址 或 其他 key
 */
- (void)removeObjectWithKey:(NSString *_Nonnull)name;

/**
 离线下载 删除全部请求列队
 */
- (void)removeBatchArray;

/**
 离线下载 判断栏目url 或 其他参数 是否已添加到请求容器
 
 @param key   请求地址 或 其他参数
 @param isUrl 是否是url
 
 @return 1:0
 */
- (BOOL)isAddForKey:(NSString *_Nonnull)key isUrl:(BOOL)isUrl;

/**
 离线下载 将url 或 其他参数 添加到请求列队
 
 @param key   请求地址 或 其他参数
 @param isUrl 是否是url
 */
- (void)addObjectWithForKey:(NSString *_Nonnull)key isUrl:(BOOL)isUrl;

/**
 离线下载 将url 或 其他参数 从请求列队删除
 
 @param key   请求地址 或 其他参数
 @param isUrl 是否是url
 */
- (void)removeObjectWithForkey:(NSString *_Nonnull)key isUrl:(BOOL)isUrl;

/**
 批量取消请求

 @param completion block 后续操作
 */
- (void)cancelbatchRequestWithCompletion:(cancelCompletedBlock _Nullable )completion;

@end

#pragma mark - ZBUploadData
/**
 上传文件数据的类
 */
@interface ZBUploadData : NSObject

/**
 文件对应服务器上的字段
 */
@property (nonatomic, copy) NSString * _Nonnull name;

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

+ (instancetype _Nonnull )formDataWithName:(NSString *_Nonnull)name fileData:(NSData *_Nonnull)fileData;
+ (instancetype _Nonnull )formDataWithName:(NSString *_Nonnull)name fileName:(NSString *_Nonnull)fileName mimeType:(NSString *_Nonnull)mimeType fileData:(NSData *_Nonnull)fileData;
+ (instancetype _Nonnull )formDataWithName:(NSString *_Nonnull)name fileURL:(NSURL *_Nonnull)fileURL;
+ (instancetype _Nonnull )formDataWithName:(NSString *_Nonnull)name fileName:(NSString *_Nonnull)fileName mimeType:(NSString *_Nonnull)mimeType fileURL:(NSURL *_Nonnull)fileURL;


@end

