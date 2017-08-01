//
//  ZBNetworkManager.m
//  ZBNetworkingDemo
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
#import <AFNetworkActivityIndicatorManager.h>

@interface ZBNetworkManager()
@property (nonatomic, strong) AFHTTPSessionManager *AFmanager;

@property AFNetworkReachabilityStatus netStatus;
@end

@implementation ZBNetworkManager

+ (ZBNetworkManager *)sharedInstance {
    static ZBNetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZBNetworkManager alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        self.request.timeoutInterval=15;
    }
    return self;
}
#pragma mark - GET/POST 配置请求
+ (void)requestWithConfig:(requestConfig)config  success:(requestSuccess)success failed:(requestFailed)failed{
    [[ZBNetworkManager sharedInstance]requestWithConfig:config success:success failed:failed];
}

+ (void)requestWithConfig:(requestConfig)config  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    [[ZBNetworkManager sharedInstance]requestWithConfig:config progress:progress success:success failed:failed];
}

- (void)requestWithConfig:(requestConfig)config success:(requestSuccess)success failed:(requestFailed)failed{
    return [self requestWithConfig:config progress:nil success:success failed:failed];
}

- (void)requestWithConfig:(requestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    config ? config(self.request) : nil;
    if (self.request.methodType==POST) {
        [self POST:self.request.urlString parameters:self.request.parameters progress:progress success:success failed:failed];
    }else{
        if (self.request.apiType==ZBRequestTypeOffline) {
            [self offlineDownload:self.request.urlArray apiType:self.request.apiType success:success failed:failed];
        }else{
            [self GET:self.request.urlString parameters:self.request.parameters apiType:self.request.apiType progress:progress success:success failed:failed];
        }
    }
}

- (void)offlineDownload:(NSMutableArray *)downloadArray apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed{
    if (downloadArray.count==0)return;
    [downloadArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
        [self GET:urlString parameters:nil apiType:type progress:nil success:success failed:failed ];
    }];
}

#pragma mark - GET 请求
- (void)GET:(NSString *)urlString success:(requestSuccess)success failed:(requestFailed)failed{
    [ZBNetworkManager GET:urlString success:success failed:failed];
}

- (void)GET:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)success failed:(requestFailed)failed{
    [ZBNetworkManager GET:urlString parameters:parameters success:success failed:failed];
}

- (void)GET:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    [ZBNetworkManager GET:urlString parameters:parameters progress:progress success:success failed:failed];
}

- (void)GET:(NSString *)urlString parameters:(id)parameters apiType:(apiType)type progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    [ZBNetworkManager GET:urlString parameters:parameters apiType:type progress:progress success:success failed:failed];
}

+ (ZBNetworkManager *)GET:(NSString *)urlString success:(requestSuccess)success failed:(requestFailed)failed{
   return [ZBNetworkManager GET:urlString parameters:nil success:success failed:failed];
}

+ (ZBNetworkManager *)GET:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)success failed:(requestFailed)failed{
   return [ZBNetworkManager GET:urlString parameters:parameters progress:nil success:success failed:failed];
}

+ (ZBNetworkManager *)GET:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
  return [ZBNetworkManager GET:urlString parameters:parameters apiType:ZBRequestTypeDefault progress:progress success:success failed:failed];
}

+ (ZBNetworkManager *)GET:(NSString *)urlString parameters:(id)parameters apiType:(apiType)type  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{

    if([urlString isEqualToString:@""]||urlString==nil)return nil;
    
    if (![urlString isKindOfClass:NSString.class]) {
        urlString = nil;
    }
    ZBNetworkManager *manager = [[ZBNetworkManager alloc] init];
    manager.request.urlString=urlString;
    manager.request.parameters=parameters;
    manager.request.apiType=type;
    manager.success=success;
    manager.failed=failed;
    manager.progres=progress;
    
    NSString *key = [manager.request stringUTF8Encoding:[manager.request urlString:urlString appendingParameters:parameters]];
    
    if ([[ZBCacheManager sharedInstance]diskCacheExistsWithKey:key]&&type!=ZBRequestTypeRefresh&&type!=ZBRequestTypeOffline&&type!=ZBRequestTypeRefreshMore){
        
        [[ZBCacheManager sharedInstance]getCacheDataForKey:key value:^(id responseObj,NSString *filePath) {
            [manager.request.responseObj appendData:responseObj];
            success ? success(manager.request.responseObj ,type) : nil;
        }];
        
    }else{
        //传urlString 不传key
        [manager GETRequest:urlString parameters:parameters progress:progress success:success failed:failed];
    }
    return manager;
}

