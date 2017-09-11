//
//  NSFileManager+ZBPathMethod.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/9/11.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (ZBPathMethod)

/**
 *   判断指定路径下的文件，是否超出规定时间的方法
 *
 *  @param path 文件路径
 *  @param time NSTimeInterval 毫秒
 *
 *  @return 是否超时
 */
+(BOOL)isTimeOutWithPath:(NSString *)path timeOut:(NSTimeInterval)time;

@end

@interface NSString (UTF8Encoding)

/**
 UTF8
 
 @param urlString   URL
 @return 已经编码的URL
 */
+ (NSString *)zb_stringUTF8Encoding:(NSString *)urlString;

/**
 拼接URL与参数
 
 @param urlString   URL
 @param parameters  参数
 @return 已经拼接的URL
 */
+ (NSString *)zb_urlString:(NSString *)urlString appendingParameters:(id)parameters;

@end
