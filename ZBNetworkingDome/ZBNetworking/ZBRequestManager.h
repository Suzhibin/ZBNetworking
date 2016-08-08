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

//请求管理类： 需要将request对象的生命周期通过ZBRequestManager来维护
@interface ZBRequestManager : NSObject


@property ( nonatomic, strong) ZBURLSessionManager *manager;


+(ZBRequestManager *)shareManager;

/**
 *
 *  @param obj request
 *  @param key 请求的协议地址
 */
- (void)setRequestObject:(id)obj forkey:(NSString *)key;

/**
 *
 *  @param key 请求的协议地址
 */
- (void)removeRequestForkey:(NSString *)key;

/**
 *
 *  将request的delegate置空
 *  在ViewController被销毁之前,将delegate置为nil
 *
 *  @return  请求的协议地址
 */
- (void)clearDelegateForKey:(NSString *)key;


/**
 *  无效的会话管理,选择是否取消任务
 *  Invalidates the managed session, optionally canceling pending tasks.
 *
 *  @param cancelPendingTasks Whether or not to cancel pending tasks.
 */
- (void)requestToCancel:(BOOL)cancelPendingTasks;



@end










