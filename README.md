# ZBNetworking    [介绍文档](http://www.jianshu.com/p/55cda3341d11)
优点:

1 低耦合，易扩展。

2.有缓存文件过期机制 默认一周

3.显示缓存大小/个数，全部清除缓存/单个文件清除缓存/按时间清除缓存  方法多样  并且都可以自定义路径   可扩展性强

4.离线下载功能 

5.多种请求类型的判断。也可不遵循，自由随你定。

```objective-c
    ZBRequestTypeDefault,   //默认类型
    ZBRequestTypeRefresh,   //重新请求 （有缓存，不读取，重新请求）
    ZBRequestTypeLoadMore,  //加载更多
    ZBRequestTypeDetail,    //详情
    ZBRequestTypeOffline,   //离线    （有缓存，不读取，重新请求）
    ZBRequestTypeCustom     //自定义
```
6.可见的缓存文件

![](http://a3.qpic.cn/psb?/V12I5WUv0Ual5v/uls*nG1YySR.EpyYI8*lFu9kW.lwzjgW.cnPbGMUBG8!/b/dPgAAAAAAAAA&bo=aAHwAAAAAAACDLE!&rf=viewer_4)

## 使用 
```objective-c
//get请求方法 会默认创建缓存路径    
  [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        request.urlString=list_URL;
        request.methodType=ZBMethodTypeGET;//默认为GET
        request.apiType=ZBRequestTypeDefault;//默认为default
        request.timeoutInterval=10;
       // request.parameters=@{@"1": @"one", @"2": @"two"};
       // [request setValue:@"1234567890" forHeaderField:@"apitype"];
    }  success:^(id responseObj,apiType type){
        if (type==ZBRequestTypeRefresh) 
             //结束刷新
        }
        if (type==ZBRequestTypeLoadMore) {
            //结束上拉加载
        }
        //请求成功
        
    } failed:^(NSError *error){
        if (error.code==NSURLErrorCancelled)return;
        if (error.code==NSURLErrorTimedOut){
            [self alertTitle:@"请求超时" andMessage:@""];
        }else{
            [self alertTitle:@"请求失败" andMessage:@""];
        }
    }];

```





## 使用 其他功能
1.离线下载


```objective-c
 [ZBNetworkManager requestWithConfig:^(ZBURLRequest *request)
        request.urlArray=offlineArray;
        request.apiType=ZBRequestTypeOffline;   //离线请求 apiType:ZBRequestTypeOffline
    }  success:^(id responseObj,apiType type){
        //如果是离线请求的数据
        if (type==ZBRequestTypeOffline) {
        
        } 
    } failed:^(NSError *error){
        if (error.code==NSURLErrorCancelled)return;
        if (error.code==NSURLErrorTimedOut){
            [self alertTitle:@"请求超时" andMessage:@""];
        }else{
            [self alertTitle:@"请求失败" andMessage:@""];
        }
    }];

//具体演示看demo
```
![](http://a3.qpic.cn/psb?/V12I5WUv0Ual5v/cY8K3L2*GJ9RO3i*z1If9XTmzas0cylmafMXWqdFe4o!/b/dK0AAAAAAAAA&bo=aAHwAAAAAAACLJE!&rf=viewer_4)


2.缓存相关
```objective-c
//显示缓存大小
 [[ZBCacheManager sharedInstance]getCacheSize];
 //删除缓存
[[ZBCacheManager sharedInstance]clearCache];
 ```
