//
//  MethodViewController.m
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2018/10/12.
//  Copyright © 2018年 Suzhibin. All rights reserved.
//

#import "MethodViewController.h"
#import "ZBNetworking.h"
#import "PlayerViewController.h"
#define urlStr @"http://api.dotaly.com/lol/api/v1/shipin/latest"
@interface MethodViewController ()<UITableViewDelegate,UITableViewDataSource,ZBURLRequestDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic, copy) NSString *AccessToken;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) UIButton *controlButton;
@property (nonatomic, assign)BOOL isDownload;
@property (nonatomic, assign)NSUInteger identifier;
@end

@implementation MethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    self.dataArray=[NSArray arrayWithObjects:@"GET / POST / PUT / PATCH / DELETE ",@"取消请求",@"代理方法",@"上传文件",@"下载文件（支持断点）",@"批量请求",@"多次请求,保留第一次请求(场景:发帖,评论等)",@"多次请求,保留最后一次请求(场景:搜索)",@"parameters过滤动态参数",nil];
     self.path = [[ZBCacheManager sharedInstance] tmpPath];
    NSLog(@"path:%@",self.path);
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (weakSelf.isDownload==YES) {
            NSLog(@"进入后台 暂停下载");
            [weakSelf downloadWithState:ZBDownloadStateStop];
            weakSelf.controlButton.selected=YES;
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (weakSelf.isDownload==YES) {
            NSLog(@"进入前台 恢复下载");
            [weakSelf downloadWithState:ZBDownloadStateStart];
            weakSelf.controlButton.selected=NO;
        }
    }];
}

#pragma mark - 多类型请求方法
- (void)requestMethod{
    /*
     GET/POST/PUT/PATCH/DELETE 请求 都有缓存功能
     POST请求 是给服务器传参的 改变服务器状态 一般是没有缓存的。也有特例 所有列表数据请求都是post的，所以request.apiType也可以用，如：request.apiType=ZBRequestTypeCache
     支持内存缓存 和 沙盒缓存
     默认缓存路径/Library/Caches/ZBKit/AppCache
     */
    
    self.identifier= [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        request.url=@"https://URL";
        request.methodType=ZBMethodTypePOST;//ZBMethodTypePUT//ZBMethodTypePATCH//ZBMethodTypeDELETE//ZBMethodTypeGET 默认为GET
        request.requestSerializer=ZBJSONRequestSerializer;//默认ZBJSONRequestSerializer 上传参数默认为json 格式
        request.responseSerializer=ZBJSONResponseSerializer;//默认ZBJSONResponseSerializer  返回的数据默认为json格式
        request.apiType=ZBRequestTypeCache;//默认为ZBRequestTypeRefresh
        // request.isBaseParameters=NO;//本次 请求不使用 公共参数
        request.timeoutInterval=10;//默认30
        request.parameters=@{@"1": @"one", @"2": @"two"};
        request.headers=@{@"headers": @"headers"};
        request.userInfo=@{@"tag":@"111"};//用于标示 请求信息
    }  success:^(id responseObject,ZBURLRequest *request){
        
        if (request.isCache) {
            NSLog(@"使用了缓存");
        }else{
            NSLog(@"重新请求");
        }
    } failure:^(NSError *error){
        NSLog(@"error: %@", error);
    }];

}
- (void)cancelRequest{
    [ZBRequestManager cancelRequest:self.identifier];//取消请求  （已请求完和读缓存 无法取消）
}
#pragma mark - 代理请求
- (void)delegateRequest{
    [ZBRequestManager requestWithConfig:^(ZBURLRequest * _Nullable request) {
        request.url=@"https://URL";
    } target:self];
}
#pragma mark - ZBURLRequestDelegate
- (void)request:(ZBURLRequest *)request successForResponseObject:(id)responseObject{
    if (request.isCache) {
        NSLog(@"使用了缓存");
    }else{
        NSLog(@"重新请求");
    }
}
- (void)request:(ZBURLRequest *)request failedForError:(NSError *)error{
    NSLog(@"请求失败");
}
- (void)request:(ZBURLRequest *)request forProgress:(NSProgress *)progress{
    NSLog(@"onProgress: %.f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
}
- (void)request:(ZBURLRequest *)request finishedForResponseObject:(id)responseObject forError:(NSError *)error{
    NSLog(@"code:%ld",error.code);
    NSLog(@"url:%@",request.url);
}

#pragma mark - 上传文件方法
- (void)UploadRequest{
    
   // UIImage *image = [UIImage imageNamed:@"testImage"];
   // NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
    
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/testImage.png"];
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    
    [ZBRequestManager requestWithConfig:^(ZBURLRequest * request) {
        request.url=@"https://URL";
        request.methodType=ZBMethodTypeUpload;
        
       // [request addFormDataWithName:@"image[]" fileData:fileData];
        
        [request addFormDataWithName:@"image[]" fileURL:fileURL];
        
    } progress:^(NSProgress * _Nullable progress) {
        NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
        
    } success:^(id  responseObject,ZBURLRequest * request) {
        NSLog(@"responseObject: %@", responseObject);
    } failure:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    }];
}

