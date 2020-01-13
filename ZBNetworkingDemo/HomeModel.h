//
//  HomeModel.h
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2018/10/12.
//  Copyright © 2018年 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeModel : NSObject
@property (nonatomic,copy)NSString *wid; //id
@property (nonatomic,copy)NSString *name;//名字
@property (nonatomic,copy)NSString *detail;

-(instancetype)initWithDict:(NSDictionary *)dict;
@end
