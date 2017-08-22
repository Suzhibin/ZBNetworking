//
//  ZBURLRequest.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/12/20.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "ZBURLRequest.h"

@interface ZBURLRequest()
/**
 *  离线下载栏目url容器
 */
@property (nonatomic,strong) NSMutableArray *channelUrlArray;

/**
 *  离线下载栏目名字容器
 */
@property (nonatomic,strong) NSMutableArray *channelKeyArray;

@end


@implementation ZBURLRequest

- (void)dealloc{
    ZBLog(@"%s",__func__);
}
#pragma mark - 请求头
- (void)setValue:(NSString *)value forHeaderField:(NSString *)field{
    if (value) {
        [self.mutableHTTPRequestHeaders setValue:value forKey:field];
    }
    else {
        [self removeHeaderForkey:field];
    }
}

- (NSString *)objectHeaderForKey:(NSString *)key{
    return  [self.mutableHTTPRequestHeaders objectForKey:key];
}

- (void)removeHeaderForkey:(NSString *)key{
    if(!key)return;
    [self.mutableHTTPRequestHeaders removeObjectForKey:key];
}
#pragma mark - 添加多次请求
- (NSMutableArray *)offlineUrlArray{
    return self.channelUrlArray;
}

- (NSMutableArray *)offlineKeyArray{
    return self.channelKeyArray;
}

- (void)addObjectWithUrl:(NSString *)urlString{
    [self addObjectWithForKey:urlString isUrl:YES];
}

- (void)removeObjectWithUrl:(NSString *)urlString{
    [self removeObjectWithForkey:urlString isUrl:YES];
}

- (void)addObjectWithKey:(NSString *)key{
    [self addObjectWithForKey:key isUrl:NO];
}

- (void)removeObjectWithKey:(NSString *)key{
    [self removeObjectWithForkey:key isUrl:NO];
}

- (void)removeOfflineArray{

    [self.offlineUrlArray removeAllObjects];
    [self.offlineKeyArray removeAllObjects];
}


- (BOOL)isAddForKey:(NSString *)key isUrl:(BOOL)isUrl{
    
    if (isUrl==YES) {
        @synchronized (self.channelUrlArray) {
            return  [self.channelUrlArray containsObject: key];
        }
    }else{
        @synchronized (self.channelKeyArray) {
            return  [self.channelKeyArray containsObject: key];
        }
    }
}

- (void)addObjectWithForKey:(NSString *)key isUrl:(BOOL)isUrl{
    if (isUrl==YES) {
        
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            ZBLog(@"已经包含该栏目URL");
        }else{
            @synchronized (self.channelUrlArray) {
                [self.channelUrlArray addObject:key];
            }
        }
    }else{
        
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            ZBLog(@"已经包含该栏目名字");
        }else{
            @synchronized (self.channelKeyArray ) {
                [self.channelKeyArray addObject:key];
            }
        }
    }
}

- (void)removeObjectWithForkey:(NSString *)key isUrl:(BOOL)isUrl{
    if (isUrl==YES) {
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            @synchronized (self.channelUrlArray) {
                [self.channelUrlArray removeObject:key];
            }
        }else{
            ZBLog(@"已经删除该栏目URL");
        }
        
    }else{
        
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            @synchronized (self.channelKeyArray) {
                [self.channelKeyArray removeObject:key];
            }
        }else{
            ZBLog(@"已经删除该栏目名字");
        }
    }
}

#pragma mark - 上传请求参数
- (void)addFormDataWithName:(NSString *)name fileData:(NSData *)fileData {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileData:fileData];
    [self.uploadDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileName:fileName mimeType:mimeType fileData:fileData];
    [self.uploadDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileURL:fileURL];
    [self.uploadDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileName:fileName mimeType:mimeType fileURL:fileURL];
    [self.uploadDatas addObject:formData];
}

#pragma mark - 懒加载
- (NSMutableArray *)channelUrlArray{
    
    if (!_channelUrlArray) {
        _channelUrlArray=[[NSMutableArray alloc]init];
    }
    return _channelUrlArray;
}

- (NSMutableArray *)channelKeyArray{
    
    if (!_channelKeyArray) {
        _channelKeyArray=[[NSMutableArray alloc]init];
    }
    return _channelKeyArray;
}

- (NSMutableDictionary *)mutableHTTPRequestHeaders{
    
    if (!_mutableHTTPRequestHeaders) {
        _mutableHTTPRequestHeaders  = [[NSMutableDictionary alloc]init];
    }
    return _mutableHTTPRequestHeaders;
}

- (NSMutableArray<ZBUploadData *> *)uploadDatas {
    if (!_uploadDatas) {
        _uploadDatas = [NSMutableArray array];
    }
    return _uploadDatas;
}

- (NSMutableData *)responseObject {
    if (!_responseObject) {
        _responseObject=[[NSMutableData alloc]init];
    }
    return _responseObject;
}

@end

#pragma mark - ZBUploadData

@implementation ZBUploadData

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileURL = fileURL;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileURL = fileURL;
    return formData;
}


@end
