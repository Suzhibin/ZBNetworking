//
//  NSString+ZBURLEncoding.h
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2022/8/11.
//  Copyright © 2022 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ZBURLEncoding)

/**
 *  UTF8
 *
 *  @param urlString 编码前的url字符串
 *  @return 返回 编码后的url字符串
 */
+ (NSString *)zb_stringEncoding:(NSString *)urlString;

/**
 *  url字符串与parameters参数的的拼接
 *
 *  @param urlString url字符串
 *  @param parameters parameters参数
 *  @return 返回拼接后的url字符串
 */
+ (NSString *)zb_urlString:(NSString *)urlString appendingParameters:(id)parameters;

@end

@interface ZBRequestTool : NSObject

/**
 *  参数过滤变动参数
 *
 *  @param parameters           参数
 *  @param filtrationCacheKey   需要过滤的参数
 *  @return 返回过滤后的参数
 */
+ (id)formaParameters:(id)parameters filtrationCacheKey:(NSArray *)filtrationCacheKey;

@end
NS_ASSUME_NONNULL_END
