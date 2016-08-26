# ZBNetworking
NSURLSession 网络请求的封装  添加了缓存功能，显示缓存大小，删除缓存等功能 
## 使用
1.添加#import "ZBNetworking.h"

2.添加 Delegate
```objective-c
<ZBURLSessionDelegate>
```

3.使用简单:  类方法一行调用   或   实例方法调用
```objective-c
//get请求方法 会默认创建缓存路径 
  1.类方法
  [ZBURLSessionManager getRequestWithUrlString:URL target:self];
  
  2.实例方法
  ZBURLSessionManager *manager=[ZBURLSessionManager manager];
  [manager getRequestWithUrlString:URL target:self];
    实例方法还可以做其他操作
  [manager setTimeoutInterval:10];//更改超时时间 

```

4.完成和失败俩个代理回调
```objective-c
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
- (void)urlRequestFailed:(ZBURLSessionManager *)request
{
    NSLog(@"请求失败");
}
```

