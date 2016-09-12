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
    }
    return self;
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

- (void)clearDelegateForKey:(NSString *)key{
    if(!key)return;
    self.manager=[_requestDic objectForKey:key];
 
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




