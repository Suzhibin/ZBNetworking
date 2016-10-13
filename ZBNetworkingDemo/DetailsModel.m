//
//  DetailsModel.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/6/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "DetailsModel.h"

@implementation DetailsModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    //  NSLog(@"undefinedKey:%@",key);
}

-(instancetype)initWithDict:(NSDictionary *)dict
{
  if (self=[super init]) {
         [self setValuesForKeysWithDictionary:dict];
    }
   return self;
 }

@end
