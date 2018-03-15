//
//  ZBRequestEngine.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import "ZBRequestEngine.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "ZBCacheManager.h"
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
        
        self.operationQueue.maxConcurrentOperationCount = 5;
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript",nil];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

- (void)dealloc {
    [self invalidateSessionCancelingTasks:YES];
}

- (void)sendRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    if (request.methodType==ZBMethodTypePOST) {
        
        [self postRequest:request progress:progress success:success failed:failed];
    }else if (request.methodType==ZBMethodTypeUpload){
        
        [self uploadWithRequest:request progress:progress success:success failed:failed];
    }else if (request.methodType==ZBMethodTypeDownLoad){
        
        [self downloadWithRequest:request progress:progress success:success failed:failed];
    }else{
        
        [self getRequest:request progress:progress success:success failed:failed];
    }
}

#pragma mark - GET
- (void)getRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    NSString * key = [self keyWithParameters:request];
    if ([[ZBCacheManager sharedInstance]diskCacheExistsWithKey:key]&&request.apiType!=ZBRequestTypeRefresh&&request.apiType!=ZBRequestTypeRefreshMore){
        
        [[ZBCacheManager sharedInstance]getCacheDataForKey:key value:^(NSData *data,NSString *filePath) {
            success ? success(data ,request.apiType) : nil;
        }];
        
    }else{
        [self dataTaskWithGetRequest:request progress:progress success:success failed:failed];
    }
}

- (NSURLSessionDataTask *)dataTaskWithGetRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    [self requestSerializerConfig:request];
    [self headersAndTimeConfig:request];
    
    return [self dataTaskWithGetURL:request.urlString parameters:request.parameters  progress:progress success:^(id responseObject, apiType type) {
        
        [self storeObject:responseObject request:request];
        
        success ? success(responseObject,request.apiType) : nil;
    } failed:failed];
}

- (NSURLSessionDataTask *)dataTaskWithGetURL:(NSString *)urlString parameters:(id)parameters  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    if([urlString isEqualToString:@""]||urlString==nil)return nil;
    
    return [self GET:[NSString zb_stringUTF8Encoding:urlString] parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
        progress ? progress(downloadProgress) : nil;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        success ? success(responseObject,0) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed ? failed(error) : nil;
    }];
}

#pragma mark - POST
- (void)postRequest:(ZBURLRequest *)request  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    NSString * key = [self keyWithParameters:request];
    if ([[ZBCacheManager sharedInstance]diskCacheExistsWithKey:key]&&request.apiType!=ZBRequestTypeRefresh&&request.apiType!=ZBRequestTypeRefreshMore){
        
        [[ZBCacheManager sharedInstance]getCacheDataForKey:key value:^(NSData *data,NSString *filePath) {
            success ? success(data ,request.apiType) : nil;
        }];
        
    }else{
        [self dataTaskWithPostRequest:request apiType:request.apiType progress:progress success:success failed:failed];
    }
}

- (NSURLSessionDataTask *)dataTaskWithPostRequest:(ZBURLRequest *)request apiType:(apiType)type progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    [self requestSerializerConfig:request];
    [self headersAndTimeConfig:request];
    
    return [self dataTaskWithPostURL:request.urlString parameters:request.parameters  progress:progress success:^(id responseObject, apiType type) {
        
        [self storeObject:responseObject request:request];
        
        success ? success(responseObject,request.apiType) : nil;
    } failed:failed];
}

- (NSURLSessionDataTask *)dataTaskWithPostURL:(NSString *)urlString parameters:(id)parameters  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    if([urlString isEqualToString:@""]||urlString==nil)return nil;
    
    return [self POST:[NSString zb_stringUTF8Encoding:urlString] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress ? progress(uploadProgress) : nil;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success ? success(responseObject,0) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed ? failed(error) : nil;
    }];
}

#pragma mark - upload
- (NSURLSessionTask *)uploadWithRequest:(ZBURLRequest *)request
                               progress:(progressBlock)progress
                                success:(requestSuccess)success
                                 failed:(requestFailed)failed{
    
    return [self POST:[NSString zb_stringUTF8Encoding:request.urlString] parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
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
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success ? success(responseObject,0) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        failed ? failed(error) : nil;
        
    }];
}

#pragma mark - DownLoad
- (NSURLSessionTask *)downloadWithRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString zb_stringUTF8Encoding:request.urlString]]];
    
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
            progress ? progress(downloadProgress) : nil;
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return downloadFileSavePath;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        failed ? failed(error) : nil;
        success ? success([filePath path],request.apiType) : nil;
    }];
    
    [dataTask resume];
    return dataTask;
}

#pragma mark - 其他配置
- (NSString *)keyWithParameters:(ZBURLRequest *)request{
    return [NSString zb_stringUTF8Encoding:[NSString zb_urlString:request.urlString appendingParameters:request.parameters]];
}

- (void)storeObject:(NSObject *)object request:(ZBURLRequest *)request{
    NSString * key = [self keyWithParameters:request];
    [[ZBCacheManager sharedInstance] storeContent:object forKey:key isSuccess:nil];
}

- (void)requestSerializerConfig:(ZBURLRequest *)request{
    self.requestSerializer =request.requestSerializerType==ZBHTTPRequestSerializer ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

- (void)headersAndTimeConfig:(ZBURLRequest *)request{
    self.requestSerializer.timeoutInterval=request.timeoutInterval?request.timeoutInterval:15;
    
    if ([[request mutableHTTPRequestHeaders] allKeys].count>0) {
        [[request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [self.requestSerializer setValue:value forHTTPHeaderField:field];
        }];
    }
}

- (void)cancelRequest:(NSString *)urlString completion:(cancelCompletedBlock)completion{
    if (self.tasks.count <= 0) {
        return;
    }
    __block NSString *currentUrlString=nil;
     BOOL results;
    @synchronized (self.tasks) {
        [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[[task.currentRequest URL] absoluteString] isEqualToString:[NSString zb_stringUTF8Encoding:urlString]]) {
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
