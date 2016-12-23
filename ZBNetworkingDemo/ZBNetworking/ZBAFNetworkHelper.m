//
//  ZBAFNetworkHelper.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 16/12/20.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "ZBAFNetworkHelper.h"
#import "ZBCacheManager.h"
#import "NSFileManager+pathMethod.h"
#import <AFNetworkActivityIndicatorManager.h>
static const NSInteger timeOut = 60*60;
@interface ZBAFNetworkHelper()
@property (nonatomic, strong) AFHTTPSessionManager *AFmanager;

@property AFNetworkReachabilityStatus netStatus;
@end
@implementation ZBAFNetworkHelper
/**
 Returns the default shared `XMCenter` singleton object.
 */
+ (ZBAFNetworkHelper *)sharedHelper {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZBAFNetworkHelper alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        
        self.request.responseObj=[[NSMutableData alloc]init];
        
        self.request.timeoutInterval=15;
        
    }
    return self;
}
- (void)dealloc {
    if (self.AFmanager) {
        [self requestToCancel:YES];
    }
}

+ (ZBAFNetworkHelper*)requestWithConfig:(requestConfig)config  success:(requestSuccess)success failed:(requestFailed)failed{
    return [ZBAFNetworkHelper requestWithConfig:config progress:nil success:success failedBlock:failed];
}

+ (ZBAFNetworkHelper*)requestWithConfig:(requestConfig)config progress:(progressBlock)progressBlock  success:(requestSuccess)success failedBlock:(requestFailed)failed{
   
    ZBAFNetworkHelper *helper=[[ZBAFNetworkHelper alloc]init];
    
    config ? config(helper.request) : nil;
    
    if (helper.request.methodType==ZBMethodTypePOST) {
        [helper POST:helper.request.urlString parameters:helper.request.parameters progress:progressBlock success:success failed:failed];
    }else{
        if (helper.request.apiType==ZBRequestTypeOffline) {
            [helper offlineDownload:helper.request.urlArray apiType:helper.request.apiType success:success failed:failed];
        }else{
            [helper GET:helper.request.urlString parameters:helper.request.parameters apiType:helper.request.apiType progress:progressBlock success:success failed:failed];
        }
    }
    return helper;
}

- (void)offlineDownload:(NSMutableArray *)downloadArray apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed{
    if (downloadArray.count==0)return;
    [downloadArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
        [self GET:urlString parameters:nil apiType:type progress:nil success:success failed:failed];
    }];
}

- (void)GET:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)success failed:(requestFailed)failed{
    [self GET:urlString parameters:parameters progress:nil success:success failed:failed];
}

- (void)GET:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progressBlock success:(requestSuccess)success failed:(requestFailed)failed{
    
    [self GET:urlString parameters:parameters apiType:ZBRequestTypeDefault progress:progressBlock success:success failed:failed];
}

- (void)GET:(NSString *)urlString parameters:(id)parameters apiType:(apiType)type progress:(progressBlock)progressBlock success:(requestSuccess)success failed:(requestFailed)failed{
    
    NSString *path =[[ZBCacheManager sharedCacheManager] pathWithFileName:urlString];
    
    if ([[ZBCacheManager sharedCacheManager]fileExistsAtPath:path]&&[NSFileManager isTimeOutWithPath:path timeOut:timeOut]==NO&&type!=ZBRequestTypeRefresh&&type!=ZBRequestTypeOffline){
        ZBLog(@"AF cache");
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        [self.request.responseObj appendData:data];
        
        success ? success(self.request.responseObj ,self.request.apiType) : nil;
    }else{
        
        [self GET:urlString parameters:parameters progress:progressBlock success:success failed:failed path:path];
    }
}

- (void)GET:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progressBlock success:(requestSuccess)success failed:(requestFailed)failed path:(NSString *)path{
    if(!urlString)return;
    ZBLog(@"AF get");
    [self.AFmanager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            
        progressBlock ? progressBlock(downloadProgress) : nil;
            
    }success:^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject) {
            
        [[ZBCacheManager sharedCacheManager] setMutableData:responseObject writeToFile:path];
            
        success ? success(responseObject,self.request.apiType) : nil;
            
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
            failed ? failed(error) : nil;
    }];


}

- (void)POST:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)success failed:(requestFailed)failed{
    [self POST:urlString parameters:parameters progress:nil success:success failed:failed];
}

- (void)POST:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progressBlock success:(requestSuccess)success failed:(requestFailed)failed{
    if(!urlString)return;
    ZBLog(@"AF POST");
    [self.AFmanager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progressBlock ? progressBlock(uploadProgress) : nil;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success ? success(responseObject,self.request.apiType) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed ? failed(error) : nil;
    }];
    
}

- (void)requestToCancel:(BOOL)cancelPendingTasks{
    [self.AFmanager invalidateSessionCancelingTasks:cancelPendingTasks];
}

- (NSInteger)startNetWorkMonitoring{
    self.netStatus=[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    // 设置网络状态改变后的处理
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        self.netStatus=status;
        switch (self.netStatus)
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
    return self.netStatus;
}

- (AFHTTPSessionManager*)AFmanager{
    if (!_AFmanager) {
        _AFmanager=[AFHTTPSessionManager manager];
        //和urlsession类 公用一个chche容器 返回类型全部是二进制
        _AFmanager.requestSerializer  = [AFHTTPRequestSerializer serializer];// 设置请求格式
        _AFmanager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 设置返回格式
    
        [[self.request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
                ZBLog(@"%@-%@",field,value);
            [_AFmanager.requestSerializer setValue:value forHTTPHeaderField:field];
        }];
        [_AFmanager.requestSerializer setTimeoutInterval:self.request.timeoutInterval];
        _AFmanager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript", nil];
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
