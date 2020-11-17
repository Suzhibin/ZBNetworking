//
//  NSString+ZBUTF8Encoding.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2018/5/21.
//  Copyright © 2018年 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZBUTF8Encoding)

/**
 *  UTF8
 *
 *  @param urlString 编码前的url字符串
 *  @return 返回 编码后的url字符串
 */
+ (NSString *)zb_stringUTF8Encoding:(NSString *)urlString;

/**
 *  url字符串与parameters参数的的拼接
 *
 *  @param urlString url字符串
 *  @param parameters parameters参数
 *  @return 返回拼接后的url字符串
 */
+ (NSString *)zb_urlString:(NSString *)urlString appendingParameters:(id)parameters;

@end
