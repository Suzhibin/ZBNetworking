//
//  RootModel.h
//  ZBNetworking
//
//  Created by NQ UEC on 16/6/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RootModel : NSObject

@property (nonatomic,copy)NSString *wid; //id
@property (nonatomic,copy)NSString *name;//名字
@property (nonatomic,copy)NSString *detail;

-(instancetype)initWithDict:(NSDictionary *)dict;
@end
