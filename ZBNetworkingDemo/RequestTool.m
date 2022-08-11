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
#import "APMModel.h"
@implementation RequestTool
+ (void)setupPublicParameters{
    #pragma mark -  如需设置证书，需在网络所有配置前设置
    /**
     证书设置
     ZBRequestEngine 继承AFHTTPSessionManager，所需其他设置 可以使用[ZBRequestEngine defaultEngine] 自行设置
     */
    NSString *name=@"";
    if (name.length>0) {
        NSURL *url=[NSURL URLWithString:@"https://h5.jp.51wnl.com"];
        [[AFHTTPSessionManager manager]initWithBaseURL:url];//自定义证书 经过测试 必须设置[[AFHTTPSessionManager manager]initWithBaseURL:url]，BaseURL必须为https，不要使用 ZBRequestEngine调用initWithBaseURL 会重置ZBRequestEngine内设置
       // ⚠️⚠️⚠️ 如果设置 [[AFHTTPSessionManager manager]initWithBaseURL:url] 必须在 [ZBRequestEngine defaultEngine] 之前调用，否则会重置ZBRequestEngine内设置
        // 导入证书
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
   
    #pragma mark -  公共配置
    /**
     基础配置
     需要在请求之前配置，设置后所有请求都会带上 此基础配置
     此回调只会调用一次。⚠️⚠️⚠️需要动态配置的 不要在此设置  去setRequestProcessHandler设置
     */
    /*不推荐在此 配置参数 ，可在setRequestProcessHandler回调配置
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"github"] = @"https://github.com/Suzhibin/ZBNetworking";
    parameters[@"jianshu"] = @"https://www.jianshu.com/p/55cda3341d11";
    parameters[@"iap"]=@"0";
     */
    /*不推荐在此 配置headers，，可在setRequestProcessHandler回调配置
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
   // headers[@"Token"] = @"Token";❌❌❌❌//如果请求头内的Token 是动态获取，比如登陆后获取的 ，不在此设置Token 可以在插件 setRequestProcessHandler 方法内添加❌❌
     */
    [ZBRequestManager setupBaseConfig:^(ZBConfig * _Nullable config) {
        /**
         config.baseServer 设置基础服务器地址
         如果同一个环境，有多个服务器地址，可以在每个请求单独设置 requestr.server  优先级大于config.baseServer
         */
        config.baseServer=url_server;
        /**
         config.parameters公共参数
         如果同一个环境，有多个服务器地址，公共参数不同有两种方式
         1.在每个请求单独添加parameters
         2.在插件机制里 预处理 请求。判断对应的server添加
         3.此回调只会在配置时调用一次，如果不变的公共参数可在此配置，动态的参数不要在此配置，总体不推荐在此配置。可以在插件 setRequestProcessHandler 方法内添加
         // config.parameters=parameters;
         */
       
        // filtrationCacheKey因为时间戳是变动参数，缓存key需要过滤掉 变动参数,如果 不使用缓存功能 或者 没有变动参数 则不需要设置。
        config.filtrationCacheKey=@[@"timeString"];
        /**
         ⚠️⚠️⚠️config.headers公共参数
         .此回调只会在配置时调用一次，如果请求头内的Token 是动态获取 ，不在此设置Token ，总体不推荐在此配置。可以在插件 setRequestProcessHandler 方法内添加
         config.headers=headers;//请求头 非动态配置⚠️⚠️⚠️
         */
     
        config.requestSerializer=ZBJSONRequestSerializer; //全局设置 请求格式 默认JSON
        config.responseSerializer=ZBJSONResponseSerializer; //全局设置 响应格式 默认JSON
        //config.defaultMethodType=ZBMethodTypePOST;//更改默认请求类型，如果服务器给的接口大多不是get 请求，可以在此更改。单次请求，就不用在标明请求类型了。
        config.timeoutInterval=15;//超时时间 只能在此设置超时时间，单次请求不可设置了
        //config.retryCount=2;//请求失败 所有请求重新连接次数
        config.consoleLog=YES;//开log
        config.userInfo=@{@"info":@"ZBNetworking"};//自定义请求的信息，可以用来注释和判断使用，不会传给服务器
        /** responseContentTypes
         内部已存在的响应数据类型
         @"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript",@"text/xml",@"image/*",@"multipart/form-data",@"application/octet-stream",@"application/zip"
         */
        config.responseContentTypes=@[@"application/pdf",@"video/mpeg4"];//添加新的响应数据类型
        /*
         重新赋值HTTPMethodsEncodingParametersInURI，用于调整 不同请求类型的参数是否拼接url后 还是峰封装在request body内
         解决DELETE 方法返回 Unsupported Media Type 的解决方案（如无此问题，不要设置此属性）
         默认为GET，HEAD和DELETE。去掉DELETE，保障DELETE请求成功
         */
        config.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
    }];
     
    #pragma mark -  插件机制
    /**
       插件机制
       自定义 所有 请求,响应,错误 处理逻辑的方法
       在这里 你可以根据request对象的参数 添加你的逻辑 比如server,url,userInfo,parameters
       此回调每次请求时调用一次，如果公共参数是动态的 可在此配置。
     
       比如 1.自定义缓存逻辑 感觉ZBNetworking缓存不好，想使用yycache 等
           2.自定义响应逻辑 服务器会在成功回调里做 返回code码的操作
           3.一个应用有多个服务器地址，可在此进行单独配置参数
           4.统一loading 等UI处理
           5.业务数据数据的一些处理
           6. ......
       */
    //预处理 请求
    
    //配置参数

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"github"] = @"https://github.com/Suzhibin/ZBNetworking";
    parameters[@"jianshu"] = @"https://www.jianshu.com/p/55cda3341d11";
    parameters[@"iap"]=@"0";
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  
    [ZBRequestManager setRequestProcessHandler:^(ZBURLRequest * _Nullable request, id  _Nullable __autoreleasing * _Nullable setObject) {
        NSLog(@"插件响应 请求之前 可以进行参数加工,动态参数可在此添加");
        
        request.url=[self urlProtect:request.url];//可在此 对url 进行加工过滤处理
        
        if ([request.parameters isKindOfClass:[NSDictionary class]]){
            [request.parameters addEntriesFromDictionary:parameters];//此回调每次请求时调用一次，如果公共参数 可在此配置
        }
        //需要动态获取的参数 要在回调内取
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        NSString *timeString = [NSString stringWithFormat:@"%.2f",timeInterval];
        request.parameters[@"timeString"]=timeString;//时间戳
        
        request.headers=headers;
        request.headers[@"Token"]=@"Token";//如果请求头内的Token 是动态获取，比如登陆后获取的 ，在此设置Token
 
        
        if ([request.userInfo[@"tag"]isEqualToString:@"9999"]) {
            //如果不使用 其他缓存框架可忽略
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
                //请求成功 不对数据进行加工过滤等操作，也不用 return
                /*
                // 如要对数据进行加工过滤， json 转模型等
                NSDictionary *resultData = responseObject[@"data"];
                Model *model=[[Model alloc]initWithDict:resultData];
                return model;  //数据进行加工过滤过 必须return
                 */
            }
        }

        if([request.userInfo[@"tag"]isEqualToString:@"9999"]){
            //如果不使用 其他缓存框架可忽略
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
    
    #pragma mark - 动态获取网络状态
    [ZBRequestManager setReachabilityStatusChangeBlock:^(ZBNetworkReachabilityStatus status) {
        switch (status) {
            case ZBNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                break;
            case ZBNetworkReachabilityStatusNotReachable:
                NSLog(@"断网");
                break;
            case ZBNetworkReachabilityStatusViaWWAN:
                NSLog(@"蜂窝数据");
                break;
            case ZBNetworkReachabilityStatusViaWiFi:
                NSLog(@"WiFi网络");
                break;
            default:
                break;
        }
    }];
    //默认已经开启了 检测网络状态startMonitoring

   
    #pragma mark -  APM 监控
    /**
        APM 监控
        注意 使用需要 iOS10 以上  ，AFNetworking4.0以上。
        setTaskDidFinishCollectingMetricsBlock 实现请求的 网络指标上报
     */
    [[ZBRequestEngine defaultEngine] setTaskDidFinishCollectingMetricsBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLSessionTaskMetrics * _Nullable metrics) {
        [metrics.transactionMetrics enumerateObjectsUsingBlock:^(NSURLSessionTaskTransactionMetrics * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.resourceFetchType == NSURLSessionTaskMetricsResourceFetchTypeNetworkLoad){
                APMModel *model = [[APMModel alloc] init];
                //token为 Header的自定义参数  在插件 setRequestProcessHandler 添加的
                model.token = obj.request.allHTTPHeaderFields[@"Token"];
                
                model.req_url = [obj.request.URL absoluteString];
                model.req_params = [obj.request.URL parameterString];
                model.req_headers = obj.request.allHTTPHeaderFields;
                
                if (@available(iOS 13.0, *)) {
                    model.req_header_byte = obj.countOfRequestHeaderBytesSent;
                    model.req_body_byte = obj.countOfRequestBodyBytesSent;
                    
                    model.res_header_byte = obj.countOfResponseHeaderBytesReceived;
                    model.res_body_byte = obj.countOfResponseBodyBytesReceived;
                }
            
                if (@available(iOS 13.0, *)) {
                    model.local_ip = obj.localAddress;
                    model.local_port = obj.localPort.integerValue;
                    
                    model.remote_ip = obj.remoteAddress;
                    model.remote_port = obj.remotePort.integerValue;
                }
                
                if (@available(iOS 13.0, *)) {
                    model.cellular = obj.cellular;
                }
                
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)obj.response;
                if ([response isKindOfClass:NSHTTPURLResponse.class]){
                    model.res_headers = response.allHeaderFields;
                    model.status_code = response.statusCode;
                }
                
                model.http_method = obj.request.HTTPMethod;
                model.protocol_name = obj.networkProtocolName;
                model.proxy_connection = obj.proxyConnection;
                
                if (obj.domainLookupStartDate &&
                    obj.domainLookupEndDate){
                    model.dns_time = ceil([obj.domainLookupEndDate timeIntervalSinceDate:obj.domainLookupStartDate] * 1000);
                }
                
                if (obj.connectStartDate &&
                    obj.connectEndDate){
                    model.tcp_time = ceil([obj.connectEndDate timeIntervalSinceDate:obj.connectStartDate] * 1000);
                }
               
                if (obj.secureConnectionStartDate &&
                    obj.secureConnectionEndDate){
                    model.ssl_time = ceil([obj.secureConnectionEndDate timeIntervalSinceDate:obj.secureConnectionStartDate] * 1000);
                }
                
                if (obj.requestStartDate &&
                    obj.requestEndDate){
                    model.req_time = ceil([obj.requestEndDate timeIntervalSinceDate:obj.requestStartDate] * 1000);
                }
                
                if (obj.responseStartDate &&
                    obj.responseEndDate){
                    model.res_time = ceil([obj.responseEndDate timeIntervalSinceDate:obj.responseStartDate] * 1000);
                }
                
                if (obj.fetchStartDate &&
                    obj.responseEndDate){
                    model.req_total_time = ceil([obj.responseEndDate timeIntervalSinceDate:obj.fetchStartDate] * 1000);
                }
                NSLog(@"在此可进行 网络指标上报 或 添加到容器等时机批量上报：%@",model);
            }
        }];
    }];

}
//URL处理 不可见字符的问题 https://github.com/Suzhibin/ZBNetworking/issues/18
+(NSString *)urlProtect:(NSString *)url{
    if ([url containsString:@"\u200B"]) {
        return [url stringByReplacingOccurrencesOfString:@"\u200B" withString:@""];
    }
    return url;
}
@end
