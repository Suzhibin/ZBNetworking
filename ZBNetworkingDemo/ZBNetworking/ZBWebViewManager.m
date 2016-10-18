//
//  ZBWebViewManager.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 16/10/18.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "ZBWebViewManager.h"
#import "ZBRequestManager.h"
#import "ZBCacheManager.h"
#import "NSFileManager+pathMethod.h"

static const NSInteger timeOut = 60*60;
@interface ZBWebViewManager ()

@property (nonatomic ,copy)NSString *webCachePath;

@end

@implementation ZBWebViewManager

+ (ZBWebViewManager *)shareManager {
    static ZBWebViewManager *webViewManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webViewManager = [[ZBWebViewManager alloc] init];
    });
    return webViewManager;
}

- (BOOL)fileAtPath:(NSString *)htmlString{
    
    NSString *path=[[ZBCacheManager shareCacheManager]pathWithWebFileName:htmlString];
    
    return  [self fileAtPath:htmlString inPath:path];
}

- (BOOL)fileAtPath:(NSString *)htmlString inPath:(NSString *)path{

    if ([[ZBCacheManager shareCacheManager]fileExistsAtPath:path]&&[NSFileManager isTimeOutWithPath:path timeOut:timeOut]==NO) {
        return YES;
    }else{
        
        [[ZBRequestManager shareManager]setWebRequestObject:self forkey:htmlString];
       
        [[ZBWebViewManager shareManager]writeToCache:htmlString];
       
        return NO;
    }

}

- (NSString *)htmlString:(NSString *)htmlString{
  
    NSString *path=[[ZBCacheManager shareCacheManager]pathWithWebFileName:htmlString];

    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return html;
}

- (void)writeToCache:(NSString *)htmlString {
    
    [self writeToCache:htmlString Operation:nil];
}

- (void)writeToCache:(NSString *)htmlString Operation:(ZBWebViewManagerBlock)operation
{
    dispatch_sync(dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL), ^{
        
        NSString *path=[[ZBCacheManager shareCacheManager]pathWithWebFileName:htmlString];
        
        NSString * html = [NSString stringWithContentsOfURL:[NSURL URLWithString:htmlString]encoding:NSUTF8StringEncoding error:Nil];
        
        [[ZBCacheManager shareCacheManager]setString:html writeToFile:path];
        
        [[ZBRequestManager shareManager]removeWebRequestForkey:htmlString];
        
        if (operation) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                operation();
            });
        }

    });
}

@end
