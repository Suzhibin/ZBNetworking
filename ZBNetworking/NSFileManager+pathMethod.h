//
//  NSFileManager+pathMethod.h
//  ZBNetworking
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


@interface NSFileManager (pathMethod)


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

- (NSString *)stringUTF8Encoding:(NSString *)urlString;

- (NSString *)urlString:(NSString *)urlString appendingParameters:(id)parameters;

@end
