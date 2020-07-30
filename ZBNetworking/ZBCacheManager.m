//
//  ZBCacheManager.m
//  ZBNetworking
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

NSString *const PathSpace =@"ZBKit";
NSString *const defaultCachePathName =@"AppCache";
static const NSInteger defaultCacheMaxCacheAge  = 60*60*24*7;
//static const NSInteger defaultCacheMixCacheAge = 60;
static const CGFloat unit = 1000.0;
@interface ZBCacheManager ()
@property (nonatomic ,strong) NSCache *memoryCache;
@property (nonatomic ,copy)NSString *diskCachePath;
@property (nonatomic ,strong) dispatch_queue_t operationQueue;

@end

@implementation ZBCacheManager

+ (ZBCacheManager *)sharedInstance{
    static ZBCacheManager *cacheInstance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheInstance = [[ZBCacheManager alloc] init];
    });
    return cacheInstance;
}

- (id)init{
    self = [super init];
    if (self) {
          NSString *memoryNameSpace = [@"memory.ZBCacheManager" stringByAppendingString:defaultCachePathName];
        
         _operationQueue = dispatch_queue_create("dispatch.ZBCacheManager", DISPATCH_QUEUE_SERIAL);
        
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.name = memoryNameSpace;
        
        [self initCachesfileWithName:defaultCachePathName];
  
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMemory) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(automaticCleanCache) name:UIApplicationWillTerminateNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundCleanCache) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - 获取沙盒目录
- (NSString *)homePath {
    return NSHomeDirectory();
}

- (NSString *)documentPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)libraryPath{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)cachesPath{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)tmpPath{
    return NSTemporaryDirectory();
}

- (NSString *)ZBKitPath{
    return [[self cachesPath]stringByAppendingPathComponent:PathSpace];
}

- (NSString *)ZBAppCachePath{
    return self.diskCachePath;
}

#pragma mark - 创建存储文件夹

- (void)initCachesfileWithName:(NSString *)name{

    self.diskCachePath =[[self ZBKitPath] stringByAppendingPathComponent:name];
  
    [self createDirectoryAtPath:self.diskCachePath];
}

- (void)createDirectoryAtPath:(NSString *)path{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    } else {
        // NSLog(@"FileDir is exists.%@",path);
    }
}

- (BOOL)diskCacheExistsWithKey:(NSString *)key{
    return [self diskCacheExistsWithKey:key path:self.diskCachePath];
}

- (BOOL)diskCacheExistsWithKey:(NSString *)key path:(NSString *)path{
    
    NSString *isExists=[[self getDiskCacheWithCodingForKey:key path:path] stringByDeletingPathExtension];

    return [[NSFileManager defaultManager] fileExistsAtPath:isExists];
}

#pragma  mark - 存储
- (void)storeContent:(NSObject *)content forKey:(NSString *)key isSuccess:(ZBCacheIsSuccessBlock)isSuccess{
    [self storeContent:content forKey:key path:self.diskCachePath isSuccess:isSuccess];
}

- (void)storeContent:(NSObject *)content forKey:(NSString *)key path:(NSString *)path isSuccess:(ZBCacheIsSuccessBlock)isSuccess{
    if (!content || !key) {
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                isSuccess(NO);
            });
        }
        return;
    }
    [self.memoryCache setObject:content forKey:key ];
    
    dispatch_async(self.operationQueue,^{
        NSString *codingPath =[[self getDiskCacheWithCodingForKey:key path:path]stringByDeletingPathExtension];
        BOOL result=[self setContent:content writeToFile:codingPath];
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                isSuccess(result);
            });
        }
    });
}

