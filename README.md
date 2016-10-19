# ZBNetworking
一站式缓存解决方案 集成get请求缓存,离线下载,html缓存,显示缓存大小,删除缓存等功能 — 
低耦合，易扩展。

## 使用
1.添加#import "ZBNetworking.h"

2.添加 delegate
```objective-c
<ZBURLSessionDelegate>
```

3.使用简单:  一行代码调用 
```objective-c
//get请求方法 会默认创建缓存路径    
  [[ZBURLSessionManager shareManager] getRequestWithUrlString:URL target:self];
 
 // 还可以做其他操作 注意:要放在请求前
  [[ZBURLSessionManager shareManager] setTimeoutInterval:10];//更改超时时间 
  [[ZBURLSessionManager shareManager] setValue:@"my the apikey" forHTTPHeaderField:@"apikey"]//设置请求头

```

4.完成和失败俩个代理回调
```objective-c
//请求完成的代理方法里进行解析或赋值
- (void)urlRequestFinished:(ZBURLSessionManager *)request
{
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:NSJSONReadingMutableContainers error:nil];
    NSArray *array=[dict objectForKey:@"authors"];
    
    for (NSDictionary *dic in array) {
        RootModel *model=[[RootModel alloc]init];
        model.icon=[dic objectForKey:@"icon"];
        model.name=[dic objectForKey:@"name"];
        model.wid=[dic objectForKey:@"id"];
        model.detail=[dic objectForKey:@"detail"];
        [_dataArray addObject:model];
        
    }
    [_tableView reloadData];
    
    
    
}
//请求失败的方法里 进行异常判断 支持error.code所有异常
- (void)urlRequestFailed:(ZBURLSessionManager *)request
{
    if (request.error.code==-999)return;
    if (request.error.code==NSURLErrorTimedOut) {
        NSLog(@"请求超时");
    }else{
        NSLog(@"请求失败");
    }

}
```
5.离线下载
```objective-c
[[ZBURLSessionManager shareManager] offlineDownload:[ZBURLSessionManager shareManager].offlineUrlArray target:self apiType:ZBRequestTypeOffline];
//具体演示看demo
```
![](http://a3.qpic.cn/psb?/V12I5WUv0Ual5v/cY8K3L2*GJ9RO3i*z1If9XTmzas0cylmafMXWqdFe4o!/b/dK0AAAAAAAAA&bo=aAHwAAAAAAACLJE!&rf=viewer_4)

6.html缓存 uiwebView只要一句判断就可以使用缓存   由于uiwebView内存泄漏 demo里进入web页面内存会涨
```objective-c
    if ([[ZBHTMLManager shareManager]diskhtmlUrl:self.weburl]==YES) {
        NSLog(@"UIWebView读缓存");
        NSString *html=[[ZBWebViewManager shareManager]htmlString:self.weburl];
        [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:self.weburl]];
    }else{
        NSLog(@"UIWebView重新请求");
        NSURL *url = [NSURL URLWithString:self.weburl];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }

```
7.其他操作
```objective-c
//显示缓存大小
 [[ZBCacheManager shareCacheManager]getCacheSize];
 //删除缓存
[[ZBCacheManager shareCacheManager]clearCache];
 ```
