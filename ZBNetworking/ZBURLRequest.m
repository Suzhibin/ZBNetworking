//
//  ZBURLRequest.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/12/20.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "ZBURLRequest.h"
#import "ZBRequestManager.h"

@implementation ZBURLRequest
- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _requestSerializer=ZBJSONRequestSerializer;
    _responseSerializer=ZBJSONResponseSerializer;
    _methodType=ZBMethodTypeGET;
    _apiType=ZBRequestTypeRefresh;
    return self;
}
- (void)setRequestSerializer:(ZBRequestSerializerType)requestSerializer{
    _requestSerializer=requestSerializer;
    _isRequestSerializer=YES;
}

- (void)setResponseSerializer:(ZBResponseSerializerType)responseSerializer{
    _responseSerializer=responseSerializer;
    _isResponseSerializer=YES;
}
- (void)resultIsUseCache:(BOOL)isCache{
    _isCache=isCache;
}
- (void)dealloc{
    //NSLog(@"%s",__func__);
}

#pragma mark - 上传请求参数
- (void)addFormDataWithName:(NSString *)name fileData:(NSData *)fileData {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileData:fileData];
    [self.uploadDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileName:fileName mimeType:mimeType fileData:fileData];
    [self.uploadDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileURL:fileURL];
    [self.uploadDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileName:fileName mimeType:mimeType fileURL:fileURL];
    [self.uploadDatas addObject:formData];
}

#pragma mark - 懒加载

- (NSMutableArray<ZBUploadData *> *)uploadDatas {
    if (!_uploadDatas) {
        _uploadDatas = [[NSMutableArray alloc]init];
    }
    return _uploadDatas;
}

@end

#pragma mark - ZBBatchRequest
@interface ZBBatchRequest () {
    NSUInteger _requestCount;
}
@end

@implementation ZBBatchRequest
- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _requestCount = 0;
    _requestArray = [NSMutableArray array];
    _responseArray = [NSMutableArray array];
    return self;
}
- (void)requestFinishedResponse:(id)responseObject error:(NSError *)error finished:(batchRequestFinished _Nullable )finished{
    if (error) {
        [_responseArray addObject:error];
    }else{
        [_responseArray addObject:responseObject];
    }
    _requestCount++;
    if (_requestCount == _requestArray.count) {
        if (finished) {
            finished(_responseArray);
        }
    }
}

@end

#pragma mark - ZBUploadData

@implementation ZBUploadData

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileURL = fileURL;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileURL = fileURL;
    return formData;
}
@end

#pragma mark - ZBConfig

@implementation ZBConfig
- (void)setBaseRequestSerializer:(ZBRequestSerializerType)baseRequestSerializer{
    _baseRequestSerializer=baseRequestSerializer;
    _isRequestSerializer=YES;
}
- (void)setBaseResponseSerializer:(ZBResponseSerializerType)baseResponseSerializer{
    _baseResponseSerializer=baseResponseSerializer;
    _isResponseSerializer=YES;
}
@end
