//
//  HomeModel.h
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2018/10/12.
//  Copyright © 2018年 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeModel : NSObject
//@property (nonatomic,copy)NSString *wid; //id
//@property (nonatomic,copy)NSString *name;//名字
//@property (nonatomic,copy)NSString *detail;

@property (nonatomic,copy)NSString *newsId;//新闻id
@property (nonatomic,copy)NSString *title;//新闻名字
//@property (nonatomic,strong)NSDictionary *iconDict;//图片
@property (nonatomic,copy)id icon;//图片
@property (nonatomic,copy)NSString *online;//时间
@property (nonatomic,copy)NSString *icon_small1;//图片icon_small1
@property (nonatomic,copy)NSString *icon_small2;//图片icon_small2
@property (nonatomic,copy)NSString *icon_small3;//图片icon_small3
@property (nonatomic,copy)NSString *type;//展示类型
@property (nonatomic,copy)NSString *hits;//浏览数量

-(instancetype)initWithDict:(NSDictionary *)dict;
@end
