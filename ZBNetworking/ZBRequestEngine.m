//
//  ZBRequestEngine.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import "ZBRequestEngine.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "ZBCacheManager.h"
#import "ZBURLRequest.h"
@implementation ZBRequestEngine

+ (instancetype)defaultEngine{
    static ZBRequestEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZBRequestEngine alloc]init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //无条件地信任服务器端返回的证书。
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        self.securityPolicy = [AFSecurityPolicy defaultPolicy];
        self.securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy.validatesDomainName = NO;
        /*因为与缓存互通 服务器返回的数据 必须是二进制*/
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        self.operationQueue.maxConcurrentOperationCount = 5;
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript",nil];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

- (NSString *)cancelRequest:(NSString *)urlString{
    
    if (self.tasks.count <= 0) {
        return nil;
    }
    __block NSString *currentUrlString=nil;
    @synchronized (self.tasks) {
        [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[[task.currentRequest URL] absoluteString] isEqualToString:urlString]) {
                currentUrlString =[[task.currentRequest URL] absoluteString];
                [task cancel];
                *stop = YES;
            }
        }];
    }
    return currentUrlString;
}

@end
