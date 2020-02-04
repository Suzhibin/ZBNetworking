//
//  DataManager.h
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2020/1/19.
//  Copyright © 2020 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

@property(nonatomic,copy)NSString *cacheKey;

@property(nonatomic,copy)NSString *tag;
/**
 *  数据管理对象单例
 *
 *  @return self
 */
+ (instancetype)sharedInstance;
/**
 *  保存页面数据
 *
 *  @param info   页面数据
 *  @param menuId 菜单id
 */
- (void)saveDataInfo:(NSDictionary *)info key:(NSString *)key;
/**
 *  根据menuId获取相应页面的数据
 *
 *  @param menuId 菜单id
 *
 *  @return 页面数据，可为nil
 */
- (NSDictionary *)dataInfoWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
