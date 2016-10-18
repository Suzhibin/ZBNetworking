//
//  ZBCacheManager.m
//  ZBURLSessionManager
//
//  Created by NQ UEC on 16/6/8.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//  ( https://github.com/Suzhibin )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//


#import "ZBCacheManager.h"
#import <CommonCrypto/CommonDigest.h>

NSString *const PathDefault =@"AppCache";
NSString *const PathData =@"DataCache";
NSString *const PathWeb =@"WebCache";
static const NSInteger cacheMaxCacheAge  = 60*60*24*7;
static const CGFloat unit = 1000.0;
//static NSInteger cacheMixCacheAge = 60;
@interface ZBCacheManager ()

@property (nonatomic ,copy)NSString *diskCachePath;
@property (nonatomic ,copy)NSString *dataCachePath;
@property (nonatomic ,copy)NSString *webCachePath;
@end

static ZBCacheManager *Cachemanager=nil;

@implementation ZBCacheManager

+ (ZBCacheManager *)shareCacheManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Cachemanager = [[ZBCacheManager alloc] init];
    });
    return Cachemanager;
}

- (id)init{
    self = [super init];
    if (self) {
        
        [self initCachesfileWithName:PathDefault];
        [self initCachesDatafileWithName:PathData];
        [self initCachesWebfileWithName:PathWeb];
      
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(automaticCleanCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backgroundCleanDisk) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - 获取沙盒目录
- (NSString *)getHomeDirectory {
    return NSHomeDirectory();
}

- (NSString *)getDocumentDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)getLibraryDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)getCachesDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)getTmpDirectory{
    return NSTemporaryDirectory();
}

#pragma mark - 创建存储文件夹
- (void)initCachesfileWithName:(NSString *)name
{
    self.diskCachePath = [NSString stringWithFormat:@"%@/%@", [self getCachesDirectory],name];

    [self createDirectoryAtPath:self.diskCachePath];
}

- (void)initCachesDatafileWithName:(NSString *)name
{
    self.dataCachePath = [NSString stringWithFormat:@"%@/%@", self.diskCachePath,name];
    if (self.diskCachePath) {
         [self createDirectoryAtPath:self.dataCachePath];
    }
}

- (void)initCachesWebfileWithName:(NSString *)name
{
    self.webCachePath = [NSString stringWithFormat:@"%@/%@", self.diskCachePath,name];
    if (self.diskCachePath) {
        [self createDirectoryAtPath:self.webCachePath];
    }
}

- (void)createDirectoryAtPath:(NSString *)path
{
    if (![self fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        // NSLog(@"FileDir is exists.");
    }
}

- (BOOL)fileExistsAtPath:(NSString *)path
{
  return  [[NSFileManager defaultManager] fileExistsAtPath:path];
}

#pragma  mark - 存储
- (void)setMutableData:(NSMutableData*)data writeToFile:(NSString *)path
{
    if (!data) return;
    [data writeToFile:path atomically:YES];
}

- (void)setString:(NSString*)string writeToFile:(NSString *)path
{
    if (!string) return;
    [string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)pathWithFileName:(NSString *)key{
        
    NSString *path=[self cachePathForKey:key inPath:self.dataCachePath];
        
    return path;
        
}

- (NSString *)pathWithWebFileName:(NSString *)key{
    
    NSString *path=[self cachePathForKey:key inPath:self.webCachePath];
    
    return path;
    
}

- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)CachePath {
    @synchronized (self) {
        NSString *filename = [self cachedFileNameForKey:key];
        return [CachePath stringByAppendingPathComponent:filename];
    }
}

- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    
    return filename;
}

#pragma  mark - 计算大小与个数
- (NSUInteger)getCacheSize {
    
    return [self getFileSizeWithpath:self.dataCachePath];
}

- (NSUInteger)getCacheCount {
    return [self getFileCountWithpath:self.dataCachePath];
}

- (NSUInteger)getWebCacheSize {
    
    return [self getFileSizeWithpath:self.webCachePath];
}

