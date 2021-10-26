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
    #pragma mark -  公共配置
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
    headers[@"Token"] = @"Token";//如果请求头内的Token 是动态获取，比如登陆后获取的 ，不在此设置Token 可以在插件 setRequestProcessHandler 方法内添加

    [ZBRequestManager setupBaseConfig:^(ZBConfig * _Nullable config) {
        /**
         config.baseServer 设置基础服务器地址
         如果同一个环境，有多个服务器地址，可以在每个请求单独设置 requestr.server  优先级大于config.baseServer
         */
        config.baseServer=server_URL;
        /**
         config.parameters公共参数
         如果同一个环境，有多个服务器地址，公共参数不同有两种方式
         1.在每个请求单独添加parameters
         2.在插件机制里 预处理 请求。判断对应的server添加
         */
        config.parameters=parameters;
        // filtrationCacheKey因为时间戳是变动参数，缓存key需要过滤掉 变动参数,如果 不使用缓存功能 或者 没有变动参数 则不需要设置。
        config.filtrationCacheKey=@[@"timeString"];
        config.headers=headers;//请求头
        config.requestSerializer=ZBJSONRequestSerializer; //全局设置 请求格式 默认JSON
        config.responseSerializer=ZBJSONResponseSerializer; //全局设置 响应格式 默认JSON
        config.timeoutInterval=15;//超时时间  优先级 小于 单个请求重新设置
        //config.retryCount=2;//请求失败 所有请求重新连接次数
        config.consoleLog=YES;//开log
        config.userInfo=@{@"info":@"ZBNetworking"};//自定义请求的信息，可以用来注释和判断使用，不会传给服务器
        config.responseContentTypes=@[@"application/pdf",@"video/mpeg4"];//添加新的响应数据类型
        /**
         内部已存在的响应数据类型
         @"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript",@"text/xml",@"image/*",@"multipart/form-data",@"application/octet-stream",@"application/zip"
         */
    }];
    
    #pragma mark -  插件机制
    /**
       插件机制
       自定义 所有 请求,响应,错误 处理逻辑的方法
        在这里 你可以根据request对象的参数 添加你的逻辑 比如server,url,userInfo,parameters
     
       比如 1.自定义缓存逻辑 感觉ZBNetworking缓存不好，想使用yycache 等
           2.自定义响应逻辑 服务器会在成功回调里做 返回code码的操作
           3.一个应用有多个服务器地址，可在此进行单独配置参数
           4.统一loading 等UI处理
           5.业务数据数据的一些处理
           6. ......
       */
    //预处理 请求
    [ZBRequestManager setRequestProcessHandler:^(ZBURLRequest * _Nullable request, id  _Nullable __autoreleasing * _Nullable setObject) {
        NSLog(@"插件响应 请求之前 可以进行参数加工");
        if ([request.userInfo[@"tag"]isEqualToString:@"10086"]) {
            //为某个服务器 单独添加公共参数
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[@"pb"] = @"从插件机制添加：pb这个参数，只会在下载请求的参数里显示";
            
            [request.parameters setValue:@"从插件机制添加：pb这个参数，只会在下载请求的参数里显示" forKey:@"pb"];//这样添加 其他参数依然存在。
           // request.parameters=parameters;//这样添加 其他参数被删除
            
            NSMutableDictionary *headers = [NSMutableDictionary dictionary];
            headers[@"Token"] = @"从插件机制添加：Token";
            request.headers=headers;//如果请求头内的Token 是动态获取，比如登陆后获取的 ，在此设置Token

        }

        if ([request.userInfo[@"tag"]isEqualToString:@"9999"]) {
              
            //自定义缓存逻辑时apiType需要设置为 request.apiType=ZBRequestTypeRefresh（默认）这样就不会走ZBNetworking自带缓存了
            request.apiType=ZBRequestTypeRefresh;
            //排除上传和下载请求
            if (request.methodType!=ZBMethodTypeUpload||request.methodType!=ZBMethodTypeDownLoad) {
                NSDictionary *dict= [[DataManager sharedInstance] dataInfoWithKey:[NSString stringWithFormat:@"%@%@",request.url,request.parameters[@"github"]]];
                if (dict) {
                  //⚠️setObject 赋值 就会走成功回调，这样就读到了 自己的缓存数据
                    *setObject=dict;
                }
            }
        }
    }];
    //预处理 响应
    [ZBRequestManager setResponseProcessHandler:^id(ZBURLRequest * _Nullable request, id  _Nullable responseObject, NSError * _Nullable __autoreleasing * _Nullable error) {
        NSLog(@"插件响应 成功回调 数据返回之前");
        if ([request.userInfo[@"tag"]isEqualToString:@"2222"]) {
            NSArray *array=[responseObject objectForKey:@"authors"];
            /**
             如果请求成功，但数组为空，又不想覆盖原有缓存文件，在此判断改变request对象apiType属性
             */
            if (array.count==0) {
                request.apiType=ZBRequestTypeRefresh;
            }
        }
        if ([request.userInfo[@"tag"]isEqualToString:@"5555"]) {
            //json 转模型
        }
    
        if ([request.userInfo[@"tag"]isEqualToString:@"7777"]) {
          
            /**
            网络请求 自定义响应结果的处理逻辑
            比如服务器会在成功回调里做 返回code码的操作 ，可以进行逻辑处理
            */
            // 举个例子 假设服务器成功回调内返回了code码
            NSDictionary *data= responseObject[@"Data"];
            NSInteger IsError= [data[@"IsError"] integerValue];
            if (IsError==1) {//假设与服务器约定 IsError==1代表错误
                NSString *errorStr=responseObject[@"Error"];//服务器返回的 错误内容
                NSString * errorCode=[data objectForKey:@"HttpStatusCode"];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errorStr};
                errorCode= @"401";//假设401 登录过期或Token 失效
                if ([errorCode integerValue]==401) {
                    request.retryCount=3;//设置重试请求次数 每2秒重新请求一次 ，走失败回调时会重新请求
                    userInfo = @{NSLocalizedDescriptionKey:@"登录过期"};
                    //这里重新请求Token，请求完毕 retryCount还在执行，就会重新请求到 已失败的网络请求，3次不够的话，次数可以多设置一些。
                }else{
                    //吐司提示错误  errorStr
                }
                //⚠️给*error指针 错误信息，网络请求就会走 失败回调
                *error = [NSError errorWithDomain:NSURLErrorDomain code:[errorCode integerValue] userInfo:userInfo];
            }else{
                //请求成功
            }
        }

        if([request.userInfo[@"tag"]isEqualToString:@"9999"]){
            //自定义缓存逻辑时apiType需要设置为 request.apiType=ZBRequestTypeRefresh（默认）这样就不会走ZBNetworking自带缓存了
            //排除上传和下载请求
            if (request.methodType!=ZBMethodTypeUpload||request.methodType!=ZBMethodTypeDownLoad) {
                [[DataManager sharedInstance] saveDataInfo:responseObject key:[NSString stringWithFormat:@"%@%@",request.url,request.parameters[@"github"]]];
            }
        }
        return nil;
    }];
     //预处理 错误
    [ZBRequestManager setErrorProcessHandler:^(ZBURLRequest * _Nullable request, NSError * _Nullable error) {
   
        if (error.code==NSURLErrorCancelled){
            NSLog(@"插件响应 请求取消❌------------------");
        }else if (error.code==NSURLErrorTimedOut){
            NSLog(@"插件响应 请求超时");
        }else{
            NSLog(@"插件响应 请求失败");
        }
    }];
    #pragma mark -  证书设置
    /**
     证书设置
     ZBRequestEngine 继承AFHTTPSessionManager，所需其他设置 可以使用[ZBRequestEngine defaultEngine] 自行设置
     */
    NSString *name=@"";
    if (name.length>0) {
        // 先导入证书
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:name ofType:@"cer"];//证书的路径
        NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
           // 如果需要验证自建证书(无效证书)，需要设置为YES，默认为NO;
        securityPolicy.allowInvalidCertificates = YES;
           // 是否需要验证域名，默认为YES;
        securityPolicy.validatesDomainName = NO;
        securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
        [ZBRequestEngine defaultEngine].securityPolicy=securityPolicy;
    }
   
}
@end
