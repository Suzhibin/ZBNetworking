//
//  NSDictionary+Log.m
//  ZBNetworkingDome
//
//  Created by NQ UEC on 16/9/18.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "NSDictionary+Log.h"

@implementation NSDictionary (Log)
- (NSString *)descriptionWithLocale:(id)locale{

    return [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}
@end
