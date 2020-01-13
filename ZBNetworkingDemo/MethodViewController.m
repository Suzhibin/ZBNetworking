//
//  MethodViewController.m
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2018/10/12.
//  Copyright © 2018年 Suzhibin. All rights reserved.
//

#import "MethodViewController.h"
#import "ZBNetworking.h"
#define urlStr @"http://api.dotaly.com/lol/api/v1/shipin/latest"
@interface MethodViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic, copy) NSString *AccessToken;
@property (nonatomic, copy) NSString *path;
@end

@implementation MethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    self.dataArray=[NSArray arrayWithObjects:@"GET / POST / PUT / PATCH / DELETE / 取消请求",@"上传文件",@"下载文件",@"批量请求或批量下载文件",@"多次请求,保留第一次请求(场景:发帖,评论等)",@"多次请求,保留最后一次请求(场景:搜索)",@"parameters过滤动态参数", @"取消所有请求",nil];
     self.path = [[ZBCacheManager sharedInstance] tmpPath];
    NSLog(@"path:%@",self.path);
   
    
    
}

//多类型请求方法
- (void)requestMethod{
    /*
     GET/POST/PUT/PATCH/DELETE 请求 都有缓存功能
     POST请求 是给服务器传参的 改变服务器状态 一般是没有缓存的。也有特例 所有列表数据请求都是post的，所以request.apiType也可以用，如：request.apiType=ZBRequestTypeCache
     支持内存缓存 和 沙盒缓存
     默认缓存路径/Library/Caches/ZBKit/AppCache
     */
    
    NSURLSessionTask *task= [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        request.URLString=@"https://URL";
        request.methodType=ZBMethodTypePOST;//ZBMethodTypePUT//ZBMethodTypePATCH//ZBMethodTypeDELETE//ZBMethodTypeGET 默认为GET
        request.requestSerializer=ZBJSONRequestSerializer;//默认ZBJSONRequestSerializer 上传参数默认为json 格式
        request.responseSerializer=ZBJSONResponseSerializer;//默认ZBJSONResponseSerializer  返回的数据默认为json格式
        request.apiType=ZBRequestTypeCache;//默认为ZBRequestTypeRefresh
        request.timeoutInterval=10;//默认30
        request.parameters=@{@"1": @"one", @"2": @"two"};
        //   [request setValue:@"1234567890" forHeaderField:@"apitype"];
    }  success:^(id responseObject,ZBURLRequest *request){
        
        if (request.isCache) {
            NSLog(@"使用了缓存");
        }else{
            NSLog(@"重新请求");
        }
    } failure:^(NSError *error){
        NSLog(@"error: %@", error);
    }];
    
    
    sleep(5);
          
    [task cancel];//取消请求  （已请求完和读缓存 无法取消）
}

