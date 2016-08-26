//
//  ZBCacheManager.h
//  ZBURLSessionManager
//
//  Created by NQ UEC on 16/6/8.
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

typedef void(^ZBCacheManagerBlock)();

/**
 *  缓存文件管理类:管理缓存文件的创建,存储,编码,显示,删除等功能.
 */

@interface ZBCacheManager : NSObject


//返回单例对象
+ (ZBCacheManager *)shareCacheManager;

/**
 *  @param data 
 *  @param path 路径
 */
- (void)setMutableData:(NSMutableData*)data WriteToFile:(NSString *)path;

/**
 *  @param NSString fileName 用data对应的请求地址
 *
 *  @return 根据请求的协议地址，返回data在本地的存储路径
 */
- (NSString *)pathWithfileName:(NSString *)key;

/**
 * 显示缓存大小
 * Get the size used by the disk cache
 */
- (NSUInteger)getFileSize;

/**
 * 显示缓存个数
 * Get the number of file in the disk cache
 */
- (NSUInteger)getFileCount;

/**
 *  Remove all expired cached file from disk
 */
- (void)automaticCleanDisk;

/**
 *  Remove all expired cached file from disk
 *
 *  @param completion  block 回调
 */
- (void)automaticCleanDiskWithCompletion:(ZBCacheManagerBlock)completion;

/**
 *  删除某一个缓存文件
 *  @param key 请求的协议地址
 */
- (void)removeDiskForkey:(NSString *)key;

/**
 *  删除某一个缓存文件
 *
 *  @param key       请求的协议地址
 *  @param Operation  block 回调
 */
- (void)removeDiskForkey:(NSString *)key Operation:(ZBCacheManagerBlock)Operation;

/**
 *  删除缓存
 *  Clear ZBCache disk cached
 */
- (void)clearDisk;

/**
 *  删除缓存
 *  @param completion block 回调
 */
- (void)clearDiskOnOperation:(ZBCacheManagerBlock)Operation;

/**
 Posted when a task name.
 */
FOUNDATION_EXPORT NSString * const PathDefault;


@end



