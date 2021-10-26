//
//  HomeModel.m
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2018/10/12.
//  Copyright © 2018年 Suzhibin. All rights reserved.
//

#import "HomeModel.h"

@implementation HomeModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    //  NSLog(@"undefinedKey:%@",key);
//    if ([key isEqualToString:@"id"]) {
//        self.wid=value;
//    }
}
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self=[super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
