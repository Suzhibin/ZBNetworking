//
//  otherMethodViewController.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 2017/8/18.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import "otherMethodViewController.h"
#import "ZBNetworking.h"
@interface otherMethodViewController ()

@end

@implementation otherMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"post/Upload/DownLoad";
    
   //[self postRequest];
   //[self UploadRequest];
    [self DownLoadRequest];
   
}
- (void)postRequest{
    /*
     //POST请求 是改变服务器状态 一般是没有缓存的。也有个列 所有数据都是post的，所以request.apiType也可以用，如：request.apiType=ZBRequestTypeCache
        默认缓存路径/Library/Caches/ZBKit/AppCache
     */

    [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        request.urlString=@"";
        request.methodType=ZBMethodTypePOST;//默认为GET
        request.apiType=ZBRequestTypeRefresh;//默认为Refresh
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
    
    [ZBRequestManager requestWithConfig:^(ZBURLRequest * _Nullable request) {
        request.urlString=@"";
        request.methodType=ZBMethodTypeUpload;
    
        [request addFormDataWithName:@"" fileData:fileData];
        
        [request addFormDataWithName:@"" fileURL:fileURL];
        
    } progress:^(NSProgress * _Nullable progress) {
        NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
        
    } success:^(id  responseObject, apiType type) {
        NSLog(@"responseObject: %@", responseObject);
    } failed:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    }];

}

- (void)DownLoadRequest{
    
    [ZBRequestManager requestWithConfig:^(ZBURLRequest * _Nullable request) {
        request.urlString=@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4";
        request.methodType=ZBMethodTypeDownLoad;
        request.downloadSavePath = [[ZBCacheManager sharedInstance] tmpPath];
    } progress:^(NSProgress * _Nullable progress) {
        NSLog(@"onProgress: %.2f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
        
    } success:^(id  responseObject, apiType type) {
        NSLog(@"此时会返回存储路径: %@", responseObject);
    } failed:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    }];
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
