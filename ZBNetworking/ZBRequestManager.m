//
//  ZBRequestManager.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import "ZBRequestManager.h"
@implementation ZBRequestManager
#pragma mark - 配置请求
+ (void)requestWithConfig:(requestConfig)config success:(requestSuccess)success failed:(requestFailed)failed{
    [self requestWithConfig:config progress:nil success:success failed:failed];
}

+ (void)requestWithConfig:(requestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    ZBURLRequest *request=[[ZBURLRequest alloc]init];
    config ? config(request) : nil;
    
    [[ZBRequestEngine defaultEngine] sendRequest:request progress:progress success:success failed:failed];
}

+ (ZBBatchRequest *)sendBatchRequest:(batchRequestConfig)config success:(requestSuccess)success failed:(requestFailed)failed{
    return [self sendBatchRequest:config progress:nil success:success failed:failed];
}

+ (ZBBatchRequest *)sendBatchRequest:(batchRequestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed{
    
    ZBBatchRequest *batchRequest=[[ZBBatchRequest alloc]init];
    config ? config(batchRequest) : nil;
    
    if (batchRequest.urlArray.count==0)return nil;
    [batchRequest.urlArray enumerateObjectsUsingBlock:^(ZBURLRequest *request , NSUInteger idx, BOOL *stop) {
        [[ZBRequestEngine defaultEngine] sendRequest:request progress:progress success:success failed:failed];
    }];
    return batchRequest;
}

+ (void)cancelRequest:(NSString *)urlString completion:(cancelCompletedBlock)completion{
    if([urlString isEqualToString:@""]||urlString==nil)return;
    
    NSString *cancelUrlString=[[ZBRequestEngine defaultEngine]cancelRequest:urlString];
    if (completion) {
        completion(cancelUrlString);
    }
}

@end
