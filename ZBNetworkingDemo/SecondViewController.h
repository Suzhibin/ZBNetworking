//
//  SecondViewController.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 16/12/20.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "RootViewController.h"
//用于标识不同方法的请求
typedef NS_ENUM(NSInteger,functionType) {
    
    AFNetworking,
    sessionblock ,
    sessiondelegate

} ;
@interface SecondViewController : RootViewController
@property (nonatomic,assign) functionType functionType;
@end
