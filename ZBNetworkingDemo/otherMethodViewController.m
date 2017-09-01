//
//  otherMethodViewController.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/18.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import "otherMethodViewController.h"
#import "ZBNetworking.h"
NSString *const url =@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4";

@interface otherMethodViewController ()
@property (nonatomic,strong)ZBBatchRequest *batchRequest;
@end

@implementation otherMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"post/Upload/DownLoad";
    
    NSArray *titleArray=[NSArray arrayWithObjects:@"postRequest",@"UploadRequest",@"downLoadRequest",@"downLoadBatchRequest",@"取消请求", nil];
    
    for (int i=0; i<titleArray.count; i++) {
        
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        //  [btn setTitle:array[i]  forState:UIControlStateNormal];
        [button setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
        button.tag = 1000+i;
        button.frame=CGRectMake(50, 100+i*60, 200, 30);
        button.backgroundColor=[UIColor blackColor];
        button.titleLabel.textAlignment=NSTextAlignmentCenter;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}
- (void)btnClicked:(UIButton *)sender{
    switch (sender.tag) {
        case 1000:
            [self postRequest];
            break;
        case 1001:
            [self UploadRequest];
            break;
        case 1002:
            [self downLoadRequest];
            break;
        case 1003:
            [self downLoadBatchRequest];
            break;
        case 1004:
            [self cancelRequest];
            break;
            
        default:
            break;
    }
}

- (void)postRequest{
    /*
     //POST请求 是改变服务器状态 一般是没有缓存的。也有个列 所有数据都是post的，所以request.apiType也可以用，如：request.apiType=ZBRequestTypeCache
        默认缓存路径/Library/Caches/ZBKit/AppCache
     */

    [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        request.urlString=@"";
        request.methodType=ZBMethodTypePOST;//默认为GET
        //request.apiType=ZBRequestTypeRefresh;//默认为Refresh
        request.timeoutInterval=10;
        request.parameters=@{@"1": @"one", @"2": @"two"};
        [request setValue:@"1234567890" forHeaderField:@"apitype"];
    }  success:^(id responseObject,apiType type){
        NSLog(@"返回内容: %@", responseObject);
        
    } failed:^(NSError *error){
        NSLog(@"error: %@", error);
    }];
}
- (void)UploadRequest{
  
    UIImage *image = [UIImage imageNamed:@"testImage"];
    NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
 
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/testImage.png"];
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    
    [ZBRequestManager requestWithConfig:^(ZBURLRequest * request) {
        request.urlString=@"";
        request.methodType=ZBMethodTypeUpload;
    
        [request addFormDataWithName:@"image[]" fileData:fileData];
        
        [request addFormDataWithName:@"image[]" fileURL:fileURL];
        
    } progress:^(NSProgress * _Nullable progress) {
        NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
        
    } success:^(id  responseObject, apiType type) {
        NSLog(@"responseObject: %@", responseObject);
    } failed:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    }];

}

- (void)downLoadRequest{
    
    [ZBRequestManager requestWithConfig:^(ZBURLRequest * request) {
        request.urlString=url;
        request.methodType=ZBMethodTypeDownLoad;
        request.downloadSavePath = [[ZBCacheManager sharedInstance] tmpPath];
    } progress:^(NSProgress * _Nullable progress) {
        NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
        
    } success:^(id  responseObject, apiType type) {
        NSLog(@"此时会返回存储路径: %@", responseObject);
        
        [self downLoadPathSize:[[ZBCacheManager sharedInstance] tmpPath]];//返回下载路径的大小
        
        sleep(2);
        //删除下载的文件
        [[ZBCacheManager sharedInstance]clearDiskWithpath:[[ZBCacheManager sharedInstance] tmpPath]completion:^{
            NSLog(@"删除下载的文件");
            [self downLoadPathSize:[[ZBCacheManager sharedInstance] tmpPath]];
        }];
    
        
    } failed:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    }];
 

}

- (void)downLoadBatchRequest{
 

    self.batchRequest=[ZBRequestManager batchRequest:^(ZBBatchRequest * batchRequest) {
    
        /*
         for (int i=0; i<=10; i++) {
            ZBURLRequest *request=[[ZBURLRequest alloc]init];
            request.urlString=url;
            request.methodType=ZBMethodTypeDownLoad;
            request.downloadSavePath = [[ZBCacheManager sharedInstance] tmpPath];
            [batchRequest.urlArray addObject:request];
         }
         */
        ZBURLRequest *request1=[[ZBURLRequest alloc]init];
        request1.urlString=url;
        request1.methodType=ZBMethodTypeDownLoad;
        request1.downloadSavePath = [[ZBCacheManager sharedInstance] tmpPath];
        [batchRequest.urlArray addObject:request1];
        
        ZBURLRequest *request2=[[ZBURLRequest alloc]init];
        request2.urlString=url;
        request2.methodType=ZBMethodTypeDownLoad;
        request2.downloadSavePath = [[ZBCacheManager sharedInstance] documentPath];
        [batchRequest.urlArray addObject:request2];
    } progress:^(NSProgress * _Nullable progress) {
         NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
    } success:^(id  _Nullable responseObject, apiType type) {
        NSLog(@"此时会返回存储路径: %@", responseObject);
        
        [self downLoadPathSize:[[ZBCacheManager sharedInstance] tmpPath]];//返回下载路径的大小
        [self downLoadPathSize:[[ZBCacheManager sharedInstance] documentPath]];//返回下载路径的大小
        sleep(2);
        
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
    } failed:^(NSError * _Nullable error) {
        
    }];

}

- (void)cancelRequest{
    
    [ZBRequestManager cancelRequest:url completion:^(NSString * urlString) {
        NSLog(@"取消下载请求%@",urlString);
    }];
    [self.batchRequest cancelbatchRequest:^{
        NSLog(@"取消全部请求(已经请求成功不会取消)");
    }];
}

- (void)downLoadPathSize:(NSString *)path{
    CGFloat downLoadPathSize=[[ZBCacheManager sharedInstance]getFileSizeWithpath:path];
    downLoadPathSize=downLoadPathSize/1000.0/1000.0;
    NSLog(@"downLoadPathSize: %.2fM", downLoadPathSize);
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