- (NSUInteger)getWebCacheCount {
    return [self getFileCountWithpath:self.webCachePath];
}

- (NSUInteger)getFileSizeWithpath:(NSString *)path
{
    __block NSUInteger size = 0;
    
    dispatch_sync(dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL), ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    
    return size;

}

- (NSUInteger)getFileCountWithpath:(NSString *)path
{
    __block NSUInteger count = 0;
    dispatch_sync(dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL), ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        count = [[fileEnumerator allObjects] count];
    });
    return count;
}

- (NSString *)fileUnitWithSize:(float)size
{
    if (size >= unit * unit * unit) { // >= 1GB
        return [NSString stringWithFormat:@"%.2fGB", size / unit / unit / unit];
    } else if (size >= unit * unit) { // >= 1MB
        return [NSString stringWithFormat:@"%.2fMB", size / unit / unit];
    } else { // >= 1KB
        return [NSString stringWithFormat:@"%.2fKB", size / unit];
    }
  
}

#pragma  mark - 清除文件

-(void)automaticCleanCache{
    
    [self automaticCleanCacheWithPath:self.dataCachePath Operation:nil];
    [self automaticCleanCacheWithPath:self.webCachePath Operation:nil];
}

- (void)automaticCleanCacheWithPath:(NSString *)path Operation:(ZBCacheManagerBlock)operation
{
    dispatch_sync(dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL),^{
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheMaxCacheAge];
        
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        
        for (NSString *fileName in fileEnumerator)
        {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            NSDate *current = [info objectForKey:NSFileModificationDate];
            
            if ([[current laterDate:expirationDate] isEqualToDate:expirationDate])
            {
                
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                
            }
        }
        if (operation) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                operation();
            });
        }
    });
}

- (void)backgroundCleanDisk {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    [self automaticCleanCacheWithPath:self.dataCachePath Operation:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    [self automaticCleanCacheWithPath:self.webCachePath Operation:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)clearCacheForkey:(NSString *)key
{
    NSString *path=[self pathWithFileName:key];
    [self clearCacheForPath:path operation:nil];
}

- (void)clearWebCacheForkey:(NSString *)key
{
    NSString *path=[self pathWithWebFileName:key];
    [self clearCacheForPath:path operation:nil];
}

- (void)clearCacheForPath:(NSString *)path operation:(ZBCacheManagerBlock)operation
{
    dispatch_sync(dispatch_queue_create(0,DISPATCH_QUEUE_SERIAL),^{
        
        [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
        
        if (operation) {
            dispatch_sync(dispatch_get_main_queue(),^{
                operation();
            });
        }

    });
}

- (void)clearCache
{
     [self clearCacheOnOperation:nil];
}

- (void)clearCacheOnOperation:(ZBCacheManagerBlock)operation{

    dispatch_async(dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL), ^{

            //[self clearDiskWithpath:self.diskCachePath];
        [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:nil];
        [self createDirectoryAtPath:self.diskCachePath];
        [self createDirectoryAtPath:self.dataCachePath];
        [self createDirectoryAtPath:self.webCachePath];
        if (operation) {
            dispatch_sync(dispatch_get_main_queue(),^{
                operation();
            });
        }
    });
}

- (void)clearDataCache
{
    [self clearDiskWithpath:self.dataCachePath];
}

- (void)clearWebCache
{
    [self clearDiskWithpath:self.webCachePath];
}

- (void)clearDiskWithpath:(NSString *)path
{
    [self clearDiskWithpath:path operation:nil];
}

- (void)clearDiskWithpath:(NSString *)path operation:(ZBCacheManagerBlock)operation
{
     dispatch_async(dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL), ^{
  
           NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
         for (NSString *fileName in fileEnumerator)
         {
             NSString *filePath = [path stringByAppendingPathComponent:fileName];
         
             [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
       
         }
         if (operation) {
             dispatch_sync(dispatch_get_main_queue(),^{
                 operation();
             });
         }

     });
}


@end
