//
//  ZBRequestEngine.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import "ZBRequestEngine.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "NSFileManager+ZBPathMethod.h"
#import "ZBURLRequest.h"

@implementation ZBRequestEngine

+ (instancetype)defaultEngine{
    static ZBRequestEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZBRequestEngine alloc]init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //无条件地信任服务器端返回的证书。
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        self.securityPolicy = [AFSecurityPolicy defaultPolicy];
        self.securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy.validatesDomainName = NO;
        /*因为与缓存互通 服务器返回的数据 必须是二进制*/
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript",nil];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
    }
    return self;
}

- (void)dealloc {
    [self invalidateSessionCancelingTasks:YES];
}

#pragma mark - GET/POST/PUT/PATCH/DELETE
- (NSURLSessionDataTask *)dataTaskWithMethod:(ZBURLRequest *)request
                             zb_progress:(void (^)(NSProgress * _Nonnull))zb_progress
                              success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    
    [self requestSerializerConfig:request];
    [self headersAndTimeConfig:request];
    
    NSString *URLString=[NSString zb_stringUTF8Encoding:request.URLString];
    
    if (request.methodType==ZBMethodTypePOST) {
        return [self POST:URLString parameters:request.parameters progress:zb_progress success:success failure:failure];
    }else if (request.methodType==ZBMethodTypePUT){
        return [self PUT:URLString parameters:request.parameters success:success failure:failure];
    }else if (request.methodType==ZBMethodTypePATCH){
        return [self PATCH:URLString parameters:request.parameters success:success failure:failure];
    }else if (request.methodType==ZBMethodTypeDELETE){
        return [self DELETE:URLString parameters:request.parameters success:success failure:failure];
    }else{
        return [self GET:URLString parameters:request.parameters progress:zb_progress success:success failure:failure];
    }
}

#pragma mark - upload
- (NSURLSessionDataTask *)uploadWithRequest:(ZBURLRequest *)request
                                zb_progress:(void (^)(NSProgress * _Nonnull))zb_progress
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    
   NSURLSessionDataTask *uploadTask = [self POST:[NSString zb_stringUTF8Encoding:request.URLString] parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [request.uploadDatas enumerateObjectsUsingBlock:^(ZBUploadData *obj, NSUInteger idx, BOOL *stop) {
            if (obj.fileData) {
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileData:obj.fileData name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
                } else {
                    [formData appendPartWithFormData:obj.fileData name:obj.name];
                }
            } else if (obj.fileURL) {
                
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name fileName:obj.fileName mimeType:obj.mimeType error:nil];
                } else {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name error:nil];
                }
                
            }
        }];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            zb_progress ? zb_progress(uploadProgress) : nil;
        });
    } success:success failure:failure];
    return uploadTask;
}

#pragma mark - DownLoad
- (NSURLSessionDownloadTask *)downloadWithRequest:(ZBURLRequest *)request
                                             progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString zb_stringUTF8Encoding:request.URLString]]];
    
    [self headersAndTimeConfig:request];
    
    NSURL *downloadFileSavePath;
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:request.downloadSavePath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    if (isDirectory) {
        NSString *fileName = [urlRequest.URL lastPathComponent];
        downloadFileSavePath = [NSURL fileURLWithPath:[NSString pathWithComponents:@[request.downloadSavePath, fileName]] isDirectory:NO];
    } else {
        downloadFileSavePath = [NSURL fileURLWithPath:request.downloadSavePath isDirectory:NO];
    }
    NSURLSessionDownloadTask *dataTask = [self downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            downloadProgressBlock ? downloadProgressBlock(downloadProgress) : nil;
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return downloadFileSavePath;
    } completionHandler:completionHandler];
    
    [dataTask resume];
    return dataTask;
}

#pragma mark - 其他配置
- (void)requestSerializerConfig:(ZBURLRequest *)request{
    self.requestSerializer =request.requestSerializerType==ZBHTTPRequestSerializer ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

- (void)headersAndTimeConfig:(ZBURLRequest *)request{
    self.requestSerializer.timeoutInterval=request.timeoutInterval?request.timeoutInterval:30;
    
    if ([[request mutableHTTPRequestHeaders] allKeys].count>0) {
        [[request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [self.requestSerializer setValue:value forHTTPHeaderField:field];
        }];
    }
}

#pragma mark - 取消请求
- (void)cancelRequest:(NSString *)URLString completion:(cancelCompletedBlock)completion{
    if (self.tasks.count <= 0) {
        return;
    }
    __block NSString *currentUrlString=nil;
    BOOL results;
    @synchronized (self.tasks) {
        [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[[task.currentRequest URL] absoluteString] isEqualToString:[NSString zb_stringUTF8Encoding:URLString]]) {
                currentUrlString =[[task.currentRequest URL] absoluteString];
                [task cancel];
                *stop = YES;
            }
        }];
    }
    if (currentUrlString==nil) {
        results=NO;
    }else{
        results=YES;
    }
    completion ? completion(results,currentUrlString) : nil;
}
@end
