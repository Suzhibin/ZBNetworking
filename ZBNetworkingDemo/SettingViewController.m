//
//  SettingViewController.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/8/24.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "SettingViewController.h"
#import "ZBNetworking.h"
#import "offlineDownloadViewController.h"
#import <SDImageCache.h>
#import <SDWebImageManager.h>
#import "DetailsModel.h"
#import "HomeModel.h"
#import "DataManager.h"
static const NSInteger cacheTime = 15;//过期时间
@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource,offlineDelegate>

@property (nonatomic,copy)NSString *imagePath;
@property (nonatomic,strong)NSMutableArray *imageArray;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)ZBBatchRequest *batchRequest;
@end

@implementation SettingViewController
- (void)dealloc{
    NSLog(@"释放%s",__func__);
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //[self cancelClick];//如果退出页面可以取消下载，看产品需求
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //得到沙盒cache文件夹下的系统缓存文件路径
    NSString *cachePath= [[ZBCacheManager sharedInstance]cachesPath];
    
    //得到沙盒cache文件夹下的 SDWebImage 存储路径
    NSString *sdImage=@"com.hackemist.SDImageCache/default";
    self.imagePath=[NSString stringWithFormat:@"%@/%@",cachePath,sdImage];
    
    [self.view addSubview:self.tableView];
    
    [self addItemWithTitle:@"取消离线下载" selector:@selector(cancelClick) location:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 15;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIde=@"cellIde";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIde];
      
    }
    
    if (indexPath.row==0) {
        cell.textLabel.text=@"清除全部缓存";
        
        CGFloat cacheSize=[[ZBCacheManager sharedInstance]getCacheSize];//json缓存文件大小
        CGFloat imageSize = [[SDImageCache sharedImageCache]totalDiskSize];//图片缓存大小
        CGFloat AppCacheSize=cacheSize+imageSize;
        AppCacheSize=AppCacheSize/1000.0/1000.0;
        
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%.2fM",AppCacheSize];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row==1) {
        cell.textLabel.text=@"全部缓存数量";
        cell.userInteractionEnabled = NO;
        
        CGFloat cacheCount=[[ZBCacheManager sharedInstance]getCacheCount];//json缓存文件个数
        CGFloat imageCount=[[SDImageCache sharedImageCache]totalDiskCount];//图片缓存个数
        CGFloat AppCacheCount=cacheCount+imageCount;
        cell.detailTextLabel.text= [NSString stringWithFormat:@"%.f",AppCacheCount];
        
    }

    if (indexPath.row==2) {
        cell.textLabel.text=@"清除json缓存";
        
        CGFloat cacheSize=[[ZBCacheManager sharedInstance]getCacheSize];//json缓存文件大小
    
        cacheSize=cacheSize/1000.0/1000.0;
        CGFloat size=[[ZBCacheManager sharedInstance]getCacheSize];//json缓存文件大小
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%.2fM(%@)",cacheSize,[[ZBCacheManager sharedInstance] fileUnitWithSize:size]];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row==3) {
        cell.textLabel.text=@"json缓存数量";
         cell.userInteractionEnabled = NO;
        
        CGFloat cacheCount=[[ZBCacheManager sharedInstance]getCacheCount];//json缓存文件个数
        
        cell.detailTextLabel.text= [NSString stringWithFormat:@"%.f",cacheCount];
        
    }
    
    if (indexPath.row==4) {
        cell.textLabel.text=@"清除图片缓存方法";
         CGFloat imageSize = [[SDImageCache sharedImageCache]totalDiskSize];//图片缓存大小
        
         imageSize=imageSize/1000.0/1000.0;
        
         cell.detailTextLabel.text=[NSString stringWithFormat:@"%.2fM",imageSize];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row==5) {
        cell.textLabel.text=@"图片缓存数量方法";
        cell.userInteractionEnabled = NO;
        
        CGFloat imageCount=[[SDImageCache sharedImageCache]totalDiskCount];//图片缓存个数
        
        cell.detailTextLabel.text= [NSString stringWithFormat:@"%.f",imageCount];
    }
    
    if (indexPath.row==6) {
        cell.textLabel.text=@"清除自定义路径缓存";
    
        CGFloat cacheSize=[[ZBCacheManager sharedInstance]getFileSizeWithPath:self.imagePath];
        
        cacheSize=cacheSize/1000.0/1000.0;
        
        CGFloat size=[[ZBCacheManager sharedInstance]getFileSizeWithPath:self.imagePath];

        //fileUnitWithSize 转换单位方法
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%.2fM(%@)",cacheSize,[[ZBCacheManager sharedInstance] fileUnitWithSize:size]];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row==7) {
        cell.textLabel.text=@"自定义路径缓存数量";
        cell.userInteractionEnabled = NO;
        
        CGFloat count=[[ZBCacheManager sharedInstance]getFileCountWithPath:self.imagePath];
        
        cell.detailTextLabel.text= [NSString stringWithFormat:@"%.f",count];
        
    }
    if (indexPath.row==8) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=@"清除单个json缓存文件(例:删除首页)";
        
    }
    if (indexPath.row==9) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=@"清除单个图片缓存文件(手动添加url)";
    }
    
    if (indexPath.row==10) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=@"按过期时间清除“单个”json缓存(例:menu,超15秒)";
        cell.textLabel.font=[UIFont systemFontOfSize:14];
    }
    
    if (indexPath.row==11) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=@"按过期时间清除“单个”图片缓存(手动添加url,超15秒)";
        cell.textLabel.font=[UIFont systemFontOfSize:14];
    }

    if (indexPath.row==12) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=@"按过期时间清除全部过期json缓存(例:超过15秒)";
        cell.textLabel.font=[UIFont systemFontOfSize:14];
    }
    
    if (indexPath.row==13) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=@"按过期时间清除全部过期图片缓存(例:超过15秒)";
        cell.textLabel.font=[UIFont systemFontOfSize:14];
    }
    
    if (indexPath.row==14) {
        cell.textLabel.text=@"离线下载";
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row==0) {
        
        //清除json缓存后的操作
        [[ZBCacheManager sharedInstance]clearCacheOnCompletion:^{
            [[ZBCacheManager sharedInstance]clearMemory];
            //清除图片缓存
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
            [[SDImageCache sharedImageCache] clearMemory];
       
            [self.tableView reloadData];
            
        }];
    }
    if (indexPath.row==2) {
        //清除json缓存
        //[[ZBCacheManager sharedInstance]clearCache];
        [[ZBCacheManager sharedInstance]clearCacheOnCompletion:^{
            [[ZBCacheManager sharedInstance]clearMemory];
             [self.tableView reloadData];
        }];
    }
    
    if (indexPath.row==4) {
        //清除图片缓存
      //  [[SDImageCache sharedImageCache] clearDisk];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            [[SDImageCache sharedImageCache] clearMemory];
            [self.tableView reloadData];
        }];
    }

    if (indexPath.row==6) {

        //用ZBCacheManager 方法代替sdwebimage方法
        // [[ZBCacheManager sharedInstance]clearDiskWithpath:self.imagePath];
        [[ZBCacheManager sharedInstance]clearDiskWithPath:self.imagePath completion:^{
            [self.tableView reloadData];
            
        }];
    }
    if (indexPath.row==8) {
        
        //清除单个缓存文件
        // [[ZBCacheManager sharedInstance]clearCacheForkey:[DataManager sharedInstance].cacheKey];
       
        [[ZBCacheManager sharedInstance]clearCacheForkey:[DataManager sharedInstance].cacheKey completion:^{
            
         [self.tableView reloadData];
            
        }];
    }
    
    if (indexPath.row==9) {
        
        //清除单个图片缓存文件
        //url 过期 去log里找新的
        [[ZBCacheManager sharedInstance]clearCacheForkey:@"https://r1.ykimg.com/054101015918B62E8B3255666622E929" inPath:self.imagePath  completion:^{
            
            [self.tableView reloadData];
        }];
    }
    
    if (indexPath.row==10) {
 
        //[[ZBCacheManager sharedInstance]clearCacheForkey:[DataManager sharedInstance].cacheKey time:cacheTime]
        [[ZBCacheManager sharedInstance]clearCacheForkey:[DataManager sharedInstance].cacheKey time:cacheTime completion:^{
            [self.tableView reloadData];
        }];
    }
    if (indexPath.row==11) {
       
        //图片url 过期 去log里找新的
        [[ZBCacheManager sharedInstance]clearCacheForkey:@"https://r1.ykimg.com/054101015918B62E8B3255666622E929" time:cacheTime inPath:self.imagePath completion:^{
            [self.tableView reloadData];
        }];
    }
    if (indexPath.row==12) {
 
        [[ZBCacheManager sharedInstance]clearCacheWithTime:cacheTime completion:^{
            [self.tableView reloadData];
        }];
    }
    
    if (indexPath.row==13) {
         // 路径要准确
        [[ZBCacheManager sharedInstance]clearCacheWithTime:cacheTime inPath:self.imagePath completion:^{
            [self.tableView reloadData];
        }];
    }
    if (indexPath.row==14) {
       
        offlineDownloadViewController *offlineVC=[[offlineDownloadViewController alloc]init];
        offlineVC.delegate=self;
        [self.navigationController pushViewController:offlineVC animated:YES];
    }
}
#pragma mark offlineDelegate
- (void)downloadWithArray:(NSMutableArray *)offlineArray{

    //批量请求
   self.batchRequest = [ZBRequestManager requestBatchWithConfig:^(ZBBatchRequest *batchRequest){
        for (HomeModel *model in offlineArray) {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[@"path"] = @"SettingViewController";
            parameters[@"author"] =model.wid;
            parameters[@"iap"] = @"0";
            parameters[@"limit"] =@"50";
            parameters[@"offset"] = @"0";
            ZBURLRequest *request=[[ZBURLRequest alloc]init];
            //request.URLString=[NSString stringWithFormat:@"%@%@",server_URL,details_URL] ;
            request.URLString=details_URL;
            request.apiType=ZBRequestTypeRefreshAndCache;//重新请求 并覆盖原来缓存文件
            request.parameters=parameters;
            request.filtrationCacheKey=@[@"path"];
            [batchRequest.requestArray addObject:request];
        }
    }  success:^(id responseObject,ZBURLRequest *request){
            NSLog(@"添加了几个请求  就会走几遍");
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            
            NSArray *array=[dict objectForKey:@"videos"];
            for (NSDictionary *dic in array) {
                DetailsModel *model=[[DetailsModel alloc]init];
                model.thumb=[dic objectForKey:@"thumb"]; //找到图片的key
                [self.imageArray addObject:model];
                
                //使用SDWebImage 下载图片， YYWebImang等逻辑一样
               
                BOOL isKey=[[SDImageCache sharedImageCache]diskImageDataExistsWithKey:model.thumb];
                if (isKey) {
                    NSLog(@"已经下载了");
                } else{
                    [[SDWebImageManager sharedManager]loadImageWithURL:[NSURL URLWithString:model.thumb] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                        NSLog(@"%@",[self progressStrWithSize:(CGFloat)receivedSize/expectedSize]);
                        
                    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                        NSLog(@"单个图片完成");
                                               
                        [self.tableView reloadData];//耗性能  正式开发建议刷新单行
                                               
                        //让 下载的url与模型的最后一个比较，如果相同证明下载完毕。
                        NSString *imageURLStr = [imageURL absoluteString];
                        NSString *lastImage=[NSString stringWithFormat:@"%@",((DetailsModel *)[self.imageArray lastObject]).thumb];
                        if ([imageURLStr isEqualToString:lastImage]) {
                            NSLog(@"url相同下载完成");
                                                    
                        }
                                               
                        if (error) {
                            NSLog(@"图片下载失败");
                        }
                    }];
                }
                
            }
            
        }
        
    } failure:nil finished:nil];
}

- (void)cancelClick{
    [ZBRequestManager cancelBatchRequest:self.batchRequest];
    [[SDWebImageManager sharedManager] cancelAll];//取消图片下载
    [self.imageArray removeAllObjects];
}

//懒加载
- (UITableView *)tableView{
    
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.tableFooterView=[[UIView alloc]init];
        
    }
    
    return _tableView;
}

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
    }
    return _imageArray;
}

- (NSString *)progressStrWithSize:(CGFloat)size{

    NSString *progressStr = [NSString stringWithFormat:@"下载进度:%.1f",size* 100];
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
