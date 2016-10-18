//
//  ZBWebViewManager.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 16/10/18.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ZBWebViewManagerBlock)();

@interface ZBWebViewManager : NSObject

+ (ZBWebViewManager *)shareManager;

/**
 判断web缓存文件是否存在

 @param htmlString html地址

 @return YES/NO
 */
- (BOOL)fileAtPath:(NSString *)htmlString;

/**
 判断web缓存文件是否存在
 
 @param htmlString html地址
 @param path 路径
 
 @return YES/NO
 */
- (BOOL)fileAtPath:(NSString *)htmlString inPath:(NSString *)path;

/**
 编码

 @param htmlString html地址

 @return 编码后的字符串
 */
- (NSString *)htmlString:(NSString *)htmlString;


/**
 写入沙盒

 @param htmlString html地址
 */
- (void)writeToCache:(NSString *)htmlString;
- (void)writeToCache:(NSString *)htmlString Operation:(ZBWebViewManagerBlock)operation;

@end