- (BOOL)setContent:(NSObject *)content writeToFile:(NSString *)path{
    if (!content||!path){
        return NO;
    }
    if ([content isKindOfClass:[NSData class]]) {
        return  [(NSData *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[UIImage class]]) {
        return [UIImageJPEGRepresentation((UIImage *)content,(CGFloat)0.9) writeToFile:path atomically:YES];
    }else {
       // [NSException raise:@"非法的文件内容" format:@"文件类型%@异常。", NSStringFromClass([content class])];
        return NO;
    }
    return NO;
}

#pragma  mark - 获取存储数据
- (void)getCacheDataForKey:(NSString *)key value:(ZBCacheValueBlock)value{
    
    [self getCacheDataForKey:key path:self.diskCachePath value:value];
}

- (void)getCacheDataForKey:(NSString *)key path:(NSString *)path value:(ZBCacheValueBlock)value{
    if (!key)return;
    NSData *obj = [self.memoryCache objectForKey:key];
    if (obj) {
        if (value) {
            value(obj,@"memoryCache");
        }
    }else{
        dispatch_async(self.operationQueue,^{
            @autoreleasepool {
                NSString *filePath=[[self getDiskCacheWithCodingForKey:key path:path]stringByDeletingPathExtension];
                NSData *diskdata= [NSData dataWithContentsOfFile:filePath];
                if (diskdata) {
                    if (value) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            value(diskdata,filePath);
                        });
                    }
                    [self.memoryCache setObject:diskdata forKey:key];
                }
                
            }
        });
    }
}

- (NSArray *)getDiskCacheFileWithPath:(NSString *)path{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    
    dispatch_sync(self.operationQueue, ^{
        
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator){
            if (fileName.length==32) {
                NSString *filePath = [path stringByAppendingPathComponent:fileName];
                [array addObject:filePath];
            }
        }
    });
    return array;
}

-(NSDictionary* )getDiskFileAttributes:(NSString *)key path:(NSString *)path{
 
    NSString *filePath=[[self getDiskCacheWithCodingForKey:key path:path]stringByDeletingPathExtension];

    return [self getDiskFileAttributesWithFilePath:filePath];
}

-  (NSDictionary* )getDiskFileAttributesWithFilePath:(NSString *)filePath{
    
    NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return info;
}

#pragma mark -  编码
- (NSString *)getDiskCacheWithCodingForKey:(NSString *)key{
        
    NSString *path=[self getDiskCacheWithCodingForKey:key path:self.diskCachePath];
    return path;
}

- (NSString *)getDiskCacheWithCodingForKey:(NSString *)key path:(NSString *)path {
    NSString *filename = [self MD5StringForKey:key];
    return [path stringByAppendingPathComponent:filename];
}

- (NSString *)MD5StringForKey:(NSString *)key {
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
# pragma mark - Mem Cache settings
- (NSUInteger)maxMemoryCountLimit {
    return self.memoryCache.countLimit;
}

- (void)setMaxMemoryCountLimit:(NSUInteger)maxCountLimit {
    self.memoryCache.countLimit = maxCountLimit;
}
#pragma  mark - 计算大小与个数
- (NSUInteger)getCacheSize {
    return [self getFileSizeWithpath:self.diskCachePath];
}

- (NSUInteger)getCacheCount {
    return [self getFileCountWithpath:self.diskCachePath];
}

- (NSUInteger)getFileSizeWithpath:(NSString *)path{
    __block NSUInteger size = 0;
    //sync
    dispatch_sync(self.operationQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    
    return size;
}

- (NSUInteger)getFileCountWithpath:(NSString *)path{
    __block NSUInteger count = 0;
    //sync
    dispatch_sync(self.operationQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        count = [[fileEnumerator allObjects] count];
    });
    return count;
}

- (NSString *)fileUnitWithSize:(float)size{
    if (size >= unit * unit * unit) { // >= 1GB
        return [NSString stringWithFormat:@"%.2fGB", size / unit / unit / unit];
    } else if (size >= unit * unit) { // >= 1MB
        return [NSString stringWithFormat:@"%.2fMB", size / unit / unit];
    } else { // >= 1KB
        return [NSString stringWithFormat:@"%.2fKB", size / unit];
    }
}

- (NSUInteger)diskSystemSpace{
    
    __block NSUInteger size = 0.0;
    dispatch_sync(self.operationQueue, ^{
        NSError *error=nil;
        NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[self homePath] error:&error];
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }else{
            NSNumber *systemNumber = [dic objectForKey:NSFileSystemSize];
            size = [systemNumber floatValue];
        }
    });
    return size;

}

- (NSUInteger)diskFreeSystemSpace{
    
    __block NSUInteger size = 0.0;
    dispatch_sync(self.operationQueue, ^{
        NSError *error=nil;
        NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[self homePath] error:&error];
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }else{
            NSNumber *freeSystemNumber = [dic objectForKey:NSFileSystemFreeSize];
            size = [freeSystemNumber floatValue];
        }
    });
    return size;
}

