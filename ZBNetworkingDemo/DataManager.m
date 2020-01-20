//
//  DataManager.m
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2020/1/19.
//  Copyright © 2020 Suzhibin. All rights reserved.
//

#import "DataManager.h"
@interface DataManager()

@property (nonatomic, strong) NSMutableDictionary *dataInfo;

@end
@implementation DataManager
+ (instancetype)sharedInstance {
    static DataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        sharedManager.dataInfo = [[NSMutableDictionary alloc] init];
    });
    return sharedManager;
}

- (void)saveDataInfo:(NSDictionary *)info key:(NSString *)key {
    if (key) {
        [_dataInfo setObject:info forKey:key];
    }
}

- (NSDictionary *)dataInfoWithKey:(NSString *)key {
    return [_dataInfo objectForKey:key];
}

@end
