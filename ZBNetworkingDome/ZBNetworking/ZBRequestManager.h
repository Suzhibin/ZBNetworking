//
//  ZBRequestManager.h
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




#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ZBURLSessionManager;

#define DEBUG_LOG 0

#if(DEBUG_LOG == 1)
# define ZBLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[第 %d 行] Log:\n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define ZBLog(...);
#endif

//请求管理类： 需要将request对象的生命周期通过ZBRequestManager来维护
@interface ZBRequestManager : NSObject


@property ( nonatomic, strong) ZBURLSessionManager *manager;

/**
 *  用于维护多个request对象
 */
@property ( nonatomic, strong) NSMutableDictionary *requestDic;

/**
 *  用于维护 请求头的request对象
 */
@property (nonatomic,copy) NSString *value;

+(ZBRequestManager *)shareManager;

/**
 *
 *  @param obj request 对象
 *  @param key
 */
- (void)setRequestObject:(id)obj forkey:(NSString *)key;

/**
 *
 *  @param key 
 */
- (void)removeRequestForkey:(NSString *)key;

/**
 *
 *
 *  @param key request 对象
 *
 *  @return 
 */
- (NSString *)objectRequestForKey:(NSString *)key;

/**
 *
 *  将request的delegate置空
 *  在ViewController被销毁之前,将delegate置为nil
 *
 *  @return  请求的协议地址
 */
- (void)clearDelegateForKey:(NSString *)key;


/**
 *  请求会话管理,取消请求任务
 *  Invalidates the managed session, optionally canceling pending tasks.
 *
 *  @param cancelPendingTasks Whether or not to cancel pending tasks.
 */
- (void)requestToCancel:(BOOL)cancelPendingTasks;



@end










