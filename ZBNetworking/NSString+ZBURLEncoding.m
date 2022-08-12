//
//  NSString+ZBURLEncoding.m
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2022/8/11.
//  Copyright © 2022 Suzhibin. All rights reserved.
//

#import "NSString+ZBURLEncoding.h"

@implementation NSString (ZBURLEncoding)
+ (NSString *)zb_stringEncoding:(NSString *)urlString{
    return [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

+ (NSString *)zb_urlString:(NSString *)urlString appendingParameters:(id)parameters{
    if (parameters==nil) {
        return urlString;
    }else{
        NSString *parametersString;
        if ([parameters isKindOfClass:[NSDictionary class]]){
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSString *key in parameters) {
                id obj = [parameters objectForKey:key];
                NSString *str = [NSString stringWithFormat:@"%@=%@",key,obj];
                [array addObject:str];
            }
            parametersString = [array componentsJoinedByString:@"&"];
        }else{
            parametersString =[NSString stringWithFormat:@"%@",parameters] ;
        }
        return [urlString stringByAppendingString:[NSString stringWithFormat:@"?%@",parametersString]];
    }
}
@end

@implementation ZBRequestTool

+ (id)formaParameters:(id)parameters filtrationCacheKey:(NSArray *)filtrationCacheKey{
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [mutableParameters removeObjectsForKeys:filtrationCacheKey];
        return [mutableParameters copy];
    }else {
        return parameters;
    }
}

@end