- (void)GETRequest:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    [self.AFmanager GET:[self.request stringUTF8Encoding:urlString] parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
        progress ? progress(downloadProgress) : nil;
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject) {
        
        NSString * key= [self.request stringUTF8Encoding:[self.request urlString:urlString appendingParameters:parameters]];

       [[ZBCacheManager sharedInstance] storeContent:responseObject forKey:key];
        
        success ? success(responseObject,self.request.apiType) : nil;
        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
        failed ? failed(error) : nil;
    }];    
}
#pragma mark - POST 请求
- (void)POST:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)success failed:(requestFailed)failed{
    [ZBNetworkManager POST:urlString parameters:parameters success:success failed:failed];
}

- (void)POST:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    [ZBNetworkManager POST:urlString parameters:parameters progress:progress success:success failed:failed];
}

+ (ZBNetworkManager *)POST:(NSString *)urlString parameters:(NSDictionary*)parameters success:(requestSuccess)success failed:(requestFailed)failed{
    
    return  [ZBNetworkManager POST:urlString parameters:parameters progress:nil success:success failed:failed];
}

+ (ZBNetworkManager *)POST:(NSString *)urlString parameters:(NSDictionary*)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    ZBNetworkManager *manager  = [[ZBNetworkManager alloc] init];
    manager.request.urlString = urlString;
    manager.request.parameters=parameters;
    manager.success=success;
    manager.failed=failed;
     manager.progres=progress;
    [manager POSTRequest:urlString parameters:parameters progress:progress success:success failed:failed];
    return  manager;
}

- (void)POSTRequest:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    if(!urlString)return;
    [self.AFmanager POST:[self.request stringUTF8Encoding:urlString] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress ? progress(uploadProgress) : nil;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success ? success(responseObject,self.request.apiType) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed ? failed(error) : nil;
    }];
    
}

#pragma mark - 其他配置
+ (void)requestToCancel:(BOOL)cancelPendingTasks{
    [[ZBNetworkManager sharedInstance].AFmanager invalidateSessionCancelingTasks:cancelPendingTasks];
}

+ (NSInteger)startNetWorkMonitoring{
    [ZBNetworkManager sharedInstance].netStatus=[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
   
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
         [ZBNetworkManager sharedInstance].netStatus=status;
        switch ( [ZBNetworkManager sharedInstance].netStatus)
        {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    return  [ZBNetworkManager sharedInstance].netStatus;
}

- (AFHTTPSessionManager*)AFmanager{
    if (!_AFmanager) {
        _AFmanager=[AFHTTPSessionManager manager];
        //和urlsession类 公用一个chche容器 返回类型全部是二进制
        _AFmanager.requestSerializer  = [AFHTTPRequestSerializer serializer];// 设置请求格式
        _AFmanager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 设置返回格式
        
        [[self.request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [_AFmanager.requestSerializer setValue:value forHTTPHeaderField:field];
        }];
        [_AFmanager.requestSerializer setTimeoutInterval:self.request.timeoutInterval];
        _AFmanager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript",nil];
        //如果你用的是自签名的证书
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        _AFmanager.securityPolicy = securityPolicy;
    }
    
    return _AFmanager;
}

- (ZBURLRequest*)request{
    if (!_request) {
        _request=[[ZBURLRequest alloc]init];
    }
    return _request;
}

@end