//上传文件
- (void)UploadRequest{
    
   // UIImage *image = [UIImage imageNamed:@"testImage"];
   // NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
    
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/testImage.png"];
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    
    [ZBRequestManager requestWithConfig:^(ZBURLRequest * request) {
        request.URLString=@"https://URL";
        request.methodType=ZBMethodTypeUpload;
        
       // [request addFormDataWithName:@"image[]" fileData:fileData];
        
        [request addFormDataWithName:@"image[]" fileURL:fileURL];
        
    } progress:^(NSProgress * _Nullable progress) {
        NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
        
    } success:^(id  responseObject,ZBURLRequest *request) {
        NSLog(@"responseObject: %@", responseObject);
    } failure:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    }];
}
//下载文件
- (void)downLoadRequest{
    
    [ZBRequestManager requestWithConfig:^(ZBURLRequest * request) {
        request.URLString=@"https://URL";
        request.methodType=ZBMethodTypeDownLoad;
        request.downloadSavePath = [[ZBCacheManager sharedInstance] tmpPath];
    } progress:^(NSProgress * _Nullable progress) {
        NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
        
    } success:^(id  responseObject,ZBURLRequest *request) {
        NSLog(@"ZBMethodTypeDownLoad 此时会返回存储路径文件: %@", responseObject);
        
        [self downLoadPathSize:[[ZBCacheManager sharedInstance] tmpPath]];//返回下载路径的大小
        
        sleep(3);
        //删除下载的文件
        [[ZBCacheManager sharedInstance]clearDiskWithpath:[[ZBCacheManager sharedInstance] tmpPath]completion:^{
            NSLog(@"删除下载的文件");
            [self downLoadPathSize:[[ZBCacheManager sharedInstance] tmpPath]];
        }];
        
        
    } failure:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    }];
}
//批量下载文件或批量请求
- (void)downLoadBatchRequest{
    
    [ZBRequestManager sendBatchRequest:^(ZBBatchRequest * batchRequest) {
         for (int i=0; i<=10; i++) {
             ZBURLRequest *request=[[ZBURLRequest alloc]init];
             request.URLString=@"https://URL";
             request.methodType=ZBMethodTypeDownLoad;
             request.downloadSavePath = [[ZBCacheManager sharedInstance] tmpPath];
             [batchRequest.requestArray addObject:request];
         }
         /*
        ZBURLRequest *request1=[[ZBURLRequest alloc]init];
        request1.URLString=@"";
        request1.methodType=ZBMethodTypeDownLoad;
        request1.downloadSavePath = [[ZBCacheManager sharedInstance] tmpPath];
        [batchRequest.urlArray addObject:request1];
        
        ZBURLRequest *request2=[[ZBURLRequest alloc]init];
        request2.URLString=@"";
        request2.methodType=ZBMethodTypeDownLoad;
        request2.downloadSavePath = [[ZBCacheManager sharedInstance] documentPath];
        [batchRequest.urlArray addObject:request2];
          */
    } progress:^(NSProgress * _Nullable progress) {
        NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
    } success:^(id  _Nullable responseObject, ZBURLRequest *request) {
        NSLog(@"ZBMethodTypeDownLoad 此时会返回存储路径文件: %@", responseObject);
        
        [self downLoadPathSize:[[ZBCacheManager sharedInstance] tmpPath]];//返回下载路径的大小
        [self downLoadPathSize:[[ZBCacheManager sharedInstance] documentPath]];//返回下载路径的大小
        sleep(5);
        //删除下载的文件
        [[ZBCacheManager sharedInstance]clearDiskWithpath:[[ZBCacheManager sharedInstance] tmpPath]completion:^{
            NSLog(@"删除下载的文件");
            [self downLoadPathSize:[[ZBCacheManager sharedInstance] tmpPath]];
        }];
        //删除下载的文件
        [[ZBCacheManager sharedInstance]clearDiskWithpath:[[ZBCacheManager sharedInstance] documentPath]completion:^{
            NSLog(@"删除下载的文件");
            [self downLoadPathSize:[[ZBCacheManager sharedInstance] documentPath]];
        }];
    } failure:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    }finished:^(NSArray<id> * _Nullable responseObjects) {
        NSLog(@"请求完毕");
    }];
    
}
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
        [ZBRequestManager requestWithConfig:^(ZBURLRequest *request) {
            request.URLString=urlStr;
            request.parameters=parameters;
            request.methodType=ZBMethodTypeGET;//默认get
            request.apiType=ZBRequestTypeRefresh;
            request.keepType=keepType; //
        } success:^(id responseObject,ZBURLRequest *request) {
            
            NSLog(@"第 %d 次请求成功☑️------------------", i);
            
        } failure:^(NSError * _Nullable error) {
           
            if (error.code==NSURLErrorCancelled){
                 NSLog(@"第 %d 次请求取消❌------------------", i);
            }else if (error.code==NSURLErrorTimedOut) {
                [self alertTitle:@"请求超时" andMessage:@""];
            }else{
                [self alertTitle:@"请求失败" andMessage:@""];
            }
        }];
    }
}

//过滤掉parameters 缓存key里的 变动参数
- (void)parametersfiltrationCacheKey{
    //POST等 使用了parameters 的请求 缓存key会是URLString+parameters，parameters里有是时间戳或者其他动态参数,key一直变动 无法拿到缓存。所以定义一个parametersfiltrationCacheKey 过滤掉parameters 缓存key里的 变动参数比如 时间戳
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f",timeInterval];
    
    [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        request.URLString=@"https://URL";
        request.methodType=ZBMethodTypePOST;//默认为GET
        request.apiType=ZBRequestTypeCache;//默认为ZBRequestTypeRefresh
        request.parameters=@{@"1": @"one", @"2": @"two", @"time":timeString};
        request.filtrationCacheKey=@[@"time"];//过滤掉parameters 缓存key里变动参数比如 时间戳
    }success:nil failure:nil];
}

//取消所有请求
- (void)cancelAllRequest{
    [ZBRequestManager cancelAllRequest];
}
- (void)downLoadPathSize:(NSString *)path{
    CGFloat downLoadPathSize=[[ZBCacheManager sharedInstance]getFileSizeWithpath:path];
    downLoadPathSize=downLoadPathSize/1000.0/1000.0;
    NSLog(@"downLoadPathSize: %.2fM", downLoadPathSize);
}

#pragma mark tableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self requestMethod];//多类型请求方法
            break;
        case 1:
            [self UploadRequest];//上传文件
            break;
        case 2:
            [self downLoadRequest];//下载文件
            break;
        case 3:
            [self downLoadBatchRequest];//批量下载文件或批量请求
            break;
        case 4:
            [self keepResultType:ZBResponseKeepFirst];//只使用第一次请求结果
            break;
        case 5:
            [self keepResultType:ZBResponseKeepLast];//只使用最后一次请求结果
            break;
        case 6:
            [self parametersfiltrationCacheKey];//过滤掉parameters 缓存key里的 变动参数
            break;
        case 7:
            [self cancelAllRequest];//取消所有请求
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
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
    }
    NSString *title=[self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text=title;
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
