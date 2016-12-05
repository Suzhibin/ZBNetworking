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

static ZBRequestManager *requestManager=nil;

@implementation ZBRequestManager

+ (ZBRequestManager *)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestManager = [[ZBRequestManager alloc] init];
    });
    return requestManager;
}

- (NSMutableDictionary *)requestDic{
    
    if (!_requestDic) {
        _requestDic  = [[NSMutableDictionary alloc]init];
    }
    return _requestDic;
}

- (NSMutableArray *)channelUrlArray{
    
    if (!_channelUrlArray) {
        _channelUrlArray=[[NSMutableArray alloc]init];
    }
    return _channelUrlArray;
}

- (NSMutableArray *)channelNameArray{
    
    if (!_channelNameArray) {
        _channelNameArray=[[NSMutableArray alloc]init];
    }
    return _channelNameArray;
}

- (NSMutableDictionary *)mutableHTTPRequestHeaders{
    
    if (!_mutableHTTPRequestHeaders) {
        _mutableHTTPRequestHeaders  = [[NSMutableDictionary alloc]init];
    }
    return _mutableHTTPRequestHeaders;
}

- (void)setValue:(NSString *)value forHeaderField:(NSString *)field{
    [self.mutableHTTPRequestHeaders setValue:value forKey:field];
}

- (NSString *)objectHeaderForKey:(NSString *)key{
    return  [self.mutableHTTPRequestHeaders objectForKey:key];
}

- (void)removeHeaderForkey:(NSString *)key{
    if(!key)return;
    [self.mutableHTTPRequestHeaders removeObjectForKey:key];
}

- (BOOL)isAddForKey:(NSString *)key isUrl:(BOOL)isUrl{
   
    if (isUrl==YES) {
        @synchronized (self.channelUrlArray) {
            return  [self.channelUrlArray containsObject: key];
        }
    }else{
        @synchronized (self.channelNameArray) {
            return  [self.channelNameArray containsObject: key];
        }
    }
}

- (void)addObjectWithForKey:(NSString *)key isUrl:(BOOL)isUrl{
    if (isUrl==YES) {
       
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            ZBLog(@"已经包含该栏目URL");
        }else{
            @synchronized (self.channelUrlArray) {
                [self.channelUrlArray addObject:key];
            }
        }
    }else{
       
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            ZBLog(@"已经包含该栏目名字");
        }else{
            @synchronized (self.channelNameArray ) {
                [self.channelNameArray addObject:key];
            }
        }
    }
}

- (void)removeObjectWithForkey:(NSString *)key isUrl:(BOOL)isUrl{
    if (isUrl==YES) {
         if ([self isAddForKey:key isUrl:isUrl]==1) {
             @synchronized (self.channelUrlArray) {
                   [self.channelUrlArray removeObject:key];
             }
        }else{
            ZBLog(@"已经删除该栏目URL");
        }

    }else{
    
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            @synchronized (self.channelNameArray) {
                [self.channelNameArray removeObject:key];
            }
        }else{
            ZBLog(@"已经删除该栏目名字");
        }
    }
}

- (void)setRequestObject:(id)obj forkey:(NSString *)key{

    if (obj) {
        [self.requestDic setObject:obj forKey:key];
    }
}

- (void)removeRequestForkey:(NSString *)key{
   
    if(!key)return;
    [self.requestDic removeObjectForKey:key];

}
//_requestDic 已被remove 此方法暂时不用
- (void)clearDelegateForKey:(NSString *)key{
    if(!key)return;
    self.manager=[self.requestDic objectForKey:key];;
    self.manager.delegate = nil;
}




@end




