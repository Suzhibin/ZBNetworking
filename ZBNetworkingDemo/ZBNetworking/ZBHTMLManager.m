//
//  ZBHTMLManager.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 16/10/19.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "ZBHTMLManager.h"
#import "ZBRequestManager.h"
#import "ZBCacheManager.h"
#import "NSFileManager+pathMethod.h"

static const NSInteger timeOut = 60*60;

@implementation ZBHTMLManager

+ (ZBHTMLManager *)shareManager {
    static ZBHTMLManager *htmlViewManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        htmlViewManager = [[ZBHTMLManager alloc] init];
    });
    return htmlViewManager;
}

- (BOOL)diskhtmlUrl:(NSString *)htmlString{
    
    NSString *path=[[ZBCacheManager shareCacheManager]pathWithHtmlFileName:htmlString];
    
    return  [self diskhtmlUrl:htmlString inPath:path];
}

- (BOOL)diskhtmlUrl:(NSString *)htmlString inPath:(NSString *)path{
    
    if ([[ZBCacheManager shareCacheManager]fileExistsAtPath:path]&&[NSFileManager isTimeOutWithPath:path timeOut:timeOut]==NO) {
        return YES;
    }else{
        
        [[ZBRequestManager shareManager]setHtmlRequestObject:self forkey:htmlString];
        
        [self writeToCache:htmlString];
        
        return NO;
    }
    
}

- (NSString *)htmlString:(NSString *)htmlString{
    
    NSString *path=[[ZBCacheManager shareCacheManager]pathWithHtmlFileName:htmlString];
    
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return html;
}

- (void)writeToCache:(NSString *)htmlString {
    
    [self writeToCache:htmlString Operation:nil];
}

- (void)writeToCache:(NSString *)htmlString Operation:(ZBHTMLManagerBlock)operation
{
    dispatch_sync(dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL), ^{
        
        NSString *path=[[ZBCacheManager shareCacheManager]pathWithHtmlFileName:htmlString];
        
        NSString * html = [NSString stringWithContentsOfURL:[NSURL URLWithString:htmlString]encoding:NSUTF8StringEncoding error:Nil];
        
        [[ZBCacheManager shareCacheManager]setString:html writeToFile:path];
        
        [[ZBRequestManager shareManager]removeHtmlRequestForkey:htmlString];
        
        if (operation) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                operation();
            });
        }
        
    });
}

@end
