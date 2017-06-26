//
//  ZBURLSessionManager.m
//  ZBURLSessionManager
//
//  Created by NQ UEC on 16/5/13.
//  Copyright © 2016年 Suzhibin. All rights reserved.
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


#import "ZBURLSessionManager.h"
#import <UIKit/UIKit.h>
#import "ZBCacheManager.h"

@implementation ZBURLSessionManager

+ (ZBURLSessionManager *)sharedInstance{
    static ZBURLSessionManager *sessionInstance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionInstance = [[ZBURLSessionManager alloc] init];
    });
    return sessionInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        self.request.timeoutInterval=15;
    }
    return self;
}

#pragma mark - 离线下载

- (void)offlineDownload:(NSMutableArray *)downloadArray apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed{
    if (downloadArray.count==0)return;
    [downloadArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
        [self GET:urlString parameters:nil apiType:type success:success failed:failed];
    }];
}
- (void)offlineDownload:(NSMutableArray *)downloadArray target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type{
    if (downloadArray.count==0)return;
    [downloadArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
        [self GET:urlString parameters:nil target:delegate apiType:type];
    }];
}

#pragma  mark -  请求

+ (void)requestWithConfig:(requestConfig)config success:(requestSuccess)success failed:(requestFailed)failed{
    [[ZBURLSessionManager sharedInstance]requestWithConfig:config success:success failed:failed];
}

- (void)requestWithConfig:(requestConfig)config success:(requestSuccess)success failed:(requestFailed)failed{
    
    config ? config(self.request) : nil;
    if (self.request.methodType==POST) {
        [self POST:self.request.urlString parameters:self.request.parameters success:success failed:failed];
    }else{
        if (self.request.apiType==ZBRequestTypeOffline) {
            [self offlineDownload:self.request.urlArray apiType:self.request.apiType success:success failed:failed];
        }else{
            [self GET:self.request.urlString parameters:self.request.parameters apiType:self.request.apiType success:success failed:failed];
        }
    }
}
#pragma mark - GET 请求
- (void)GET:(NSString *)urlString parameters:(id)parameters target:(id<ZBURLSessionDelegate>)delegate{
    [ZBURLSessionManager GET:urlString parameters:parameters target:delegate];
}

- (void )GET:(NSString *)urlString parameters:(id)parameters target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type{
    [ZBURLSessionManager GET:urlString parameters:parameters target:delegate apiType:type];
}

- (void )GET:(NSString *)urlString parameters:(id)parameters apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed {
     [ZBURLSessionManager GET:urlString parameters:parameters target:nil apiType:type success:success failed:failed];
}

+ (ZBURLSessionManager *)GET:(NSString *)urlString parameters:(id)parameters target:(id<ZBURLSessionDelegate>)delegate{
    return [ZBURLSessionManager GET:urlString parameters:parameters target:delegate apiType:ZBRequestTypeDefault];
}

+ (ZBURLSessionManager *)GET:(NSString *)urlString parameters:(id)parameters target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type{
    return [ZBURLSessionManager GET:urlString parameters:parameters target:delegate apiType:type success:nil failed:nil];
}

+ (ZBURLSessionManager *)GET:(NSString *)urlString parameters:(id)parameters target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed {
    
    if([urlString isEqualToString:@""]||urlString==nil)return nil;
    
    if (![urlString isKindOfClass:NSString.class]) {
        urlString = nil;
    }
    ZBURLSessionManager *session = [[ZBURLSessionManager alloc] init];
    session.request.urlString=urlString;
    session.request.parameters=parameters;
    session.request.apiType=type;
    session.delegate = delegate;
    session.success=success;
    session.failed=failed;
    
    NSString *key=[session.request stringUTF8Encoding:[session.request urlString:urlString appendingParameters:parameters]];
    
    if ([[ZBCacheManager sharedInstance]diskCacheExistsWithKey:key]&&type!=ZBRequestTypeRefresh&&type!=ZBRequestTypeOffline) {
         [[ZBCacheManager sharedInstance]getCacheDataForKey:key value:^(id responseObj,NSString * filePath) {
             [session.request.responseObj appendData:responseObj];
             success ? success(session.request.responseObj,type) : nil;
             
             if ([session.delegate respondsToSelector:@selector(urlRequestFinished:)]) {
                 [session.delegate urlRequestFinished:session.request];
             }
         }];

        return session;
        
    }else{
        [session GETRequest:key];
    }
    
    [session.request setRequestObject:session forkey:key];
    return session;
}
#pragma mark - POST 请求
- (void)POST:(NSString *)urlString parameters:(NSDictionary*)parameters success:(requestSuccess)success failed:(requestFailed)failed{
    [ZBURLSessionManager POST:urlString parameters:parameters success:success failed:failed];
}

