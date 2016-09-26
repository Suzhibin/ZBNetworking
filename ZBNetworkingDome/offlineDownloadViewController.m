//
//  offlineDownloadViewController.m
//  ZBNetworkingDome
//
//  Created by NQ UEC on 16/9/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "offlineDownloadViewController.h"
#import "ZBNetworking.h"
#import "RootModel.h"
#import "DetailsModel.h"
#import "SDWebImageManager.h"
@interface offlineDownloadViewController ()<UITableViewDelegate,UITableViewDataSource,ZBURLSessionDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UIProgressView *pv;
@property (nonatomic,strong)UILabel *progressLabel;
@property (nonatomic,strong)UILabel *nameLabel;

@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)NSMutableArray *imageArray;
@property (nonatomic,strong)ZBURLSessionManager *manager;

@end

@implementation offlineDownloadViewController
- (ZBURLSessionManager *)session {
    return [ZBURLSessionManager shareManager];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
    NSLog(@"离开页面时 清空容器");
    [self.manager removeOfflineArray];
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray=[[NSMutableArray alloc]init];
    self.imageArray=[[NSMutableArray array]init];
    
    //创建单例
     self.manager=[self session];
    
    //保证频道是最新的 不要取缓存
    [self.manager getRequestWithUrlString:home_URL target:self apiType:ZBRequestTypeRefresh];
    
    [self.view addSubview:self.tableView];
  
    [self addItemWithTitle:@"离线下载" selector:@selector(offlineBtnClick) location:NO];
 
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
            
            NSString *path= [[SDImageCache sharedImageCache]defaultCachePathForKey:model.thumb];
            
            //如果sdwebImager 有这个图片 则不下载
            if ([[ZBCacheManager shareCacheManager]fileExistsAtPath:path]) {
                NSLog(@"已经下载了");
            } else{
                //使用SDWebImage 下载图片
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
    
        
    }else{
      //home_URL
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:NSJSONReadingMutableContainers error:nil];
        
        NSArray *array=[dict objectForKey:@"authors"];
        
        for (NSDictionary *dic in array) {
            RootModel *model=[[RootModel alloc]init];
            model.name=[dic objectForKey:@"name"];
            model.wid=[dic objectForKey:@"id"];
            [self.dataArray addObject:model];
            
        }
        [_tableView reloadData];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIde=@"cellIde";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
    }
    UISwitch *sw = [[UISwitch alloc] init];
    sw.center = CGPointMake(160, 90);
    sw.tag = indexPath.row;
    [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = sw;
    
    RootModel *model=[self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text=model.name;
        

    
    return cell;
}
- (void)switchValueChanged:(UISwitch *)sw
{
    RootModel *model=[self.dataArray objectAtIndex:sw.tag];
    NSString *url=[NSString stringWithFormat:details_URL,model.wid];
    
    if (sw.isOn == YES) {
        //添加请求列队
        [self.manager addObjectWithUrl:url];
        [self.manager addObjectWithName:model.name];
      
    }else{
        //删除请求列队
        [self.manager removeObjectWithUrl:url];
        [self.manager removeObjectWithName:model.name];
        
    }
}


- (void)offlineBtnClick
{
    
    if (self.manager.offlineUrlArray.count==0) {
        
        [self alertTitle:@"请添加栏目" andMessage:@""];
        
    }else{
       
        for (NSString *name in self.manager.offlineNameArray) {
            NSLog(@"离线请求的name:%@",name);
        }
        
        NSLog(@"离线请求的url:%@",self.manager.offlineUrlArray);
        NSLog(@"离线请求的栏目/url个数:%lu",self.manager.offlineUrlArray.count);
  
        //离线请求 apiType:ZBRequestTypeOffline
        [self.manager offlineDownload:self.manager.offlineUrlArray target:self apiType:ZBRequestTypeOffline operation:^{
          
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        
    }
}

- (NSString *)progressStrWithSize:(double)size
{
    NSString *progressStr = [NSString stringWithFormat:@"图片下载:%.1f",size* 100];
    return  progressStr = [progressStr stringByAppendingString:@"%"];
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
