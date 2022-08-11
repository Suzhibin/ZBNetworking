//
//  ZBURLRequest.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/12/20.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "ZBURLRequest.h"
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
    _retryCount=0;
    _identifier = 0;
    
    _isBaseServer=YES;
    _isBaseParameters=YES;
    _isBaseHeaders=YES;
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

- (void)setMethodType:(ZBMethodType)methodType{
    _methodType=methodType;
    _isMethodType=YES;
}

- (void)cleanAllCallback{
    _successBlock = nil;
    _failureBlock = nil;
    _finishedBlock = nil;
    _progressBlock = nil;
    _delegate=nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    //  NSLog(@"undefinedKey:%@",key);
}

- (void)dealloc{
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
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
    NSUInteger _batchRequestCount;
    BOOL _failed;
}
@end

@implementation ZBBatchRequest
- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _batchRequestCount = 0;
    _requestArray = [NSMutableArray array];
    _responseArray = [NSMutableArray array];
    return self;
}
- (void)onFinishedRequest:(ZBURLRequest*)request response:(id)responseObject error:(NSError *)error finished:(ZBBatchRequestFinishedBlock _Nullable )finished{
    NSUInteger index = [_requestArray indexOfObject:request];
    if (responseObject) {
         [_responseArray replaceObjectAtIndex:index withObject:responseObject];
    }else{
         _failed = YES;
         if (error) {
             [_responseArray replaceObjectAtIndex:index withObject:error];
         }
    }
    _batchRequestCount++;
    if (_batchRequestCount == _requestArray.count) {
        if (!_failed) {
            if (request.delegate&&[request.delegate respondsToSelector:@selector(requestBatchFinished:responseObjects:errors:)]) {
                [request.delegate requestBatchFinished:_requestArray responseObjects:_responseArray errors:nil];
            }
            if (finished) {
                finished(_responseArray,nil,_requestArray);
            }
        }else{
            if (request.delegate&&[request.delegate respondsToSelector:@selector(requestBatchFinished:responseObjects:errors:)]) {
                [request.delegate requestBatchFinished:_requestArray responseObjects:nil errors:_responseArray];
            }
            if (finished) {
                finished(nil,_responseArray,_requestArray);
            }
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
- (void)setRequestSerializer:(ZBRequestSerializerType)requestSerializer{
    _requestSerializer=requestSerializer;
    _isRequestSerializer=YES;
}

- (void)setResponseSerializer:(ZBResponseSerializerType)responseSerializer{
    _responseSerializer=responseSerializer;
    _isResponseSerializer=YES;
}

- (void)setDefaultMethodType:(ZBMethodType)defaultMethodType{
    _defaultMethodType=defaultMethodType;
    _isDefaultMethodType=YES;
}
@end
