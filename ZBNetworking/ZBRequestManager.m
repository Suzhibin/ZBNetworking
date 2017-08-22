//
//  ZBRequestManager.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import "ZBRequestManager.h"
#import "ZBCacheManager.h"
#import "ZBRequestEngine.h"
#import "ZBURLRequest.h"
@implementation ZBRequestManager

#pragma mark - GET/POST 配置请求

+ (void)requestWithConfig:(requestConfig)config success:(requestSuccess)success failed:(requestFailed)failed{
    [self requestWithConfig:config progress:nil success:success failed:failed];
}

+ (void)requestWithConfig:(requestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    ZBURLRequest *request=[[ZBURLRequest alloc]init];
    config ? config(request) : nil;
    
    if (request.methodType==ZBMethodTypePOST) {
        
        [self POST:request progress:progress success:success failed:failed];
    }else if (request.methodType==ZBMethodTypeUpload){
        
        [self uploadWithRequest:request progress:progress success:success failed:failed];
    }else if (request.methodType==ZBMethodTypeDownLoad){
        
        [self downloadWithRequest:request progress:progress success:success failed:failed];
    }else{
        if (request.apiType==ZBRequestTypeBatch) {
            
            [self batchRequest:request.urlArray apiType:request.apiType success:success failed:failed];
        }else{
            
            [self GET:request progress:progress success:success failed:failed];
        }
    }
}

+ (void)batchRequest:(NSMutableArray *)downloadArray apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed{
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
    [self headersAndTime:request];
    
    return  [self dataTaskWithGetURL:request.urlString parameters:request.parameters apiType:request.apiType  progress:progress success:success failed:failed];
}

+ (NSURLSessionDataTask *)dataTaskWithGetURL:(NSString *)urlString parameters:(id)parameters apiType:(apiType)type  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    if([urlString isEqualToString:@""]||urlString==nil)return nil;
    
    NSURLSessionDataTask *dataTask = nil;
    return dataTask= [[ZBRequestEngine defaultEngine]GET:[self stringUTF8Encoding:urlString] parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
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
    NSString *key = [self stringUTF8Encoding:[self urlString:request.urlString appendingParameters:request.parameters]];
    
    if ([[ZBCacheManager sharedInstance]diskCacheExistsWithKey:key]&&request.apiType!=ZBRequestTypeRefresh&&request.apiType!=ZBRequestTypeRefreshMore){
    
        [[ZBCacheManager sharedInstance]getCacheDataForKey:key value:^(id responseObj,NSString *filePath) {
            success ? success(responseObj ,request.apiType) : nil;
        }];
        
    }else{
        
        [self dataTaskWithPostRequest:request apiType:request.apiType progress:progress success:success failed:failed];
    }
}

+ (NSURLSessionDataTask *)dataTaskWithPostRequest:(ZBURLRequest *)request apiType:(apiType)type progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    [self serializer:request];
    [self headersAndTime:request];
    return [self dataTaskWithPostURL:request.urlString parameters:request.parameters apiType:type progress:progress success:success failed:failed];
}

+ (NSURLSessionDataTask *)dataTaskWithPostURL:(NSString *)urlString parameters:(id)parameters apiType:(apiType)type progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    if([urlString isEqualToString:@""]||urlString==nil)return nil;
    
    NSURLSessionDataTask *dataTask = nil;
    return dataTask=[[ZBRequestEngine defaultEngine] POST:[self stringUTF8Encoding:urlString] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress ? progress(uploadProgress) : nil;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString * key= [self stringUTF8Encoding:[self urlString:urlString appendingParameters:parameters]];
        
        [[ZBCacheManager sharedInstance] storeContent:responseObject forKey:key isSuccess:nil];
          success ? success(responseObject,type) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed ? failed(error) : nil;
    }];
}
#pragma mark - upload
+ (NSURLSessionTask *)uploadWithRequest:(ZBURLRequest *)request
                           progress:(progressBlock)progress
                            success:(requestSuccess)success
                            failed:(requestFailed)failed{
    
    return [[ZBRequestEngine defaultEngine] POST:[self stringUTF8Encoding:request.urlString] parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
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
+ (NSURLSessionTask *)downloadWithRequest:(ZBURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:request.urlString]];
    
    [self headersAndTime:request];
    
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
    NSURLSessionDownloadTask *dataTask = [[ZBRequestEngine defaultEngine] downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        
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
+ (void)serializer:(ZBURLRequest *)request{
    
    [ZBRequestEngine defaultEngine].requestSerializer =request.requestSerializer==ZBSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

+ (void)headersAndTime:(ZBURLRequest *)request{
    
    [ZBRequestEngine defaultEngine].requestSerializer.timeoutInterval=request.timeoutInterval?request.timeoutInterval:15;
    
    if ([[request mutableHTTPRequestHeaders] allKeys].count>0) {
        [[request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [[ZBRequestEngine defaultEngine].requestSerializer setValue:value forHTTPHeaderField:field];
        }];
    }
}

+ (void)cancelRequest:(NSString *)urlString completion:(cancelCompletedBlock)completion{
    
    if([urlString isEqualToString:@""]||urlString==nil)return;
    
    NSString *cancelUrlString=[[ZBRequestEngine defaultEngine]cancelRequest:[self stringUTF8Encoding:urlString]];
    if (completion) {
        completion(cancelUrlString);
    }
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
