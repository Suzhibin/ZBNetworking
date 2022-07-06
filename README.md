# ZBNetworking    [介绍文档](http://www.jianshu.com/p/55cda3341d11)
 
 本来想发布到cocoaPods的发现名字已经被使用了，也不想改名了。大家就手动下载用吧

[变更日志](https://github.com/Suzhibin/ZBNetworking/blob/master/CHANGELOG)

[码云gitee](https://gitee.com/AndiSuzhibin/ZBNetworking)

优点:

1.请求类型丰富 /**GET请求*//**POST请求*//**PUT请求*//**PATCH请求*//**DELETE请求*//**Upload请求*//**DownLoad请求*/

2.低耦合，易扩展。

3.通过Block配置信息，有Block回调，delegate回调 ,支持公共配置;

4.请求参数parameters 支持字典，数组，字符串等类型

5.有插件机制  可以统一 预处理 所有 请求,响应,错误 处理逻辑的方法

6.内存缓存，沙盒缓存，有缓存文件过期机制 默认一周

7.显示缓存大小/个数，全部清除缓存/单个文件清除缓存/按时间清除缓存/按路径清除缓存  方法多样  并且都可以自定义路径   可扩展性强

8.有缓存key过滤功能

9.DownLoad支持断点下载 ，批量请求等功能

10.重复请求的处理 ，可设置 保留第一次请求或最后一次请求

11.多种请求缓存类型的判断。也可不遵循，自由随你定。

```objective-c
  /**
     重新请求:   不读取缓存，不存储缓存
     没有缓存需求的，单独使用
     */
    ZBRequestTypeRefresh,
    
    /**
     重新请求:   不读取缓存，但存储缓存
     可以与 ZBRequestTypeCache 配合使用
     */
    ZBRequestTypeRefreshAndCache,
    /**
     读取缓存:   有缓存,读取缓存--无缓存，重新请求并存储缓存
     可以与ZBRequestTypeRefreshAndCache 配合使用
     */
    ZBRequestTypeCache,
    /**
     重新请求：  上拉加载更多业务，不读取缓存，不存储缓存
     用于区分业务 可以不用
     */
    ZBRequestTypeRefreshMore,
     /**
     重新请求:  不读取缓存，不存储缓存.同一请求重复请求，请求结果没有响应的时候，使用第一次请求结果
     如果请求结果响应了，会终止此过程
     */
    ZBRequestTypeKeepFirst,
    /**
     重新请求:   不读取缓存，不存储缓存.同一请求重复请求，请求结果没有响应的时候，使用最后一次请求结果
     如果请求结果响应了，会终止此过程
     */
    ZBRequestTypeKeepLast,
```
12.可见的缓存文件

![](http://a3.qpic.cn/psb?/V12I5WUv0Ual5v/uls*nG1YySR.EpyYI8*lFu9kW.lwzjgW.cnPbGMUBG8!/b/dPgAAAAAAAAA&bo=aAHwAAAAAAACDLE!&rf=viewer_4)

## 使用 
#### 公共配置
```objective-c
 /**
     基础配置
     需要在请求之前配置，设置后所有请求都会带上 此基础配置 
     此回调只会在配置时调用一次，如果不变的公共参数可在此配置,动态的参数不要在此配置
     */
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"github"] = @"https://github.com/Suzhibin/ZBNetworking";
    parameters[@"jianshu"] = @"https://www.jianshu.com/p/55cda3341d11";

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
         3.此回调只会在配置时调用一次，如果不变的公共参数可在此配置，动态的参数不要在此配置。可以在插件 setRequestProcessHandler 方法内添加
         */
        config.parameters=parameters;
        // filtrationCacheKey因为时间戳是变动参数，缓存key需要过滤掉 变动参数,如果 不使用缓存功能 或者 没有变动参数 则不需要设置。
        config.filtrationCacheKey=@[@"timeString"];
        /**
         config.headers公共参数
         .此回调只会在配置时调用一次，如果请求头内的Token 是动态获取 ，不在此设置Token 可以在插件 setRequestProcessHandler 方法内添加
         */
        config.headers=headers;//请求头 
        config.requestSerializer=ZBJSONRequestSerializer; //全局设置 请求格式 默认JSON
        config.responseSerializer=ZBJSONResponseSerializer; //全局设置 响应格式 默认JSON
        config.methodType=ZBMethodTypePOST;//更改默认请求类型，如果服务器给的接口大多不是get 请求，可以在此更改。单次请求，就不用在标明请求类型了。
        config.timeoutInterval=15;//超时时间  优先级 小于 单个请求重新设置
        config.retryCount=2;//请求失败 所有请求重新连接次数
        config.consoleLog=YES;//开log
        config.responseContentTypes=@[@"text/aaa",@"text/bbb"];//添加新的响应数据类型
        /**
         内部已存在的响应数据类型
         @"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript",@"text/xml",@"image/*",@"multipart/form-data",@"application/octet-stream",@"application/zip"
         */
    }];
```
#### 插件机制
```
    /**
       插件机制
       自定义 所有 请求,响应,错误 处理逻辑的方法
       在这里 你可以根据request对象的参数 添加你的逻辑 比如server,url,userInfo,parameters
       此回调每次请求时调用一次，如果公共参数是动态的 可在此配置。
       
       比如 1.自定义缓存逻辑 感觉ZBNetworking缓存不好，想使用yycache 等
           2.自定义响应逻辑 服务器会在成功回调里做 返回code码的操作
           3.一个应用有多个服务器地址，可在此进行配置
           4.统一loading 等UI处理
           5.为某个服务器单独添加参数
           6. ......
       */
    [ZBRequestManager setRequestProcessHandler:^(ZBURLRequest * _Nullable request, id  _Nullable __autoreleasing * _Nullable setObject) {
         NSLog(@"插件响应 请求之前 可以进行参数加工,动态参数可在此添加");
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        NSString *timeString = [NSString stringWithFormat:@"%.2f",timeInterval];
        [request.parameters setValue:timeString forKey:@"timeString"];//时间戳
        //此回调每次请求时调用一次，如果公共参数是动态的 可在此配置
        parameters[@"pb"] = @"从插件机制添加";
        [request.parameters setValue:parameters forKey:@"pb"];//这样添加 其他参数依然存在。
       // request.parameters=parameters;//这样添加 其他参数被删除
        
        headers[@"Token"] = @"从插件机制添加：Token";
        request.headers=headers;//如果请求头内的Token 是动态获取，比如登陆后获取的 ，在此设置Token
    }];
    
    [ZBRequestManager setResponseProcessHandler:^id(ZBURLRequest * _Nullable request, id  _Nullable responseObject, NSError * _Nullable __autoreleasing * _Nullable error) {
        NSLog(@"成功回调 数据返回之前");
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
```
#### 获取网络状态
```
  //获取网络状态
    ZBNetworkReachabilityStatus status=[ZBRequestManager networkReachability];
    //当前是否有网
    [ZBRequestManager isNetworkReachable];
    //否为WiF
    [ZBRequestManager isNetworkWiFi];
    //动态获取网络状态
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
 ```
#### Block 请求方法
```
//请求方法 会默认创建缓存路径    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"path"] = @"HomeViewController";
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"headers"] = @"herader";
    [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        request.url=list_URL;
        request.methodType=ZBMethodTypeGET;//默认为GET
        request.apiType=ZBRequestTypeRefresh;//（默认为ZBRequestTypeRefresh 不读取缓存，不存储缓存）
        request.parameters=parameters;//支持 字典、数组、字符串 等类型 。
        request.headers=headers;
        request.filtrationCacheKey=@[@""];//与basefiltrationCacheKey 兼容
        request.requestSerializer=ZBJSONRequestSerializer; //单次请求设置 请求格式 默认JSON，优先级大于 全局设置，不影响其他请求设置
        request.responseSerializer=ZBJSONResponseSerializer; //单次请求设置 响应格式 默认JSON，优先级大于 全局设置,不影响其他请求设置
        request.retryCount=2;//请求失败 当次请求重新连接次数
        request.timeoutInterval=10; //优先级 高于 全局设置,不影响其他请求设置
      
    }  success:^(id responseObj,ZBURLRequest * request){
        if (request.apiType==ZBRequestTypeRefresh) 
             //结束刷新
        }
        if (request.apiType==ZBRequestTypeLoadMore) {
            //结束上拉加载
        }
        //请求成功
          NSLog(@"得到数据:%@",responseObject);
      
    } failure:^(NSError *error){
    }];

```
#### Delegate 请求方法
```
  [ZBRequestManager requestWithConfig:^(ZBURLRequest *request) {
       request.url=listUrl;
       request.apiType=type;
  } target:self];//ZBURLRequestDelegate
  
#pragma mark - ZBURLRequestDelegate
- (void)requestSuccess:(ZBURLRequest *)request responseObject:(id)responseObject{
        if (request.apiType==ZBRequestTypeRefresh) 
             //结束刷新
        }
        if (request.apiType==ZBRequestTypeLoadMore) {
            //结束上拉加载
        }
        //请求成功
          NSLog(@"得到数据:%@",responseObject);
}
- (void)requestFailed:(ZBURLRequest *)request error:(NSError *)error{
}
- (void)requestProgress:(NSProgress *)progress{
    NSLog(@"onProgress: %.f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
}
- (void)requestFinished:(ZBURLRequest *)request responseObject:(id)responseObject error:(NSError *)error{
//    NSLog(@"code:%ld",error.code);
//    NSLog(@"URLString:%@",request.URLString);
}

```
#### 断点下载
```
    [ZBRequestManager requestWithConfig:^(ZBURLRequest * request) {
        request.url=@"https://URL";
        request.methodType=ZBMethodTypeDownLoad;
        request.downloadState=ZBDownloadStateStart;//开始 //ZBDownloadStateStop暂停
    } progress:^(NSProgress * _Nullable progress) {
        NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
    } success:^(id  responseObject,ZBURLRequest * request) {
        NSLog(@"ZBMethodTypeDownLoad 此时会返回存储路径文件: %@", responseObject);
         //在任何地方拿到下载文件
        NSString *file=[ZBRequestManager getDownloadFileForKey:request.url];
    } failure:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    }];
```
#### 批量请求
```objective-c
 [ZBRequestManager sendBatchRequest:^(ZBBatchRequest *batchRequest)
            for (NSString *urlString in offlineArray) {
            ZBURLRequest *request=[[ZBURLRequest alloc]init];
            request.url=urlString;
            [batchRequest.urlArray addObject:request];
        }
    }  success:^(id responseObj,ZBURLRequest * request){
    } failure:^(NSError *error){
    } finished:^(NSArray * _Nullable responseObjects, NSArray<NSError *> * _Nullable errors, NSArray<ZBURLRequest *> * _Nullable requests) {
            NSLog(@"批量完成事件");
    }];

//具体演示看demo
```
![](http://a3.qpic.cn/psb?/V12I5WUv0Ual5v/cY8K3L2*GJ9RO3i*z1If9XTmzas0cylmafMXWqdFe4o!/b/dK0AAAAAAAAA&bo=aAHwAAAAAAACLJE!&rf=viewer_4)

#### 取消请求
```
 //取消当前请求
 [ZBRequestManager cancelRequest:identifier];
 //取消批量请求
 [ZBRequestManager cancelBatchRequest:batchRequest];
 //取消所有请求
 [ZBRequestManager cancelAllRequest];
  ```
#### 缓存相关
```objective-c
 //显示缓存大小 可以自定义路径
 [[ZBCacheManager sharedInstance]getCacheSize];
  //显示缓存个数  可以自定义路径
 [[ZBCacheManager sharedInstance]getCacheCount];
 //清除沙盒缓存
 [[ZBCacheManager sharedInstance]clearCache];
 //清除内存缓存
 [[ZBCacheManager sharedInstance]clearMemory];
  //清除单个缓存
 [[ZBCacheManager sharedInstance]clearCacheForkey:list_URL];
 //按时间清除缓存
  [[ZBCacheManager sharedInstance]clearCacheForkey:menu_URL time:60*60];
  //按路径清除缓存
 [[ZBCacheManager sharedInstance]clearDiskWithpath:@"路径" completion:nil];
 ```

![](https://upload-images.jianshu.io/upload_images/1830250-3636c0621ebb6fa1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/621)

#### 缓存key过滤
 ```
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"&time=%f", a];
    
     // 使用了parameters 的请求 缓存key会是URLString+parameters，parameters里有是时间戳或者其他动态参数,key一直变动 无法拿到缓存。所以定义一个 filtrationCacheKey 过滤掉parameters 缓存key里的 变动参数比如 时间戳
    [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        request.url=@"http://URL";
        request.methodType=ZBMethodTypePOST;//默认为GET
        request.parameters=@{@"1": @"one", @"2": @"two", @"time": @"12345667"};
        request.filtrationCacheKey=@[@"time"];//过滤掉time
    }success:nil failure:nil];
  ```


## License

ZBNetworking is released under the MIT license. See LICENSE for details.
