//
//  ZBRequestManager.m
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


#import "ZBRequestManager.h"
#import "ZBURLSessionManager.h"
#import "ZBCacheManager.h"

static ZBRequestManager *RequestManager=nil;

@implementation ZBRequestManager{

 //  NSMutableDictionary*_requestDic;
    
}
+ (ZBRequestManager *)shareManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RequestManager = [[ZBRequestManager alloc] init];
    });
    return RequestManager;
}


- (id)init{
    self = [super init];
    if (self) {
        _requestDic =[[NSMutableDictionary alloc] init];
        self.mutableHTTPRequestHeaders = [[NSMutableDictionary alloc]init];
        self.channelArray=[[NSMutableArray alloc]init];
    }
    return self;
}

- (void)setValue:(NSString *)value forHeaderField:(NSString *)field
{
    [self.mutableHTTPRequestHeaders setValue:value forKey:field];
}

- (NSString *)objectHeaderForKey:(NSString *)key{
    
    return  [self.mutableHTTPRequestHeaders objectForKey:key];
    
}

- (void)removeHeaderForkey:(NSString *)key{
    
    if(!key)return;
    [self.mutableHTTPRequestHeaders removeObjectForKey:key];
    
}

- (BOOL)isAddForkey:(NSString *)url
{
    return  [self.channelArray containsObject: url];
}

- (void)addObjectWithForkey:(NSString *)url
{
    if ([self isAddForkey:url]==1) {
        ZBLog(@"已经包含该频道");
    }else{
        [self.channelArray addObject:url];
    }
    
}

- (void)removeObjectWithForkey:(NSString *)url
{
    if ([self isAddForkey:url]==1) {
        [self.channelArray removeObject:url];
        
    }else{
        ZBLog(@"已经删除该频道");
    }
    
}

- (void)setRequestObject:(id)obj forkey:(NSString *)key{

    if (obj) {
        [_requestDic setObject:obj forKey:key];
    }
}

- (void)removeRequestForkey:(NSString *)key{
   
    if(!key)return;
    [_requestDic removeObjectForKey:key];

}
//_requestDic 已被remove 此方法暂时不用
- (void)clearDelegateForKey:(NSString *)key{
    if(!key)return;
    self.manager=[_requestDic objectForKey:key];;
    self.manager.delegate = nil;
}

- (void)requestToCancel:(BOOL)cancelPendingTasks
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (cancelPendingTasks) {
         
            [self.manager.session invalidateAndCancel];
        } else {
            
            [self.manager.session finishTasksAndInvalidate];
        }

    });
}





@end




