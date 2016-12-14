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
#import "ZBRequestManager.h"
#import "NSFileManager+pathMethod.h"
#import "ZBCacheManager.h"
static const NSInteger timeOut = 60*60;
static ZBURLSessionManager *sessionManager=nil;
@implementation ZBURLSessionManager

+ (ZBURLSessionManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [[ZBURLSessionManager alloc] init];
    });
    return sessionManager;
}

- (id)init{
    self = [super init];
    if (self) {
        
        self.downloadData = [[NSMutableData alloc] init];
      
        _timeoutInterval=15;
        
    }
    return self;
}

+ (instancetype)manager {
    return [[[self class] alloc] init];
}

#pragma mark - 离线下载

- (NSMutableArray *)offlineUrlArray{
    return [NSMutableArray arrayWithArray:[ZBRequestManager sharedManager].urlArray];
}

- (NSMutableArray *)offlineNameArray{
    return [NSMutableArray arrayWithArray:[ZBRequestManager sharedManager].nameArray];
}

- (void)offlineDownload:(NSMutableArray *)downloadArray target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type{
    [self offlineDownload:downloadArray target:delegate apiType:type operation:nil];
}

- (void)offlineDownload:(NSMutableArray *)downloadArray target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type operation:(ZBURLSessionManagerBlock)operation{
    dispatch_sync(dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL), ^{
    
        [downloadArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
            [self getRequestWithURL:urlString target:delegate apiType:type];
        }];
        if (operation) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                operation();
            });
        }
    });  
}

- (void)addObjectWithUrl:(NSString *)url{
    [[ZBRequestManager sharedManager]addObjectWithForKey:url isUrl:YES];
}

- (void)removeObjectWithUrl:(NSString *)url{
    [[ZBRequestManager sharedManager]removeObjectWithForkey:url isUrl:YES];
}

- (void)addObjectWithName:(NSString *)name{
     [[ZBRequestManager sharedManager]addObjectWithForKey:name isUrl:NO];
}

- (void)removeObjectWithName:(NSString *)name{
    [[ZBRequestManager sharedManager]removeObjectWithForkey:name isUrl:NO];
}

- (void)removeOfflineArray{
    [self.offlineUrlArray removeAllObjects];
    [self.offlineNameArray removeAllObjects];
    [[ZBRequestManager sharedManager].urlArray removeAllObjects];
    [[ZBRequestManager sharedManager].nameArray removeAllObjects];
}

#pragma  mark -  请求
-(void)postRequestWithURL:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<ZBURLSessionDelegate>)delegate{
    [ZBURLSessionManager postRequestWithURL:urlString parameters:parameters target:delegate];
}

- (void)getRequestWithURL:(NSString *)urlString target:(id<ZBURLSessionDelegate>)delegate{
    [ZBURLSessionManager getRequestWithURL:urlString target:delegate];
}

- (void )getRequestWithURL:(NSString *)urlString target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type{
    [ZBURLSessionManager getRequestWithURL:urlString target:delegate apiType:type];
}

+(ZBURLSessionManager *)postRequestWithURL:(NSString *)urlString parameters:(NSDictionary*)parameters target:(id<ZBURLSessionDelegate>)delegate{
    ZBURLSessionManager *request = [[ZBURLSessionManager alloc] init];
    request.urlString = urlString;
    request.delegate = delegate;
    [request postStartRequestWithParameters:parameters];
    return  request;
    
}

+(ZBURLSessionManager *)getRequestWithURL:(NSString *)urlString target:(id<ZBURLSessionDelegate>)delegate{
    return [ZBURLSessionManager getRequestWithURL:urlString target:delegate apiType:ZBRequestTypeDefault];
}

