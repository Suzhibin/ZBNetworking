//
//  NSFileManager+pathMethod.m
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


#import "NSFileManager+pathMethod.h"

@implementation NSFileManager (pathMethod)
+(BOOL)isTimeOutWithPath:(NSString *)path timeOut:(NSTimeInterval)time{

    NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
  
    NSDate *current = [info objectForKey:NSFileModificationDate];

    NSDate *date = [NSDate date];
 
    NSTimeInterval currentTime = [date timeIntervalSinceDate:current];

    if (currentTime>time) {

        return YES;
    }else{

        return NO;
    }
    
}
@end
