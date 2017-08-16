//
//  ZBNetworkManager.m
//  ZBNetworking
//
//  Created by NQ UEC on 17/1/10.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//  ( https://github.com/Suzhibin )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//


#import "ZBNetworkManager.h"
#import "ZBCacheManager.h"
#import "ZBNetworkEngine.h"

@implementation ZBNetworkManager

#pragma mark - GET/POST 配置请求

+ (void)requestWithConfig:(requestConfig)config success:(requestSuccess)success failed:(requestFailed)failed{
    return [self requestWithConfig:config progress:nil success:success failed:failed];
}

+ (void)requestWithConfig:(requestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    ZBURLRequest *request=[[ZBURLRequest alloc]init];
    config ? config(request) : nil;
 
    if (request.methodType==POST) {
        [self POST:request progress:progress success:success failed:failed];
    }else{
        if (request.apiType==ZBRequestTypeOffline) {
            [self offlineDownload:request.urlArray apiType:request.apiType success:success failed:failed];
        }else{
            [self GET:request progress:progress success:success failed:failed];
        }
    }
}

+ (void)offlineDownload:(NSMutableArray *)downloadArray success:(requestSuccess)success failed:(requestFailed)failed{
    [self offlineDownload:downloadArray apiType:ZBRequestTypeOffline success:success failed:failed];
}

+ (void)offlineDownload:(NSMutableArray *)downloadArray apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed{
    if (downloadArray.count==0)return;
    [downloadArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
         [self dataTaskWithGetURL:urlString parameters:nil apiType:type progress:nil success:success failed:failed];
    }];
}

#pragma mark - GET 请求

+ (void)GET:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    NSString *key = [self stringUTF8Encoding:[self urlString:request.urlString appendingParameters:request.parameters]];
    
    if ([[ZBCacheManager sharedInstance]diskCacheExistsWithKey:key]&&request.apiType!=ZBRequestTypeRefresh&&request.apiType!=ZBRequestTypeRefreshMore){
        
        [[ZBCacheManager sharedInstance]getCacheDataForKey:key value:^(id responseObj,NSString *filePath) {
            success ? success(responseObj ,request.apiType) : nil;
        }];
        
    }else{
        [self dataTaskWithGetRequest:request progress:progress success:success failed:failed];
    }
}

+ (NSURLSessionDataTask *)dataTaskWithGetRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    [self serializer:request];
    
    return  [self dataTaskWithGetURL:request.urlString parameters:request.parameters apiType:request.apiType  progress:progress success:success failed:failed];
}

+ (NSURLSessionDataTask *)dataTaskWithGetURL:(NSString *)urlString parameters:(id)parameters apiType:(apiType)type  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    if([urlString isEqualToString:@""]||urlString==nil)return nil;
    
    NSURLSessionDataTask *dataTask = nil;
    return dataTask= [[ZBNetworkEngine defaultEngine]GET:[self stringUTF8Encoding:urlString] parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
        progress ? progress(downloadProgress) : nil;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString * key= [self stringUTF8Encoding:[self urlString:urlString appendingParameters:parameters]];
        
        [[ZBCacheManager sharedInstance] storeContent:responseObject forKey:key isSuccess:nil];
        
        success ? success(responseObject,type) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed ? failed(error) : nil;
    }];
}

#pragma mark - POST 请求

+ (void)POST:(ZBURLRequest *)request  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
      [self dataTaskWithPostRequest:request progress:progress success:success failed:failed];
}

+ (NSURLSessionDataTask *)dataTaskWithPostRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    [self serializer:request];
    
    return [self dataTaskWithPostURL:request.urlString parameters:request.parameters progress:progress success:success failed:failed];
}

+ (NSURLSessionDataTask *)dataTaskWithPostURL:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    if([urlString isEqualToString:@""]||urlString==nil)return nil;
    
    NSURLSessionDataTask *dataTask = nil;
    return dataTask=[[ZBNetworkEngine defaultEngine] POST:[self stringUTF8Encoding:urlString] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress ? progress(uploadProgress) : nil;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success ? success(responseObject,0) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed ? failed(error) : nil;
    }];
    
}
#pragma mark - 其他配置
+ (void)serializer:(ZBURLRequest *)request{
  
    [ZBNetworkEngine defaultEngine].requestSerializer =request.requestSerializer==ZBSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
    
    [ZBNetworkEngine defaultEngine].requestSerializer.timeoutInterval=request.timeoutInterval?request.timeoutInterval:15;
    
    if ([[request mutableHTTPRequestHeaders] allKeys].count>0) {
        [[request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [[ZBNetworkEngine defaultEngine].requestSerializer setValue:value forHTTPHeaderField:field];
        }];
    }
}

+ (void)cancelRequest:(NSString *)urlString completion:(cancelCompletedBlock)completion{

    if([urlString isEqualToString:@""]||urlString==nil)return;
    
    if ([ZBNetworkEngine defaultEngine].dataTasks.count <= 0) {
        return;
    }
    
    [[ZBNetworkEngine defaultEngine].tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([[[task.currentRequest URL] absoluteString] isEqualToString:[self stringUTF8Encoding:urlString]]) {
            [task cancel];
            
            if (completion) {
                completion([[task.currentRequest URL] absoluteString]);
            }
        }
        
    }];
}

+ (NSString *)stringUTF8Encoding:(NSString *)urlString{
    return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)urlString:(NSString *)urlString appendingParameters:(id)parameters{
    if (parameters==nil) {
        return urlString;
    }else{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSString *key in parameters) {
            id obj = [parameters objectForKey:key];
            NSString *str = [NSString stringWithFormat:@"%@=%@",key,obj];
            [array addObject:str];
        }
        
        NSString *parametersString = [array componentsJoinedByString:@"&"];
        return  [urlString stringByAppendingString:[NSString stringWithFormat:@"?%@",parametersString]];
    }
}
@end