+(ZBURLSessionManager *)getRequestWithURL:(NSString *)urlString target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type{
    ZBURLSessionManager *request = [[ZBURLSessionManager alloc] init];
    __weak __typeof(request) weakRequest = request;
    weakRequest.urlString = urlString;
    weakRequest.delegate = delegate;
    weakRequest.apiType = type;
    
    NSString *path =[[ZBCacheManager sharedCacheManager] pathWithFileName:urlString];
    
    if ([[ZBCacheManager sharedCacheManager]fileExistsAtPath:path]&&[NSFileManager isTimeOutWithPath:path timeOut:timeOut]==NO&&type!=ZBRequestTypeRefresh&&type!=ZBRequestTypeOffline) {
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        ZBLog(@"cache");
        [weakRequest.downloadData appendData:data];
        
        if ([weakRequest.delegate respondsToSelector:@selector(urlRequestFinished:)]) {
            [weakRequest.delegate urlRequestFinished:request];
        }
        return weakRequest;
        
    }else{
        [weakRequest getStartRequest];
    }
    
    [[ZBRequestManager sharedManager] setRequestObject:weakRequest forkey:urlString];
    return weakRequest;
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
    [self.downloadData appendData:data];
}

/**
 *  请求完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if(error == nil){
        NSString *path =[[ZBCacheManager sharedCacheManager] pathWithFileName:_urlString];
        [[ZBCacheManager sharedCacheManager] setMutableData:self.downloadData writeToFile:path];
        
        if ([_delegate respondsToSelector:@selector(urlRequestFinished:)]) {
            [_delegate urlRequestFinished:self];
        }
        [[ZBRequestManager sharedManager] removeRequestForkey:_urlString];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }else{
         ZBLog(@"error:%@",[error localizedDescription]);
        self.error=nil;
        self.error=error;
       
        if ([_delegate respondsToSelector:@selector(urlRequestFailed:)]) {
            [_delegate urlRequestFailed:self];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

#pragma mark - request Operation
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field{
    if (value) {
        [ZBRequestManager sharedManager].value =value;
        [[ZBRequestManager sharedManager] setValue:value forHeaderField:field ];
    }
    else {
        [[ZBRequestManager sharedManager] removeHeaderForkey:field];
    }
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    return [[ZBRequestManager sharedManager]objectHeaderForKey:field];
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
    _timeoutInterval = timeoutInterval;
    [self didChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
}

- (NSURLSession *)session{
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)requestToCancel:(BOOL)cancelPendingTasks{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (cancelPendingTasks) {
            [self.session invalidateAndCancel];
        } else {
            [self.session finishTasksAndInvalidate];
        }
    });
}

#pragma mark - get Request
- (void)getStartRequest{
     ZBLog(@"get");
    NSString *string = [self.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:string];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeoutInterval];
    
    if ([ZBRequestManager sharedManager].value) {
        
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        
        [[[ZBRequestManager sharedManager]mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            
            if (![mutableRequest valueForHTTPHeaderField:field]) {
                [mutableRequest addValue: value forHTTPHeaderField:field];
            }
            
        }];
        
        request = [mutableRequest copy];
        
        ZBLog(@"get_HeaderField%@", request.allHTTPHeaderFields);
    }
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    
    [dataTask resume];

}

#pragma mark - post Request
- (void)postStartRequestWithParameters:(NSDictionary *)parameters;{
     ZBLog(@"post");
    NSString *string = [_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:string];
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    
    [mutableRequest setHTTPMethod: @"POST"];
    
    if ([ZBRequestManager sharedManager].value) {
        
        [[[ZBRequestManager sharedManager]mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            
            if (![mutableRequest valueForHTTPHeaderField:field]) {
                [mutableRequest setValue:value forHTTPHeaderField:field];
            }
        }];
        
        ZBLog(@"POST_HeaderField%@", mutableRequest.allHTTPHeaderFields);
    }
    
    [mutableRequest setTimeoutInterval:_timeoutInterval];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSString *key in parameters) {
        id obj = [parameters objectForKey:key];
        NSString *str = [NSString stringWithFormat:@"%@=%@",key,obj];
        [array addObject:str];
    }
    
    NSString *dataStr = [array componentsJoinedByString:@"&"];
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [mutableRequest setHTTPBody:data];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:mutableRequest];
    
    [dataTask resume];
    
}


@end
