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
#import "ZBRequestManager.h"
#import "NSFileManager+pathMethod.h"
#import "ZBCacheManager.h"

@implementation ZBURLSessionManager

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

- (NSURLSession *)session
{
    if (nil == _session) {
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

#pragma  mark - 实例方法 请求

-(void)postRequestWithUrlString:(NSString *)requestString dict:(NSDictionary*)dict target:(id<ZBURLSessionDelegate>)delegate
{
    
    [ZBURLSessionManager postRequestWithUrlString:requestString dict:dict target:delegate];
    
}

- (void)getRequestWithUrlString:(NSString *)requestString target:(id<ZBURLSessionDelegate>)delegate
{
    [ZBURLSessionManager getRequestWithUrlString:requestString target:delegate];
}

- (void )getRequestWithUrlString:(NSString *)requestString target:(id<ZBURLSessionDelegate>)delegate apiType:(apiType)type
{
    
     [ZBURLSessionManager getRequestWithUrlString:requestString target:delegate apiType:type];

}
#pragma  mark - 类方法 请求

+(ZBURLSessionManager *)postRequestWithUrlString:(NSString *)requestString dict:(NSDictionary*)dict target:(id<ZBURLSessionDelegate>)delegate
{
    ZBURLSessionManager *request = [[ZBURLSessionManager alloc] init];
    request.requestString = requestString;
    request.delegate = delegate;
    [request downloadFromdict:dict];
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
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]&&[NSFileManager isTimeOutWithPath:path timeOut:60*60]==NO&&type!=ZBRequestTypeRefresh) {
        
        NSData *data = [NSData dataWithContentsOfFile:path];
    
        ZBLog(@"Read cache");
        [request.downloadData appendData:data];

        if ([request.delegate respondsToSelector:@selector(urlRequestFinished:)]) {
            [request.delegate urlRequestFinished:request];
        }
       
        return request;
    }else{

        [request startRequest];
       
 
    }

    [[ZBRequestManager shareManager] setRequestObject:request forkey:requestString];
    
    return request;
}


- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    [self willChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
    _timeoutInterval = timeoutInterval;
    [self didChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
}

#pragma mark - NSURLSessionDelegate

/**
 *  1.接收到服务器响应的时候调用该方法
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{

  //  ZBLog(@"didReceiveResponse--%@",[NSThread currentThread]);
    
    
    completionHandler(NSURLSessionResponseAllow);
    
}
/**
 *  接收到服务器返回数据的时候会调用该方法，如果数据较大那么该方法可能会调用多次
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   // ZBLog(@"%ld---%@--",_downloadData.length,[NSThread currentThread]);
   
    [self.downloadData appendData:data];
}

/**
 *  请求完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
   // ZBLog(@"didCompleteWithError--%@",[NSThread currentThread]);
    
    if(error == nil)
    {

        NSString *path =[[ZBCacheManager shareCacheManager] pathWithfileName:_requestString];
        

        [[ZBCacheManager shareCacheManager] setMutableData:_downloadData WriteToFile:path];
        
        if ([_delegate respondsToSelector:@selector(urlRequestFinished:)]) {
            [_delegate urlRequestFinished:self];
        }
 
        [[ZBRequestManager shareManager] removeRequestForkey:_requestString];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    }else{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //错误信息
         ZBLog(@"error:%@",[error localizedDescription]);
        self.error=nil;
        self.error=error;
       
        if ([_delegate respondsToSelector:@selector(urlRequestFailed:)]) {
            [_delegate urlRequestFailed:self];
        }
        
    }
}
#pragma mark - get Request
/**
 *  get
 */
- (void)startRequest
{
     ZBLog(@"start Request");
    if (_dataTask) {
        [_dataTask cancel];
        
        
    }
    
    NSString *string = [self.requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:string];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeoutInterval];
    
    _dataTask = [self.session dataTaskWithRequest:request];
    
    [_dataTask resume];
}

#pragma mark - post Request
/**
 *  post
 *
 *  @param dict 字典
 */
- (void)downloadFromdict:(NSDictionary *)dict;{
    
    if (_dataTask) {
        [_dataTask cancel];
        
    }
    
    
    NSString *string = [_requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:string];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    
    request.HTTPMethod = @"POST";
    
    [request setTimeoutInterval:_timeoutInterval];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *key in dict) {
        id obj = [dict objectForKey:key];
        NSString *str = [NSString stringWithFormat:@"%@=%@",key,obj];
        [array addObject:str];
    }
    NSString *dataStr = [array componentsJoinedByString:@"&"];
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    
    _dataTask = [self.session dataTaskWithRequest:request];
    
    [_dataTask resume];
    
    
}


@end