- (void)POST:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<ZBURLSessionDelegate>)delegate{
    [ZBURLSessionManager POST:urlString parameters:parameters target:delegate];
}

+ (ZBURLSessionManager *)POST:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<ZBURLSessionDelegate>)delegate{
    
    return  [ZBURLSessionManager POST:urlString parameters:parameters target:delegate success:nil failed:nil];
}

+ (ZBURLSessionManager *)POST:(NSString *)urlString parameters:(NSDictionary*)parameters success:(requestSuccess)success failed:(requestFailed)failed{
    
    return  [ZBURLSessionManager POST:urlString parameters:parameters target:nil success:success failed:failed];
}

+ (ZBURLSessionManager *)POST:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<ZBURLSessionDelegate>)delegate success:(requestSuccess)success failed:(requestFailed)failed{
    ZBURLSessionManager *session = [[ZBURLSessionManager alloc] init];
    session.request.urlString = urlString;
    session.request.parameters=parameters;
    session.delegate = delegate;
    session.success=success;
    session.failed=failed;
    [session POSTRequest:urlString parameters:parameters];
    return  session;
}

#pragma mark - NSURLSessionDelegate

/**
 *  1.接收到服务器响应的时候调用该方法
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    completionHandler(NSURLSessionResponseAllow);
}

/**
 *  接收到服务器返回数据的时候会调用该方法，如果数据较大那么该方法可能会调用多次
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.request.responseObj appendData:data];
}

/**
 *  请求完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if(error == nil){
        
        NSString *key= [self.request stringUTF8Encoding:[self.request urlString:self.request.urlString appendingParameters:self.request.parameters]];
       
         [[ZBCacheManager sharedInstance] storeContent:self.request.responseObj forKey:key];
        
        if (self.success) {
           self.success(self.request.responseObj,self.request.apiType);
        }
        
        if ([_delegate respondsToSelector:@selector(urlRequestFinished:)]) {
            [_delegate urlRequestFinished:self.request];
        }
        [self.request removeRequestForkey:key ];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }else{
        ZBLog(@"error:%@",[error localizedDescription]);
        self.request.error=nil;
        self.request.error=error;
        
        if (self.failed) {
            self.failed(self.request.error);
        }
        
        if ([_delegate respondsToSelector:@selector(urlRequestFailed:)]) {
            [_delegate urlRequestFailed:self.request];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

/**
 *  证书处理
 */
- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    //挑战处理类型为 默认
    /*
     NSURLSessionAuthChallengePerformDefaultHandling：默认方式处理
     NSURLSessionAuthChallengeUseCredential：使用指定的证书
     NSURLSessionAuthChallengeCancelAuthenticationChallenge：取消挑战
     */
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
  
    if (credential) {
        disposition = NSURLSessionAuthChallengeUseCredential;
    }

    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark - request Operation
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field{
    if (value) {
        [ZBURLRequest sharedInstance].value =value;
        [[ZBURLRequest sharedInstance] setValue:value forHeaderField:field ];
    }
    else {
        [[ZBURLRequest sharedInstance] removeHeaderForkey:field];
    }
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    return [self.request objectHeaderForKey:field];
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
    self.request.timeoutInterval = timeoutInterval;
    [self didChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
}

- (NSURLSession *)urlSession{
    if (_urlSession == nil) {

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = self.request.timeoutInterval;
        _urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _urlSession;
}

- (ZBURLRequest*)request{
    if (!_request) {
        _request=[[ZBURLRequest alloc]init];
    }
    
    return _request;
}

+ (void)requestToCancel:(BOOL)cancelPendingTasks{
    [[ZBURLSessionManager sharedInstance]requestToCancel:cancelPendingTasks];
}

- (void)requestToCancel:(BOOL)cancelPendingTasks{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (cancelPendingTasks) {
            [self.urlSession invalidateAndCancel];
        } else {
            [self.urlSession finishTasksAndInvalidate];
        }
    });
}

#pragma mark - get Request
- (void)GETRequest:(NSString *)urlString{
  
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.request.timeoutInterval];
    if ([ZBURLRequest sharedInstance].value) {
       
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        
        [[[ZBURLRequest sharedInstance] mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            
            if (![mutableRequest valueForHTTPHeaderField:field]) {
                [mutableRequest addValue: value forHTTPHeaderField:field];
            }
        }];
        
        request = [mutableRequest copy];
        
        ZBLog(@"get_HeaderField%@", request.allHTTPHeaderFields);
    }
    
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request];
    
    [dataTask resume];

}

#pragma mark - post Request
- (void)POSTRequest:(NSString *)urlString parameters:(NSDictionary *)parameters; {

     NSURLSession *session = [NSURLSession sharedSession];

     NSURL *url = [NSURL URLWithString:[self.request stringUTF8Encoding:urlString]];

     NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

     request.HTTPMethod = @"POST";
     
     if (self.request.value) {
         
         [[self.request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
             
             if (![request valueForHTTPHeaderField:field]) {
                 [request setValue:value forHTTPHeaderField:field];
             }
         }];
     }
     [request setTimeoutInterval:self.request.timeoutInterval];

     NSMutableArray *array = [[NSMutableArray alloc] init];
     for (NSString *key in parameters) {
         id obj = [parameters objectForKey:key];
         NSString *str = [NSString stringWithFormat:@"%@=%@",key,obj];
         [array addObject:str];
     }
     NSString *dataStr = [array componentsJoinedByString:@"&"];
     NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];

     request.HTTPBody = data;

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error == nil){
     
            [self.request.responseObj appendData:data];
            if (self.success) {
                self.success(self.request.responseObj,self.request.apiType);
            }
            if ([_delegate respondsToSelector:@selector(urlRequestFinished:)]) {
                [_delegate urlRequestFinished:self.request];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }else{
            self.request.error=nil;
            self.request.error=error;
            
            if (self.failed) {
                self.failed(self.request.error);
            }
            if ([_delegate respondsToSelector:@selector(urlRequestFailed:)]) {
                [_delegate urlRequestFailed:self.request];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }

    }];
     
    [dataTask resume];
}
/*
- (void)POSTRequest:(NSString *)urlString parameters:(NSDictionary *)parameters;{
       
    NSURL *url = [NSURL URLWithString:[self.request stringUTF8Encoding:urlString]];
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    
    [mutableRequest setHTTPMethod: @"POST"];
    
    if (self.request.value) {
        
        [[self.request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            
            if (![mutableRequest valueForHTTPHeaderField:field]) {
                [mutableRequest setValue:value forHTTPHeaderField:field];
            }
        }];
    }
    
    [mutableRequest setTimeoutInterval:self.request.timeoutInterval];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSString *key in parameters) {
        id obj = [parameters objectForKey:key];
        NSString *str = [NSString stringWithFormat:@"%@=%@",key,obj];
        [array addObject:str];
    }
    
    NSString *dataStr = [array componentsJoinedByString:@"&"];
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [mutableRequest setHTTPBody:data];
    
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:mutableRequest];
    
    [dataTask resume];
    
}
*/

@end
