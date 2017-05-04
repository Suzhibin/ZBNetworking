//
//  ZBNetworkManager.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 17/1/10.
//  Copyright © 2017年 Suzhibin. All rights reserved.
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
        
        self.request.responseObj=[[NSMutableData alloc]init];
        
        self.request.timeoutInterval=15;
        
    }
    return self;
}

+ (ZBNetworkManager *)requestWithConfig:(requestConfig)config  success:(requestSuccess)success failed:(requestFailed)failed{
    return [ZBNetworkManager requestWithConfig:config progress:nil success:success failed:failed];
}

+ (ZBNetworkManager *)requestWithConfig:(requestConfig)config progress:(progressBlock)progress  success:(requestSuccess)success failed:(requestFailed)failed{
    
    ZBNetworkManager *manager=[[ZBNetworkManager alloc]init];
    
    config ? config(manager.request) : nil;
    
    if (manager.request.methodType==ZBMethodTypePOST) {
        [manager POST:manager.request.urlString parameters:manager.request.parameters progress:progress success:success failed:failed];
    }else{
        if (manager.request.apiType==ZBRequestTypeOffline) {
            [manager offlineDownload:manager.request.urlArray apiType:manager.request.apiType success:success failed:failed];
        }else{
            [manager GET:manager.request.urlString parameters:manager.request.parameters apiType:manager.request.apiType progress:progress success:success failed:failed];
        }
    }
    return manager;
}

- (void)offlineDownload:(NSMutableArray *)downloadArray apiType:(apiType)type success:(requestSuccess)success failed:(requestFailed)failed{
    if (downloadArray.count==0)return;
    [downloadArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
        [self GET:urlString parameters:nil apiType:type progress:nil success:success failed:failed ];
    
    }];
}

- (void)GET:(NSString *)urlString success:(requestSuccess)success failed:(requestFailed)failed{
    [self GET:urlString parameters:nil success:success failed:failed];
}

- (void)GET:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)success failed:(requestFailed)failed{
    [self GET:urlString parameters:parameters progress:nil success:success failed:failed];
}

- (void)GET:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    [self GET:urlString parameters:parameters apiType:ZBRequestTypeDefault progress:progress success:success failed:failed];
}

- (void)GET:(NSString *)urlString parameters:(id)parameters apiType:(apiType)type  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{

    if (![urlString isKindOfClass:NSString.class]) {
        urlString = nil;
    }

    if ([[ZBCacheManager sharedInstance]diskCacheExistsWithKey:urlString]&&type!=ZBRequestTypeRefresh&&type!=ZBRequestTypeOffline){
        
        [[ZBCacheManager sharedInstance]getCacheDataForKey:urlString value:^(NSData *data,NSString *filePath) {
            [self.request.responseObj appendData:data];
            success ? success(self.request.responseObj ,type) : nil;
        }];
        
    }else{
        [self GETRequest:urlString parameters:parameters progress:progress success:success failed:failed];
    }
}

- (void)GETRequest:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    if(!urlString)return;
    [self.AFmanager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
        progress ? progress(downloadProgress) : nil;
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject) {
   
       [[ZBCacheManager sharedInstance] storeContent:responseObject forKey:urlString];
        
        success ? success(responseObject,self.request.apiType) : nil;
        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
        failed ? failed(error) : nil;
    }];

    
}
- (void)POST:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)success failed:(requestFailed)failed{
    [self POST:urlString parameters:parameters progress:nil success:success failed:failed];
}

- (void)POST:(NSString *)urlString parameters:(id)parameters progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    if(!urlString)return;
    [self.AFmanager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress ? progress(uploadProgress) : nil;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success ? success(responseObject,self.request.apiType) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed ? failed(error) : nil;
    }];
    
}

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
