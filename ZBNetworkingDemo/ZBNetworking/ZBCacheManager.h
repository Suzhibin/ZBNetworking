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
 *  文件管理类:管理文件的路径,创建,存储,编码,显示,删除等功能.
 */
@interface ZBCacheManager : NSObject


//返回单例对象
+ (ZBCacheManager *)shareCacheManager;

/**
  获取沙盒Document的文件目录

 @return Document 路径
 */
- (NSString *)getDocumentDirectory;

/**
  获取沙盒Library的文件目录
 
 @return Document 路径
 */
- (NSString *)getLibraryDirectory;

/**
 获取沙盒Library/Caches的文件目录
 
 @return Library/Caches 路径
 */
- (NSString *)getCachesDirectory;

/**
 获取沙盒tmp的文件目录
 
 @return tmp路径
 */
- (NSString *)getTmpDirectory;

/**
 * 把二进制内容,写入到文件
 *  @param data 
 *  @param path 路径
 */
- (void)setMutableData:(NSMutableData*)data writeToFile:(NSString *)path;

/**
 判断沙盒是否对应的值

 @param path 路径

 @return YES NO
 */
- (BOOL)fileExistsAtPath:(NSString *)path;

/**
 *  查找存储的文件
 *  @param NSString fileName 存储的文件
 *
 *  @return 根据存储的文件，返回data在本地的存储路径
 */
- (NSString *)pathWithfileName:(NSString *)key;

/**
 * 显示缓存大小
 * Get the size used by the disk cache
 */
- (NSUInteger)getCacheSize;

/**
 * 显示缓存个数
 * Get the number of file in the disk cache
 */
- (NSUInteger)getCacheCount;

/**
 显示文件大小

 @param path 沙盒路径

 @return size 大小
 */
- (NSUInteger)getFileSizeWithpath:(NSString *)path;

/**
 显示文件的大小单位
 
 @param size 得到的大小
 
 @return 显示的单位 GB/MB/KB
 */
- (NSString *)fileUnitWithSize:(float)size;

/**
 显示文件个数
 
 @param path 沙盒路径

 @return count 大小
 */
- (NSUInteger)getFileCountWithpath:(NSString *)path;

/**
 *
 *  Remove all expired cached file from disk
 */
- (void)automaticCleanCache;

/** 
 *  
 *  Remove all expired cached file from disk
 *
 *  @param completion  block 后续操作
 */
- (void)automaticCleanCacheWithOperation:(ZBCacheManagerBlock)operation;

/**
 *  清除某一个缓存文件
 *  @param key 请求的协议地址
 */
- (void)clearCacheForkey:(NSString *)key;

/**
 *  清除某一个缓存文件
 *
 *  @param key       请求的协议地址
 *  @param Operation  block 后续操作
 */
- (void)clearCacheForkey:(NSString *)key operation:(ZBCacheManagerBlock)operation;

/**
 *  清除缓存
 *  Clear AppCache disk cached
 */
- (void)clearCache;

/**
 *  清除缓存
 *  @param Operation block 后续操作
 */
- (void)clearCacheOnOperation:(ZBCacheManagerBlock)operation;


/**
 清除某一路径下的文件

 @param path 路径
 */
- (void)clearDiskWithpath:(NSString *)path;

/**
 清除某一路径下的文件

 @param path      路径
 @param Operation block 后续操作
 */
- (void)clearDiskWithpath:(NSString *)path operation:(ZBCacheManagerBlock)operation;

/**
 Posted when a task name.
 */
FOUNDATION_EXPORT NSString * const PathDefault;

/**
 Posted when a task name.
 */
FOUNDATION_EXPORT NSString *const PathImager;
@end