#pragma mark - 下载文件方法
- (void)downloadWithState:(ZBDownloadState)state{
  //  会默认创建下载路径/Library/Caches/ZBKit/AppDownload
   self.identifier=[ZBRequestManager requestWithConfig:^(ZBURLRequest * request) {
        request.url=@"https://fcvideo.cdn.bcebos.com/smart/f103c4fc97d2b2e63b15d2d5999d6477.mp4";
        request.methodType=ZBMethodTypeDownLoad;
        request.downloadState=state;//下载状态
        request.userInfo=@{@"tag":@"10086"};
    } progress:^(NSProgress * _Nullable progress) {
        NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
    } success:^(id  responseObject,ZBURLRequest * request) {
        NSLog(@"ZBMethodTypeDownLoad 此时会返回存储路径文件: %@", responseObject);
        [self downLoadPathSize:[ZBRequestManager AppDownloadPath]];//返回下载路径的大小
        self.controlButton.selected=NO;
        
        [self alertTitle:@"下载完毕" andMessage:@"" completed:^{
            
            /*
            //在任何地方拿到下载文件
             NSString *file=[ZBRequestManager getDownloadFileForKey:request.url];
             */
            //播放下载的mp4
            PlayerViewController *playerVC=[[PlayerViewController alloc]init];
            NSURL *videoURL = [NSURL fileURLWithPath:responseObject];
            //NSURL *videoURL = [NSURL fileURLWithPath:file];
            playerVC.videoUrl=videoURL.absoluteString;
            playerVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:playerVC animated:YES];
        }];
       
        /*
        sleep(5);
        //删除下载的文件
         [[ZBCacheManager sharedInstance]clearDiskWithPath:[ZBRequestManager AppDownloadPath] completion:^{
             NSLog(@"删除下载的文件");
             [self downLoadPathSize:[ZBRequestManager AppDownloadPath]];
         }];
        */
        
    } failure:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    }];
}

#pragma mark - 批量请求
- (void)downLoadBatchRequest{
    NSArray *array=@[@"https://fcvideo.cdn.bcebos.com/smart/f103c4fc97d2b2e63b15d2d5999d6477.mp4",@"http://m4.pc6.com/cjh3/LogMeInInstaller7009.zip"];

    ZBBatchRequest *batchRequest=[ZBRequestManager requestBatchWithConfig:^(ZBBatchRequest * batchRequest) {
        [array enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZBURLRequest *request=[[ZBURLRequest alloc]init];
            request.url= obj;
            request.methodType=ZBMethodTypeDownLoad;
            [batchRequest.requestArray addObject:request];
        }];

         /*
        ZBURLRequest *request1=[[ZBURLRequest alloc]init];
        request1.url=@"";
        request1.methodType=ZBMethodTypeDownLoad;
        [batchRequest.urlArray addObject:request1];
        
        ZBURLRequest *request2=[[ZBURLRequest alloc]init];
        request2.url=@"";
        request2.methodType=ZBMethodTypeDownLoad;
        [batchRequest.urlArray addObject:request2];
          */
    } progress:^(NSProgress * _Nullable progress) {
        NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
    } success:^(id  _Nullable responseObject, ZBURLRequest *request) {
        NSLog(@"ZBMethodTypeDownLoad 此时会返回存储路径文件: %@", responseObject);
    } failure:^(NSError * _Nullable error) {
        if (error.code==NSURLErrorCancelled){
            NSLog(@"请求取消❌------------------");
        }else{
              NSLog(@"error: %@", error);
        }
    }finished:^(NSArray * _Nullable responseObjects, NSArray<NSError *> * _Nullable errors, NSArray<ZBURLRequest *> * _Nullable requests) {
  
        [requests enumerateObjectsUsingBlock:^(ZBURLRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"批量完成事件 url:%@",obj.url);
        }];
        // NSLog(@"ZBMethodTypeDownLoad 此时会返回存储路径文件: %@", responseObject);
                
        [self downLoadPathSize:[ZBRequestManager AppDownloadPath]];//返回下载路径的大小

//        sleep(5);
//        //删除下载的文件
//        [[ZBCacheManager sharedInstance]clearDiskWithpath:[ZBRequestManager AppDownloadPath] completion:^{
//            NSLog(@"删除下载的文件");
//            [self downLoadPathSize:[ZBRequestManager AppDownloadPath]];
//        }];
    }];
    /**
     批量请求取消
     */
   // [ZBRequestManager cancelBatchRequest:batchRequest];
    
}

