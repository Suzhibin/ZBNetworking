# ZBNetworking
NSURLSession 网络请求的封装  添加了缓存功能，显示缓存大小，删除缓存等功能 
## 使用
1.添加#import "ZBNetworking.h"

2.添加 代理
```objective-c
<ZBURLSessionDelegate>
```

3.使用简单  一行代码调用
```objective-c
//get请求方法 会创建缓存路径 
  [ZBURLSessionManager getRequestWithUrlString:URL target:self];
```


4.成功和失败俩个代理回调
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

