//
//  ZBRequestManager.h
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/17.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBRequestConst.h"

@interface ZBRequestManager : NSObject

/**
 *  传参对象
 */
@property (nonatomic,strong) ZBURLRequest *request;

/**
 *  类请求方法 get/post
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (void)requestWithConfig:(requestConfig)config  success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  类请求方法 get/post/DownLoad
 *
 *  @param config           请求配置  Block
 *  @param progress         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (void)requestWithConfig:(requestConfig)config  progress:(progressBlock)progress success:(requestSuccess)success failed:(requestFailed)failed;

/**
 *  离线下载 请求方法
 *
 *  @param downloadArray    请求列队
 *  @param success          请求成功的 Block
 *  @param failed           请求失败的 Block
 */
+ (void)offlineDownload:(NSMutableArray *)downloadArray success:(requestSuccess)success failed:(requestFailed)failed;

/**
 取消请求任务
 
 @param urlString           协议接口
 @param completion          后续操作
 */
+ (void)cancelRequest:(NSString *)urlString completion:(cancelCompletedBlock)completion;

@end
