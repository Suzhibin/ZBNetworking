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
+ (ZBCacheManager *)sharedInstance;

/**
 获取沙盒Home的文件目录

 @return Home 路径
 */
- (NSString *)homePath;

/**
  获取沙盒Document的文件目录

 @return Document 路径
 */
- (NSString *)documentPath;

/**
  获取沙盒Library的文件目录
 
 @return Document 路径
 */
- (NSString *)libraryPath;

/**
 获取沙盒Library/Caches的文件目录
 
 @return Library/Caches 路径
 */
- (NSString *)cachesPath;

/**
 获取沙盒tmp的文件目录
 
 @return tmp路径
 */
- (NSString *)tmpPath;

/**
 获取沙盒自创建的ZBKit文件目录
 
 @return Library/Caches/ZBKit路径
 */
- (NSString *)ZBKitPath;

/**
 获取沙盒自创建的AppCache文件目录
 
 @return Library/Caches/ZBKit/AppCache路径
 */
- (NSString *)ZBAppCachePath;

/**
 创建沙盒文件夹

 @param path    路径
 */
- (void)createDirectoryAtPath:(NSString *)path;

/**
 把内容,写入到文件
 
 @param content    数据
 @param path    路径
 */
- (BOOL)setContent:(NSObject *)content writeToFile:(NSString *)path;

/**
 判断沙盒是否对应的值

 @param path    路径

 @return YES/NO
 */
- (BOOL)isExistsAtPath:(NSString *)path;

/**
 *  查找存储的文件 默认缓存路径/Library/Caches/ZBKit/AppCache
 *  @param  key  存储的文件
 *
 *  @return 根据存储的文件，返回在本地的存储路径
 */
- (NSString *)pathWithFileName:(NSString *)key;

/**
 拼接路径与编码后的文件

 @param key       文件
 @param CachePath 自定义路径

 @return 完整的文件路径
 */
- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)CachePath;

/**
 * 显示data文件缓存大小 默认缓存路径/Library/Caches/ZBKit/AppCache
 * Get the size used by the disk cache
 */
- (NSUInteger)getCacheSize;

/**
 * 显示data文件缓存个数 默认缓存路径/Library/Caches/ZBKit/AppCache
 * Get the number of file in the disk cache
 */
- (NSUInteger)getCacheCount;

/**
 显示文件大小

 @param path        自定义路径

 @return size       大小
 */
- (NSUInteger)getFileSizeWithpath:(NSString *)path;

/**
 显示文件个数
 
 @param  path       自定义路径
 
 @return count      数量
 */
- (NSUInteger)getFileCountWithpath:(NSString *)path;
/**
 显示文件的大小单位
 
 @param size        得到的大小
 
 @return 显示的单位 GB/MB/KB
 */
- (NSString *)fileUnitWithSize:(float)size;

/**
  磁盘总空间大小
 
 @return size       大小
 */
- (NSUInteger)diskSystemSpace;

/**
 磁盘空闲系统空间

 @return size       大小
 */
- (NSUInteger)diskFreeSystemSpace;

/**
 *返回某个路径下的所有数据文件
 * @param path      路径
 * @return array    所有数据
 */
- (NSArray *)getCacheFileWithPath:(NSString *)path;

/**
 *  缓存文件的属性
 *  @param key      缓存文件
 */
-(NSDictionary* )getFileAttributes:(NSString *)key;

/**
 *  自动清除过期缓存
 *  Remove all expired cached file from disk
 */
- (void)automaticCleanCache;

/** 
 *  自动清除过期缓存
 *  Remove all expired cached file from disk
 *  @param path   路径
 *  @param operation  block 后续操作
 */
- (void)automaticCleanCacheWithPath:(NSString *)path Operation:(ZBCacheManagerBlock)operation;

/**
 *  清除某一个缓存文件    默认路径/Library/Caches/ZBKit/AppCache
 *  @param key 请求的协议地址
 */
- (void)clearCacheForkey:(NSString *)key;

/**
 *  清除某一个缓存文件   默认路径/Library/Caches/ZBKit/AppCache
 *
 *  @param key        请求的协议地址
 *  @param operation  block 后续操作
 */
- (void)clearCacheForkey:(NSString *)key operation:(ZBCacheManagerBlock)operation;

/**
 *  清除某一个缓存文件   自定义路径
 *  @param key        请求的协议地址
 *  @param path       自定义路径
 *  @param operation  block 后续操作
 */
- (void)clearCacheForkey:(NSString *)key path:(NSString *)path operation:(ZBCacheManagerBlock)operation;

/**
 *  清除全部缓存 /Library/Caches/ZBKit/AppCache
 *  Clear AppCache disk cached
 */
- (void)clearCache;

/**
 *  清除全部缓存 /Library/Caches/ZBKit/AppCache
 *  @param operation block 后续操作
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
 @param operation block 后续操作
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



