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

#import "NSFileManager+pathMethod.h"
#import "ZBCacheManager.h"
static const NSInteger timeOut = 60*60;

@implementation ZBURLSessionManager

+ (ZBURLSessionManager *)sharedManager {
    static ZBURLSessionManager *sessionManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [[ZBURLSessionManager alloc] init];
    });
    return sessionManager;
}

- (id)init{
    self = [super init];
    if (self) {
        
        self.request.responseObj = [[NSMutableData alloc] init];
      
        self.request.timeoutInterval=15;
        
    }
    return self;
}

+ (instancetype)manager {
    return [[[self class] alloc] init];
}

#pragma mark - 离线下载

- (void)offlineDownload:(NSMutableArray *)downloadArray apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed{
    if (downloadArray.count==0)return;
    [downloadArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
        [self getRequestWithURL:urlString apiType:type success:success failed:failed];
    }];
}
- (void)offlineDownload:(NSMutableArray *)downloadArray target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type{
    if (downloadArray.count==0)return;
    [downloadArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
        [self getRequestWithURL:urlString target:delegate apiType:type];
    }];
}

#pragma  mark -  请求

- (void)requestWithConfig:(requestConfig)config success:(requestSuccess)success failed:(requestFailed)failed{
    
    config ? config(self.request) : nil;
    
    if (self.request.apiType==ZBRequestTypeOffline) {
        [self offlineDownload:self.request.urlArray apiType:self.request.apiType success:success failed:failed];
    }else{
        [self getRequestWithURL:self.request.urlString apiType:self.request.apiType success:success failed:failed];
    }
}

-(void)postRequestWithURL:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<ZBURLSessionDelegate>)delegate{
    [ZBURLSessionManager postRequestWithURL:urlString parameters:parameters target:delegate];
}

- (void)getRequestWithURL:(NSString *)urlString target:(id<ZBURLSessionDelegate>)delegate{
    [ZBURLSessionManager getRequestWithURL:urlString target:delegate];
}

- (void )getRequestWithURL:(NSString *)urlString target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type{
    [ZBURLSessionManager getRequestWithURL:urlString target:delegate apiType:type];
}

- (void )getRequestWithURL:(NSString *)urlString apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed {
     [ZBURLSessionManager getRequestWithURL:urlString target:nil apiType:type success:success failed:failed];
}

+(ZBURLSessionManager *)postRequestWithURL:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<ZBURLSessionDelegate>)delegate{
    ZBURLSessionManager *session = [[ZBURLSessionManager alloc] init];
    session.request.urlString = urlString;
    session.delegate = delegate;
    [session postStartRequestWithParameters:parameters];
    return  session;
}

+(ZBURLSessionManager *)getRequestWithURL:(NSString *)urlString target:(id<ZBURLSessionDelegate>)delegate{
    return [ZBURLSessionManager getRequestWithURL:urlString target:delegate apiType:ZBRequestTypeDefault];
}

+(ZBURLSessionManager *)getRequestWithURL:(NSString *)urlString target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type{
    return [ZBURLSessionManager getRequestWithURL:urlString target:delegate apiType:type success:nil failed:nil];
}

+(ZBURLSessionManager *)getRequestWithURL:(NSString *)urlString target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed {
    
    ZBURLSessionManager *session = [[ZBURLSessionManager alloc] init];
    session.request.urlString=urlString;
    session.request.apiType=type;
    session.delegate = delegate;
    session.requestSuccess=success;
    session.requestFailed=failed;
    NSString *path =[[ZBCacheManager sharedManager] pathWithFileName:urlString];
    
    if ([[ZBCacheManager sharedManager]isExistsAtPath:path]&&[NSFileManager isTimeOutWithPath:path timeOut:timeOut]==NO&&type!=ZBRequestTypeRefresh&&type!=ZBRequestTypeOffline) {
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        ZBLog(@"session cache");
        [session.request.responseObj appendData:data];
    
        success ? success(session.request.responseObj  ,type) : nil;
        
        if ([session.delegate respondsToSelector:@selector(urlRequestFinished:)]) {
            [session.delegate urlRequestFinished:session.request];
        }
        return session;
        
    }else{
        [session getStartRequest];
    }
    
    [session.request setRequestObject:session forkey:urlString];
    return session;
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
        NSString *path =[[ZBCacheManager sharedManager] pathWithFileName:self.request.urlString];
        
        [[ZBCacheManager sharedManager] setContent:self.request.responseObj writeToFile:path];
        
        if (self.requestSuccess) {
           self.requestSuccess(self.request.responseObj,self.request.apiType);
        }
        
        if ([_delegate respondsToSelector:@selector(urlRequestFinished:)]) {
            [_delegate urlRequestFinished:self.request];
        }
        [self.request removeRequestForkey:self.request.urlString ];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }else{
         ZBLog(@"error:%@",[error localizedDescription]);
        self.request.error=nil;
        self.request.error=error;
        
        if (self.requestFailed) {
            self.requestFailed(self.request.error);
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
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _urlSession;
}

- (ZBURLRequest*)request{
    if (!_request) {
        _request=[[ZBURLRequest alloc]init];
    }
    
    return _request;
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
- (void)getStartRequest{
     ZBLog(@"session get");
    if(!self.request.urlString)return;
    NSString *string = [self.request.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:string];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.request.timeoutInterval];
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
- (void)postStartRequestWithParameters:(NSDictionary *)parameters;{
     ZBLog(@"post");
    NSString *string = [self.request.urlString  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:string];
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    
    [mutableRequest setHTTPMethod: @"POST"];
    
    if (self.request.value) {
        
        [[self.request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            
            if (![mutableRequest valueForHTTPHeaderField:field]) {
                [mutableRequest setValue:value forHTTPHeaderField:field];
            }
        }];
        
        ZBLog(@"POST_HeaderField%@", mutableRequest.allHTTPHeaderFields);
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


@end
