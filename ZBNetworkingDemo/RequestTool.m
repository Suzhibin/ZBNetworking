//
//  RequestTool.m
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2020/6/2.
//  Copyright © 2020 Suzhibin. All rights reserved.
//

#import "RequestTool.h"
#import "ZBNetworking.h"
#import "DataManager.h"
@implementation RequestTool
+ (void)setupPublicParameters{
    /**
     基础配置
     需要在请求之前配置，设置后所有请求都会带上 此基础配置
     */
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"github"] = @"https://github.com/Suzhibin/ZBNetworking";
    parameters[@"jianshu"] = @"https://www.jianshu.com/p/55cda3341d11";
    parameters[@"iap"]=@"0";
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.2f",timeInterval];
    parameters[@"timeString"] =timeString;//时间戳

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"Token"] = @"Token";

    [ZBRequestManager setupBaseConfig:^(ZBConfig * _Nullable config) {
        config.baseURL=server_URL;//如果同一个环境，有多个域名 不要设置baseURL
        config.parameters=parameters;//公共参数
        // filtrationCacheKey因为时间戳是变动参数，缓存key需要过滤掉 变动参数,如果 不使用缓存功能 或者 没有变动参数 则不需要设置。
        config.filtrationCacheKey=@[@"timeString"];
        config.headers=headers;//请求头
        config.requestSerializer=ZBJSONRequestSerializer; //全局设置 请求格式 默认JSON
        config.responseSerializer=ZBJSONResponseSerializer; //全局设置 响应格式 默认JSON
        config.timeoutInterval=15;//超时时间  优先级 小于 单个请求重新设置
        //config.retryCount=2;//请求失败 所有请求重新连接次数
        config.consoleLog=YES;//开log
        config.userInfo=@{@"info":@"ZBNetworking"};//请求的信息，可以用来注释和判断使用
        config.responseContentTypes=@[@"text/aaa",@"text/bbb"];//添加新的响应数据类型
        /**
         内部已存在的响应数据类型
         @"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript",@"text/xml",@"image/*",@"multipart/form-data",@"application/octet-stream",@"application/zip"
         */
    }];
    /**
       插件机制
       自定义 所有 请求,响应,错误 处理逻辑的方法

       比如 1.自定义缓存逻辑 感觉ZBNetworking缓存不好，想使用yycache 等
           2.自定义响应逻辑 服务器会在成功回调里做 返回code码的操作
           3.一个应用有多个服务器地址，可在此进行配置
           4.统一loading 等UI处理
           5. ......
       */
    [ZBRequestManager setRequestProcessHandler:^(ZBURLRequest * _Nullable request, id  _Nullable __autoreleasing * _Nullable setObject) {
         NSLog(@"请求之前");
      

        //比如 我们可以根据参数寻找一个业务的请求 ，给改该请求做一个替换响应数据的操作
        if ([request.userInfo[@"tag"]isEqualToString:@"7777"]) {
            if (request.apiType != ZBRequestTypeCache) {
                      /**
                      //⚠️setObject 赋值 就会走成功回调
                      如判断内的请求包含keep请求，keep功能将受影响
                      request.keepType=ZBResponseKeepFirst
                      request.keepType=ZBResponseKeepLast
                       都不会不起作用了。所有请求都会成功了。
                       */
                *setObject=@{ @"authors":@[@{@"errorCode":@"400"}],
                                @"videos":@[@{@"errorCode":@"400"}]};
            }
                       
        }
        if ([request.userInfo[@"tag"]isEqualToString:@"8888"]){
                     /**
                     如果服务器有多个域名 可以在此配置，并不可以使用config.baseURL。
                     也可以在每个请求的URLString赋值时拼接
                     */
                     NSString *URL;
                     if ([request.userInfo[@"tag"]isEqualToString:@"111"]){
                         URL=[NSString stringWithFormat:@"https://AAAURL.com/%@",request.URLString] ;
                     }
                     if ([request.userInfo[@"tag"]isEqualToString:@"222"]){
                         URL=[NSString stringWithFormat:@"https://BBBURL.com/%@",request.URLString] ;
                     }
                     if ([request.userInfo[@"tag"]isEqualToString:@"333"]){
                         URL=[NSString stringWithFormat:@"https://CCCURL.com/%@",request.URLString] ;
                     }
                     request.URLString=URL;
                     
                       //⚠️setObject 赋值 就会走成功回调
                     *setObject=@{};
                     
        }
        if ([request.userInfo[@"tag"]isEqualToString:@"9999"]) {
              
            //自定义缓存逻辑时apiType需要设置为 request.apiType=ZBRequestTypeRefresh（默认）这样就不会走ZBNetworking自带缓存了
            request.apiType=ZBRequestTypeRefresh;
            //排除上传和下载请求
            if (request.methodType!=ZBMethodTypeUpload||request.methodType!=ZBMethodTypeDownLoad) {
                NSDictionary *dict= [[DataManager sharedInstance] dataInfoWithKey:[NSString stringWithFormat:@"%@%@",request.URLString,request.parameters[@"author"]]];
                if (dict) {
                  //⚠️setObject 赋值 就会走成功回调
                    *setObject=dict;
                }
            }
        }
    }];
    
    [ZBRequestManager setResponseProcessHandler:^id(ZBURLRequest * _Nullable request, id  _Nullable responseObject, NSError * _Nullable __autoreleasing * _Nullable error) {
        NSLog(@"成功回调 数据返回之前");
        if ([request.userInfo[@"tag"]isEqualToString:@"5555"]) {
            //json 转模型
        }
    
        if ([request.userInfo[@"tag"]isEqualToString:@"7777"]) {
          
                         /**
                         网络请求 自定义响应结果的处理逻辑
                         比如服务器会在成功回调里做 返回code码的操作 ，可以进行逻辑处理
                         */
                         // 举个例子 假设服务器成功回调内返回了code码
                NSArray * authors;
                NSString *path= request.parameters[@"path"];
                if ([path isEqualToString:@"HomeViewController"]) {
                    authors=responseObject[@"authors"];
                }
                if ([path isEqualToString:@"DetailViewController"]) {
                    authors=responseObject[@"videos"];
                }
                             
                NSString * errorCode= [[authors objectAtIndex:0]objectForKey:@"errorCode"];
                if ([errorCode isEqualToString:@"400"]) {//假设400 登录过期
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"登录过期"};
                    NSLog(@"重新开始业务请求：%@ 参数：%@",request.URLString,request.parameters[@"path"]);
                               

                    //⚠️给*error指针 错误信息，网络请求就会走 失败回调
                    *error = [NSError errorWithDomain:NSURLErrorDomain code:[errorCode integerValue] userInfo:userInfo];

                }else{
                    //转模型
                    NSDictionary *resultData = responseObject;
                    return resultData;
                }
            
                    
        }
        if ([request.userInfo[@"tag"]isEqualToString:@"8888"]){
                           
        }
        if([request.userInfo[@"tag"]isEqualToString:@"9999"]){
            //自定义缓存逻辑时apiType需要设置为 request.apiType=ZBRequestTypeRefresh（默认）这样就不会走ZBNetworking自带缓存了
                           //排除上传和下载请求
            if (request.methodType!=ZBMethodTypeUpload||request.methodType!=ZBMethodTypeDownLoad) {
                    [[DataManager sharedInstance] saveDataInfo:responseObject key:[NSString stringWithFormat:@"%@%@",request.URLString,request.parameters[@"author"]]];
                    }
            }
        return nil;
    }];
    [ZBRequestManager setErrorProcessHandler:^(ZBURLRequest * _Nullable request, NSError * _Nullable error) {
   
        if (error.code==NSURLErrorCancelled){
            NSLog(@"请求取消❌------------------");
        }else if (error.code==NSURLErrorTimedOut){
            NSLog(@"请求超时");
        }else{
            NSLog(@"请求失败");
        }
    }];
}
@end
