//
//  SettingViewController.m
//  ZBNetworkingDome
//
//  Created by NQ UEC on 16/8/24.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "SettingViewController.h"
#import "ZBNetworking.h"
#import "offlineDownloadViewController.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "OfflineView.h"
#import "DetailsModel.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource,offlineDelegate,ZBURLSessionDelegate>

@property (nonatomic,copy)NSString *path;
@property (nonatomic,strong)NSMutableArray *imageArray;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)OfflineView *offlineView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageArray=[[NSMutableArray array]init];
    //得到沙盒cache文件夹
    NSString *cachePath= [[ZBCacheManager shareCacheManager]getCachesDirectory];
    NSString *Snapshots=@"Snapshots";
    //拼接cache文件夹下的 Snapshots 文件夹
    self.path=[NSString stringWithFormat:@"%@/%@",cachePath,Snapshots];
    
    [self.view addSubview:self.tableView];


}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIde=@"cellIde";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIde];
    }
    if (indexPath.row==0) {
        cell.textLabel.text=@"清除缓存";
        
        float cacheSize=[[ZBCacheManager shareCacheManager]getCacheSize];//json缓存文件大小
        float imageSize = [[SDImageCache sharedImageCache]getSize];//图片缓存大小
        float AppCacheSize=cacheSize+imageSize;
        AppCacheSize=AppCacheSize/1000.0/1000.0;
  
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%.2fM",AppCacheSize];

    }
    if (indexPath.row==1) {
        cell.textLabel.text=@"缓存文件数量";
        
        float cacheCount=[[ZBCacheManager shareCacheManager]getCacheCount];//json缓存文件个数
        float imageCount=[[SDImageCache sharedImageCache]getDiskCount];//图片缓存个数
         float AppCacheCount=cacheCount+imageCount;
        cell.detailTextLabel.text= [NSString stringWithFormat:@"%.f",AppCacheCount];
        
    }

    if (indexPath.row==2) {
        cell.textLabel.text=@"清除某个沙盒文件";
    
        float size=[[ZBCacheManager shareCacheManager]getFileSizeWithpath:self.path];

        //fileUnitWithSize 转换单位方法
        cell.detailTextLabel.text=[[ZBCacheManager shareCacheManager] fileUnitWithSize:size];

    }
    if (indexPath.row==3) {
        cell.textLabel.text=@"某个沙盒文件数量";
      
        float count=[[ZBCacheManager shareCacheManager]getFileCountWithpath:self.path];
        
        cell.detailTextLabel.text= [NSString stringWithFormat:@"%.f",count];
        
    }
    
    if (indexPath.row==4) {
        cell.textLabel.text=@"离线下载";
         cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row==0) {
        
        [[NSURLCache sharedURLCache]removeAllCachedResponses];
        
        //清除缓存
        [[ZBCacheManager shareCacheManager]clearCacheOnOperation:^{
            //清除图片缓存
            [[SDImageCache sharedImageCache] clearDisk];
            [[SDImageCache sharedImageCache] clearMemory];
            
            [self.tableView reloadData];
            
        }];
    }
    
    if (indexPath.row==2) {
        
        //清除某个沙盒文件内容
        [[ZBCacheManager shareCacheManager]clearDiskWithpath:self.path operation:^{
            
            [self.tableView reloadData];
            
        }];
    }
    if (indexPath.row==4) {
       
        offlineDownloadViewController *offlineVC=[[offlineDownloadViewController alloc]init];
        offlineVC.delegate=self;
        [self.navigationController pushViewController:offlineVC animated:YES];
        
    }
    
}
#pragma mark offlineDelegate
- (void)downloadWithArray:(NSMutableArray *)offlineArray
{
    //离线请求 apiType:ZBRequestTypeOffline
    [[ZBURLSessionManager shareManager] offlineDownload:offlineArray target:self apiType:ZBRequestTypeOffline];
    
    self.offlineView=[[OfflineView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    [self.offlineView.cancelButton addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow addSubview:self.offlineView];
}

#pragma mark - ZBURLSessionManager Delegate
- (void)urlRequestFinished:(ZBURLSessionManager *)request
{
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
            //如果sdwebImage 有这个图片 则不下载
            if ([[ZBCacheManager shareCacheManager]fileExistsAtPath:path]) {
                NSLog(@"已经下载了");
                self.offlineView.progressLabel.text=@"已经下载了";
            } else{
             
                SDWebImageOptions options = SDWebImageRetryFailed ;
                [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:model.thumb] options:options progress:^(NSInteger receivedSize, NSInteger expectedSize){
                    
                     NSLog(@"%@",[self progressStrWithSize:(double)receivedSize/expectedSize]);
                    self.offlineView.progressLabel.text=[self progressStrWithSize:(double)receivedSize/expectedSize];
                    self.offlineView.pv.progress =(double)receivedSize/expectedSize;
                    
                    [self.tableView reloadData];
                    
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,BOOL finished,NSURL *imageURL){
                
                    NSLog(@"单个图片下载完成");
                    self.offlineView.progressLabel.text=[self progressStrWithSize:0.0];
                    
                    self.offlineView.pv.progress = 0.0;
                    
                    [self.tableView reloadData];
                    
                    //让 下载的url与模型的最后一个比较，如果相同证明下载完毕。
                    NSString *imageURLStr = [imageURL absoluteString];
                    NSString *lastImage=[NSString stringWithFormat:@"%@",((DetailsModel *)[self.imageArray lastObject]).thumb];
                    if ([imageURLStr isEqualToString:lastImage]) {
                        NSLog(@"下载完成");
                        [self alertTitle:@"下载完成" andMessage:@""];
                        [self.offlineView hide];
                       
                    }
                    if (error) {
                        NSLog(@"下载失败");
                    }
                }];
                
            }
            
            
        }
        
        
    }
}
- (void)urlRequestFailed:(ZBURLSessionManager *)request
{
    if (request.error.code==NSURLErrorCancelled)return;
    if (request.error.code==NSURLErrorTimedOut) {
        
        [self alertTitle:@"请求超时" andMessage:@""];
    }else{
        
        [self alertTitle:@"请求失败" andMessage:@""];
    }
}


- (void)cancelClick
{
    [[ZBURLSessionManager shareManager] requestToCancel:YES];
    [[SDWebImageManager sharedManager] cancelAll];
    [self.offlineView hide];
    NSLog(@"取消下载");
}

//懒加载
- (UITableView *)tableView
{
    
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.tableFooterView=[[UIView alloc]init];
        
    }
    
    return _tableView;
}

- (NSString *)progressStrWithSize:(double)size
{
    NSString *progressStr = [NSString stringWithFormat:@"图片下载:%.1f",size* 100];
    return  progressStr = [progressStr stringByAppendingString:@"%"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
