//
//  RootModel.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/6/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "RootModel.h"

@implementation RootModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    //  NSLog(@"undefinedKey:%@",key);
    if ([key isEqualToString:@"id"]) {
        self.wid=value;
    }
}
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self=[super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

@end
