//
//  NSFileManager+ZBPathMethod.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/9/11.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import "NSFileManager+ZBPathMethod.h"

@implementation NSFileManager (ZBPathMethod)
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

@implementation NSString (UTF8Encoding)

+ (NSString *)zb_stringUTF8Encoding:(NSString *)urlString{
    return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)zb_urlString:(NSString *)urlString appendingParameters:(id)parameters{
    if (parameters==nil) {
        return urlString;
    }else{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSString *key in parameters) {
            id obj = [parameters objectForKey:key];
            NSString *str = [NSString stringWithFormat:@"%@=%@",key,obj];
            [array addObject:str];
        }
        
        NSString *parametersString = [array componentsJoinedByString:@"&"];
        return  [urlString stringByAppendingString:[NSString stringWithFormat:@"?%@",parametersString]];
    }
}

@end