#pragma  mark - 设置过期时间 清除某路径缓存文件
- (void)automaticCleanCache{
   [self clearCacheWithTime:defaultCacheMaxCacheAge completion:nil];
}

- (void)clearCacheWithTime:(NSTimeInterval)time completion:(ZBCacheCompletedBlock)completion{
     [self clearCacheWithTime:time path:self.diskCachePath completion:completion];
}

- (void)clearCacheWithTime:(NSTimeInterval)time path:(NSString *)path completion:(ZBCacheCompletedBlock)completion{
    if (!time||!path)return;
    dispatch_async(self.operationQueue,^{
        // “-” time
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-time];
        
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        
        for (NSString *fileName in fileEnumerator){
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            NSDate *current = [info objectForKey:NSFileModificationDate];

            if ([[current laterDate:expirationDate] isEqualToDate:expirationDate]){
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)backgroundCleanCacheWithPath:(NSString *)path{
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
    [self clearCacheWithTime:defaultCacheMaxCacheAge path:path completion:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)backgroundCleanCache {
    [self backgroundCleanCacheWithPath:self.diskCachePath];
}

#pragma  mark - 清除单个缓存文件
- (void)clearCacheForkey:(NSString *)key{
 
    [self clearCacheForkey:key completion:nil];
}

- (void)clearCacheForkey:(NSString *)key completion:(ZBCacheCompletedBlock)completion{
    
    [self clearCacheForkey:key path:self.diskCachePath completion:completion];
}

- (void)clearCacheForkey:(NSString *)key path:(NSString *)path completion:(ZBCacheCompletedBlock)completion{
    if (!key)return;
    [self.memoryCache removeObjectForKey:key];
    dispatch_async(self.operationQueue,^{
        
        NSString *filePath=[[self getDiskCacheWithCodingForKey:key path:path]stringByDeletingPathExtension];
        
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(),^{
                completion();
            });
        }
    });
}
#pragma  mark - 设置过期时间 清除单个缓存文件
- (void)clearCacheForkey:(NSString *)key time:(NSTimeInterval)time{
    [self clearCacheForkey:key time:time completion:nil];
}

- (void)clearCacheForkey:(NSString *)key time:(NSTimeInterval)time completion:(ZBCacheCompletedBlock)completion{
    [self clearCacheForkey:key time:time path:self.diskCachePath completion:completion];
}

- (void)clearCacheForkey:(NSString *)key time:(NSTimeInterval)time path:(NSString *)path completion:(ZBCacheCompletedBlock)completion{
    if (!time||!key||!path)return;
    dispatch_async(self.operationQueue,^{
        // “-” time
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-time];
        
        NSString *filePath=[[self getDiskCacheWithCodingForKey:key path:path]stringByDeletingPathExtension];
        
        NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSDate *current = [info objectForKey:NSFileModificationDate];
        
        if ([[current laterDate:expirationDate] isEqualToDate:expirationDate]){
            [self.memoryCache removeObjectForKey:key];
            [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}
#pragma  mark - 清除所有缓存
- (void)clearMemory {
    [self.memoryCache removeAllObjects];
}
- (void)clearCache{
     [self clearCacheOnCompletion:nil];
}

- (void)clearCacheOnCompletion:(ZBCacheCompletedBlock)completion{

    dispatch_async(self.operationQueue, ^{
            //[self clearDiskWithpath:self.diskCachePath];
        [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:nil];
        [self createDirectoryAtPath:self.diskCachePath];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(),^{
                completion();
            });
        }
    });
}
#pragma  mark - 清除自定义路径缓存
- (void)clearDiskWithpath:(NSString *)path{
    [self clearDiskWithpath:path completion:nil];
}

- (void)clearDiskWithpath:(NSString *)path completion:(ZBCacheCompletedBlock)completion{
    if (!path)return;
     dispatch_async(self.operationQueue, ^{
  
           NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
         for (NSString *fileName in fileEnumerator)
         {
             NSString *filePath = [path stringByAppendingPathComponent:fileName];
         
             [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
         }
         if (completion) {
             dispatch_async(dispatch_get_main_queue(),^{
                 completion();
             });
         }
     });
}

@end
