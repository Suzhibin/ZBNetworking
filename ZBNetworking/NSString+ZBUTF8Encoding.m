//
//  NSString+ZBUTF8Encoding.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2018/5/21.
//  Copyright © 2018年 Suzhibin. All rights reserved.
//

#import "NSString+ZBUTF8Encoding.h"
#import <UIKit/UIKit.h>
@implementation NSString (ZBUTF8Encoding)

+ (NSString *)zb_stringUTF8Encoding:(NSString *)urlString{
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 9.0){
        return [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }else{
        return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}

+ (NSString *)zb_urlString:(NSString *)urlString appendingParameters:(id)parameters{
    if (parameters==nil) {
        return urlString;
    }else{
        NSString *parametersString;
        if ([parameters isKindOfClass:[NSDictionary class]]){
            NSMutableArray *array = [[NSMutableArray alloc] init];
            if ([parameters isKindOfClass:[NSDictionary class]]){
                for (NSString *key in parameters) {
                    id obj = [parameters objectForKey:key];
                    NSString *str = [NSString stringWithFormat:@"%@=%@",key,obj];
                    [array addObject:str];
                }
            }
            parametersString = [array componentsJoinedByString:@"&"];
        }else if ([parameters isKindOfClass:[NSArray class]]){
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in parameters) {
                for (NSString *key in dict) {
                    id obj = [dict objectForKey:key];
                    NSString *str = [NSString stringWithFormat:@"%@=%@",key,obj];
                    [array addObject:str];
                }
            }
            parametersString = [array componentsJoinedByString:@"&"];
        }else{
            parametersString =[NSString stringWithFormat:@"%@",parameters] ;
        }
        return [urlString stringByAppendingString:[NSString stringWithFormat:@"?%@",parametersString]];
    }
}

@end
