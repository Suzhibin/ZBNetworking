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

+ (ZBURLSessionManager *)shareManager {
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

- (NSMutableArray *)offlineUrlArray
{
    return [NSMutableArray arrayWithArray:[ZBRequestManager shareManager].channelUrlArray];
}

- (NSMutableArray *)offlineNameArray
{
    return [NSMutableArray arrayWithArray:[ZBRequestManager shareManager].channelNameArray];
}

- (void)offlineDownload:(NSMutableArray *)downloadArray target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type
{
    [self offlineDownload:downloadArray target:delegate apiType:type operation:nil];
}

- (void)offlineDownload:(NSMutableArray *)downloadArray target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type operation:(ZBURLSessionManagerBlock)operation
{
    dispatch_sync(dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL), ^{
    
        for (NSString *urlStr in downloadArray) {
    
            [self getRequestWithUrlString:urlStr target:delegate apiType:type];
        }
        
        if (operation) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                operation();
            });
            
        }
        
    });  
}

- (BOOL)isAddUrl:(NSString *)url
{
    return [[ZBRequestManager shareManager]isAddForKey:url isUrl:YES];
}

- (void)addObjectWithUrl:(NSString *)url
{
    [[ZBRequestManager shareManager]addObjectWithForKey:url isUrl:YES];
}

- (void)removeObjectWithUrl:(NSString *)url
{
    [[ZBRequestManager shareManager]removeObjectWithForkey:url isUrl:YES];
}

- (BOOL)isAddName:(NSString *)name
{
    return [[ZBRequestManager shareManager]isAddForKey:name isUrl:NO];
}

- (void)addObjectWithName:(NSString *)name
{
     [[ZBRequestManager shareManager]addObjectWithForKey:name isUrl:NO];
}

- (void)removeObjectWithName:(NSString *)name
{
    [[ZBRequestManager shareManager]removeObjectWithForkey:name isUrl:NO];
}

- (void)removeOfflineArray
{
    [self.offlineUrlArray removeAllObjects];
    [self.offlineNameArray removeAllObjects];
    [[ZBRequestManager shareManager].channelUrlArray removeAllObjects];
    [[ZBRequestManager shareManager].channelNameArray removeAllObjects];
}

#pragma  mark -  请求
-(void)postRequestWithUrlString:(NSString *)requestString parameters:(NSDictionary*)parameters target:(id<ZBURLSessionDelegate>)delegate
{
    [ZBURLSessionManager postRequestWithUrlString:requestString parameters:parameters target:delegate];
}

- (void)getRequestWithUrlString:(NSString *)requestString target:(id<ZBURLSessionDelegate>)delegate
{
    [ZBURLSessionManager getRequestWithUrlString:requestString target:delegate];
}

- (void )getRequestWithUrlString:(NSString *)requestString target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type
{
    [ZBURLSessionManager getRequestWithUrlString:requestString target:delegate apiType:type];
}

+(ZBURLSessionManager *)postRequestWithUrlString:(NSString *)requestString parameters:(NSDictionary*)parameters target:(id<ZBURLSessionDelegate>)delegate
{
    ZBURLSessionManager *request = [[ZBURLSessionManager alloc] init];
    request.requestString = requestString;
    request.delegate = delegate;
    [request postStartRequestWithParameters:parameters];
    return  request;
    
}

+(ZBURLSessionManager *)getRequestWithUrlString:(NSString *)requestString target:(id<ZBURLSessionDelegate>)delegate{
    
    return [ZBURLSessionManager getRequestWithUrlString:requestString target:delegate apiType:ZBRequestTypeDefault];
    
}

+(ZBURLSessionManager *)getRequestWithUrlString:(NSString *)requestString target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type
{
    ZBURLSessionManager *request = [[ZBURLSessionManager alloc] init];
    request.requestString = requestString;
    request.delegate = delegate;
    request.apiType = type;
       
     NSString *path =[[ZBCacheManager shareCacheManager] pathWithfileName:requestString];
    
    if ([[ZBCacheManager shareCacheManager]fileExistsAtPath:path]&&[NSFileManager isTimeOutWithPath:path timeOut:timeOut]==NO&&type!=ZBRequestTypeRefresh&&type!=ZBRequestTypeOffline) {
        
        NSData *data = [NSData dataWithContentsOfFile:path];
    
        ZBLog(@"Read cache");
        [request.downloadData appendData:data];

        if ([request.delegate respondsToSelector:@selector(urlRequestFinished:)]) {
            [request.delegate urlRequestFinished:request];
        }
        
        return request;
        
    }else{

        [request getStartRequest];
       
    }
 
    [[ZBRequestManager shareManager] setRequestObject:request forkey:requestString];
    
   
    
    return request;
}

#pragma mark - NSURLSessionDelegate

/**
 *  1.接收到服务器响应的时候调用该方法
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
}

/**
 *  接收到服务器返回数据的时候会调用该方法，如果数据较大那么该方法可能会调用多次
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   
    [self.downloadData appendData:data];
}

/**
 *  请求完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(error == nil)
    {
        NSString *path =[[ZBCacheManager shareCacheManager] pathWithfileName:_requestString];
       
        [[ZBCacheManager shareCacheManager] setMutableData:self.downloadData writeToFile:path];
        
        if ([_delegate respondsToSelector:@selector(urlRequestFinished:)]) {
            [_delegate urlRequestFinished:self];
        }
    
        [[ZBRequestManager shareManager] removeRequestForkey:_requestString];
        
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
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    if (value) {
        [ZBRequestManager shareManager].mutableHTTPRequestHeaders = [[NSMutableDictionary alloc]init];
        [ZBRequestManager shareManager].value =value;
        [[ZBRequestManager shareManager] setValue:value forHeaderField:field ];
    }
    else {
        [[ZBRequestManager shareManager] removeHeaderForkey:field];
    }
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    
    return [[ZBRequestManager shareManager]objectHeaderForKey:field];
    
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
    _timeoutInterval = timeoutInterval;
    [self didChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
}

- (NSURLSession *)session
{
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
- (void)getStartRequest
{
     ZBLog(@"get start Request");
    
    NSString *string = [self.requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:string];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeoutInterval];
    
    if ([ZBRequestManager shareManager].value) {
        
          NSMutableURLRequest *mutableRequest = [request mutableCopy];
        
        [[[ZBRequestManager shareManager]mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            
            if (![mutableRequest valueForHTTPHeaderField:field]) {
                [mutableRequest addValue: value forHTTPHeaderField:field];
            }
            
        }];
        
        request = [mutableRequest copy];
        
        ZBLog(@"get_HeaderField%@", request.allHTTPHeaderFields);
    }

    _dataTask = [self.session dataTaskWithRequest:request];
    
    [_dataTask resume];
}


#pragma mark - post Request
- (void)postStartRequestWithParameters:(NSDictionary *)parameters;{
    
     ZBLog(@"start Request POST");
    
    NSString *string = [_requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:string];
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    
    [mutableRequest setHTTPMethod: @"POST"];
    
    if ([ZBRequestManager shareManager].value) {
        
        [[[ZBRequestManager shareManager]mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            
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
    
    _dataTask = [self.session dataTaskWithRequest:mutableRequest];
    
    [_dataTask resume];
    
    
}


@end
