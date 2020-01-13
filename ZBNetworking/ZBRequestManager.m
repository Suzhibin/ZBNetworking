//
//  ZBRequestManager.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import "ZBRequestManager.h"
#import "ZBCacheManager.h"
#import "ZBURLRequest.h"
#import "NSString+ZBUTF8Encoding.h"

@implementation ZBRequestManager

#pragma mark - 配置请求
+ (void)setupBaseConfig:(void(^)(ZBConfig *config))block{
    [[ZBRequestEngine defaultEngine] setupBaseConfig:block];
}

+ (NSURLSessionTask *)requestWithConfig:(requestConfig)config success:(requestSuccess)success failure:(requestFailure)failure{
    return [self requestWithConfig:config progress:nil success:success failure:failure];
}

+ (NSURLSessionTask *)requestWithConfig:(requestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure {
    ZBURLRequest *request=[[ZBURLRequest alloc]init];
    config ? config(request) : nil;
    return [self sendRequest:request progress:progress success:success failure:failure finished:nil];
}

+ (void)sendBatchRequest:(batchRequestConfig)config success:(requestSuccess)success failure:(requestFailure)failure{
     [self sendBatchRequest:config progress:nil success:success failure:failure];
}

+ (void)sendBatchRequest:(batchRequestConfig)config success:(requestSuccess)success failure:(requestFailure)failure finished:(batchRequestFinished)finished{
    [self sendBatchRequest:config progress:nil success:success failure:failure finished:finished];
}

+ (void)sendBatchRequest:(batchRequestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure{
    [self sendBatchRequest:config progress:progress success:success failure:failure finished:nil];
}

+ (void)sendBatchRequest:(batchRequestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure finished:(batchRequestFinished)finished{
    ZBBatchRequest *batchRequest=[[ZBBatchRequest alloc]init];
    config ? config(batchRequest) : nil;
    if (batchRequest.requestArray.count==0)return;
    [batchRequest.requestArray enumerateObjectsUsingBlock:^(ZBURLRequest *request , NSUInteger idx, BOOL *stop) {
        [self sendRequest:request progress:progress success:success failure:failure finished:^(id responseObject, NSError *error) {
            [batchRequest requestFinishedResponse:responseObject error:error finished:finished];
        }];
    }];
}

#pragma mark - 发起请求
+ (NSURLSessionTask *)sendRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure finished:(requestFinished)finished{
    
    if([request.URLString isEqualToString:@""]||request.URLString==nil)return nil;
    
    [self configBaseWithRequest:request];
    
    if (request.methodType==ZBMethodTypeUpload) {
       return [self sendUploadRequest:request progress:progress success:success failure:failure finished:finished];
    }else if (request.methodType==ZBMethodTypeDownLoad){
       return [self sendDownLoadRequest:request progress:progress success:success failure:failure finished:finished];
    }else{
       return [self sendHTTPRequest:request progress:progress success:success failure:failure finished:finished];
    }
}

+ (NSURLSessionTask *)sendUploadRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure finished:(requestFinished)finished{
    return [[ZBRequestEngine defaultEngine] uploadWithRequest:request zb_progress:progress success:^(NSURLSessionDataTask *task, id responseObject) {
        [request resultIsUseCache:NO];
        success ? success(responseObject,request) : nil;
        finished ? finished (responseObject,nil) : nil;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure ? failure(error) : nil;
        finished ? finished (nil,error) : nil;
    }];
}

+ (NSURLSessionTask *)sendDownLoadRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure finished:(requestFinished)finished{
    return [[ZBRequestEngine defaultEngine] downloadWithRequest:request progress:progress completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [request resultIsUseCache:NO];
        failure ? failure(error) : nil;
        success ? success([filePath path],request) : nil;
        finished ? finished ([filePath path],error) : nil;
    }];
}

+ (NSURLSessionTask *)sendHTTPRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure finished:(requestFinished)finished{
    __block NSURLSessionTask *task = nil;
    NSString *key = [self keyWithParameters:request];
    if ([[ZBCacheManager sharedInstance]diskCacheExistsWithKey:key]&&request.apiType==ZBRequestTypeCache){
        [self getCacheDataForKey:key request:request success:success finished:finished];
        return task;
    }else{
        NSURLSessionTask  *originaltask= [[ZBRequestEngine defaultEngine]objectRequestForkey:request.URLString];
        if (request.keepType==ZBResponseKeepFirst&&originaltask) {
            return task;
        }
        if (request.keepType==ZBResponseKeepLast&&originaltask) {
            [originaltask cancel];
        }
        task = [self dataTaskWithHTTPRequest:request progress:progress success:success failure:failure finished:finished];
        [[ZBRequestEngine defaultEngine]setRequestObject:task forkey:request.URLString];
        return task;
    }
}

+ (NSURLSessionTask *)dataTaskWithHTTPRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure finished:(requestFinished)finished{
    NSURLSessionDataTask *dataTask= [[ZBRequestEngine defaultEngine]dataTaskWithMethod:request zb_progress:^(NSProgress * _Nonnull zb_progress) {
        progress ? progress(zb_progress) : nil;
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self successWithResponseObject:responseObject request:request success:success finished:finished];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self failureWithError:error request:request failure:failure finished:finished];
    }];
    return dataTask;
}

