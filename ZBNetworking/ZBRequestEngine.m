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
        sharedInstance = [ZBRequestEngine manager];
        //无条件地信任服务器端返回的证书。
        sharedInstance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        sharedInstance.securityPolicy = [AFSecurityPolicy defaultPolicy];
        sharedInstance.securityPolicy.allowInvalidCertificates = YES;
        sharedInstance.securityPolicy.validatesDomainName = NO;
        /*因为与缓存互通 服务器返回的数据 必须是二进制*/
        sharedInstance.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        sharedInstance.operationQueue.maxConcurrentOperationCount = 5;
        sharedInstance.requestSerializer.timeoutInterval = 15.f;
        sharedInstance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript",nil];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        //忽略系统缓存
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
        
    });
    return sharedInstance;
}

- (NSString *)cancelRequest:(NSString *)urlString{
    
    if (self.dataTasks.count <= 0) {
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