#pragma mark - 保留第一个 或 最后一次请求
/**
 多次相同的请求，保留第一次或最后一次请求结果 只在请求时有用  读取缓存无效果 (ZBRequestTypeRefresh或ZBRequestTypeRefreshMore //request.keepType 设置才有效 ）
 */
- (void)keepResultType:(ZBResponseKeepType)keepType{
    /**
     注意⚠️ 请求使用keep功能 要使用parameters。不要把参数拼接在url后，有可能会因为参数变动 导致url不一样无法取消请求
     */
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"path"] = @"MethodViewController";
    parameters[@"author"] =@"xiaomo";
    parameters[@"iap"] = @"0";
    parameters[@"limit"] =@"50";
    parameters[@"offset"] = @"0";
    for (int i = 0; i < 5; i++) {
        NSUInteger identifier=[ZBRequestManager requestWithConfig:^(ZBURLRequest *request) {
            request.url=urlStr;
            request.parameters=parameters;
            request.methodType=ZBMethodTypeGET;//默认get
            request.apiType=ZBRequestTypeRefresh;
            request.keepType=keepType; //
           // request.userInfo=@{@"tag":@"7777"};
        } success:^(id responseObject,ZBURLRequest *request) {
            
            NSLog(@"第 %d 次请求成功☑️------------------", i);
            
        } failure:^(NSError * _Nullable error) {
           
            if (error.code==NSURLErrorCancelled){
                 NSLog(@"第 %d 次请求取消❌------------------", i);
            }else if (error.code==NSURLErrorTimedOut) {
                [self alertTitle:@"请求超时" andMessage:@"" completed:nil];
            }else{
                [self alertTitle:@"请求失败" andMessage:@""completed:nil];
            }
        }];
        NSLog(@"identifier:%ld",identifier);
    }
}

#pragma mark - 过滤缓存key
//过滤掉parameters 缓存key里的 变动参数
- (void)parametersfiltrationCacheKey{
    //POST等 使用了parameters 的请求 缓存key会是url+parameters，parameters里有是时间戳或者其他动态参数,key一直变动 无法拿到缓存。所以定义一个parametersfiltrationCacheKey 过滤掉parameters 缓存key里的 变动参数比如 时间戳
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f",timeInterval];
    
    [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        request.url=@"https://URL";
        request.methodType=ZBMethodTypePOST;//默认为GET
        request.apiType=ZBRequestTypeCache;//默认为ZBRequestTypeRefresh
        request.parameters=@{@"1": @"one", @"2": @"two", @"time":timeString};
        request.filtrationCacheKey=@[@"time"];//过滤掉parameters 缓存key里变动参数比如 时间戳
    }success:nil failure:nil];
}

- (void)downLoadPathSize:(NSString *)path{
    CGFloat downLoadPathSize=[[ZBCacheManager sharedInstance]getFileSizeWithPath:path];
    downLoadPathSize=downLoadPathSize/1000.0/1000.0;
    NSLog(@"downLoadPathSize: %.2fM", downLoadPathSize);
}
#pragma mark - Action
- (void)controlDidTap:(UIButton *)sender {
    sender.selected =!sender.selected;
    self.isDownload=YES;
    if (sender.isSelected==YES) {
        [self downloadWithState:ZBDownloadStateStart];
    }else{
        [self downloadWithState:ZBDownloadStateStop];
    }
}
#pragma mark tableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.isDownload=NO;
    switch (indexPath.row) {
        case 0:
            [self requestMethod];//多类型请求方法
            break;
        case 1:
            [self cancelRequest];//代理请求方法
            break;
        case 2:
            [self delegateRequest];//代理请求方法
            break;
        case 3:
            [self UploadRequest];//上传文件
            break;
        case 4:
            //按钮事件
            break;
        case 5:
            [self downLoadBatchRequest];//批量下载文件或批量请求
            break;
        case 6:
            [self keepResultType:ZBResponseKeepFirst];//只使用第一次请求结果
            break;
        case 7:
            [self keepResultType:ZBResponseKeepLast];//只使用最后一次请求结果
            break;
        case 8:
            [self parametersfiltrationCacheKey];//过滤掉parameters 缓存key里的 变动参数
            break;
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *iden=@"iden2";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:iden];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:iden];
    }
    NSString *title=[self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text=title;
    if (indexPath.row==4) {
        UIButton *controlButton = [[UIButton alloc] init];
        [controlButton setTitle:@"开始" forState:UIControlStateNormal];
        [controlButton setTitle:@"暂停" forState:UIControlStateSelected];
        [controlButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        controlButton.frame=CGRectMake(cell.contentView.frame.size.width-44, 0, 44, 44);
        [controlButton addTarget:self action:@selector(controlDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:controlButton];
        self.controlButton=controlButton;
    }
    return cell;
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