+ (void)cancelAllRequest{
    [[ZBRequestEngine defaultEngine]cancelAllRequest];
}

#pragma mark - 其他配置
+ (void)configBaseWithRequest:(ZBURLRequest *)request{
    [[ZBRequestEngine defaultEngine] configBaseWithRequest:request];
}

+ (NSString *)keyWithParameters:(ZBURLRequest *)request{
    NSDictionary *newParameters;
    if (request.filtrationCacheKey.count>0) {
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:request.parameters];
        [mutableParameters removeObjectsForKeys:request.filtrationCacheKey];
        newParameters = [mutableParameters copy];
    }else{
        newParameters = request.parameters;
    }

    return [NSString zb_stringUTF8Encoding:[NSString zb_urlString:request.URLString appendingParameters:newParameters]];
}

+ (void)storeObject:(NSObject *)object request:(ZBURLRequest *)request{
    NSString * key= [self keyWithParameters:request];
    [[ZBCacheManager sharedInstance] storeContent:object forKey:key isSuccess:nil];
}

+ (id)responsetSerializerConfig:(ZBURLRequest *)request responseObject:(id)responseObject{
    if (request.responseSerializer==ZBHTTPResponseSerializer) {
        return responseObject;
    }else{
        NSError *serializationError = nil;
        NSData *data = (NSData *)responseObject;
        // Workaround for behavior of Rails to return a single space for `head :ok` (a workaround for a bug in Safari), which is not interpreted as valid input by NSJSONSerialization.
        // See https://github.com/rails/rails/issues/1742
        BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];
        if (data.length > 0 && !isSpace) {
            id result=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serializationError];
            return result;
        } else {
            return nil;
        }
    }
}
+ (void)successWithResponseObject:(id)responseObject request:(ZBURLRequest *)request success:(requestSuccess)success finished:(requestFinished)finished{
    if (request.apiType == ZBRequestTypeRefreshAndCache||request.apiType == ZBRequestTypeCache) {
             [self storeObject:responseObject request:request];
        }
        id result=[self responsetSerializerConfig:request responseObject:responseObject];
        [request resultIsUseCache:NO];
        success ? success(result,request) : nil;
        finished ? finished (result,nil) : nil;
        [[ZBRequestEngine defaultEngine] removeRequestForkey:request.URLString];
}
+ (void)failureWithError:(NSError *)error request:(ZBURLRequest *)request failure:(requestFailure)failure finished:(requestFinished)finished{
    failure ? failure(error) : nil;
    finished ? finished (nil,error) : nil;
    [[ZBRequestEngine defaultEngine] removeRequestForkey:request.URLString];
    if (request.consoleLog==YES) {
        [self printfailureInfoWithError:error request:request];
    }
}
+ (void)getCacheDataForKey:(NSString *)key request:(ZBURLRequest *)request success:(requestSuccess)success finished:(requestFinished)finished{
    [[ZBCacheManager sharedInstance]getCacheDataForKey:key value:^(NSData *data,NSString *filePath) {
        id result=[self responsetSerializerConfig:request responseObject:data];
        [request resultIsUseCache:YES];
        success ? success(result ,request) : nil;
        finished ? finished (result,nil) : nil;
        if (request.consoleLog==YES) {
            [self printCacheInfoWithkey:key filePath:filePath request:request];
        }
    }];

}
#pragma mark - 打印log
+ (void)printCacheInfoWithkey:(NSString *)key filePath:(NSString *)filePath request:(ZBURLRequest *)request{
    NSString *responseStr=request.responseSerializer==ZBHTTPResponseSerializer ?@"HTTP":@"JOSN";
    NSLog(@"\n------------ZBNetworking------cache info------begin------\n-cachekey-:%@\n-cacheFileSource-:%@\n-responseSerializer-:%@\n------------ZBNetworking------cache info-------end-------",key,filePath,responseStr);
}

+ (void)printfailureInfoWithError:(NSError *)error request:(ZBURLRequest *)request{
    NSLog(@"\n------------ZBNetworking------error info------begin------\n-request url-:%@\n-error info-:%@\n------------ZBNetworking------error info-------end-------",request.URLString,error);
}

@end
