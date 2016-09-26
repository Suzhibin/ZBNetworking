# ZBNetworking
NSURLSession 网络请求的封装  添加了缓存功能，离线下载，显示缓存大小，删除缓存等功能 
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

  //如果是离线数据
    if (request.apiType==ZBRequestTypeOffline) {
        NSLog(@"添加了几个url  就会走几遍");
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:NSJSONReadingMutableContainers error:nil];
        NSArray *array=[dict objectForKey:@"videos"];
        for (NSDictionary *dic in array) {
            DetailsModel *model=[[DetailsModel alloc]init];
            model.thumb=[dic objectForKey:@"thumb"]; //找到图片的key
            [self.imageArray addObject:model];
            
             //使用SDWebImage 下载图片
            NSString *path= [[SDImageCache sharedImageCache]defaultCachePathForKey:model.thumb];
            //如果sdwebImager 有这个图片 则不下载
            if ([[ZBCacheManager shareCacheManager]fileExistsAtPath:path]) {
                NSLog(@"已经下载了");
            } else{
               
                SDWebImageOptions options = SDWebImageRetryFailed ;
                [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:model.thumb] options:options progress:^(NSInteger receivedSize, NSInteger expectedSize){
                    
                    [self.delegate progressSize:(double)receivedSize/expectedSize];
                    
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,BOOL finished,NSURL *imageURL){
                    
                    NSLog(@"单个图片下载完成");
                    [self.delegate progressSize:0.0];
                    
                    //让 下载的url与模型的最后一个比较，如果相同证明下载完毕。
                    NSString *imageURLStr = [imageURL absoluteString];
                    NSString *lastImage=[NSString stringWithFormat:@"%@",((DetailsModel *)[self.imageArray lastObject]).thumb];
                    if ([imageURLStr isEqualToString:lastImage]) {
                        NSLog(@"下载完成");
                        [self.delegate Finished];
                        
                    }

                }];

            }
            
          
        }
    
        
    }
```
6.其他操作
```objective-c
//显示缓存大小
 [[ZBCacheManager shareCacheManager]getCacheSize];
 //删除缓存
[[ZBCacheManager shareCacheManager]clearCache];
 ```
