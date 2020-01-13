//
//  DetailViewController.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/8/24.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailsModel.h"
#import "ZBNetworking.h"
#import <UIImageView+WebCache.h>
@interface DetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic, strong) NSURLSessionTask *currentTask;

@end

@implementation DetailViewController
- (void)dealloc{
  NSLog(@"%s",__func__);
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    /**
       如果请求未完成，就退出，可以取消本次请求，节省用户流量，节约开销。已请求成功和读缓存，不会取消。
     */
    [self.currentTask cancel];//取消本次请求
    
    [[SDWebImageManager sharedManager] cancelAll];//取消图片下载
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    [self.view addSubview:self.tableView];
    /**
     *  如果页面不想使用缓存 要添加 apiType 类型
     *   ZBRequestTypeRefresh  每次就会重新请求url 不存储缓存
     *   ZBRequestTypeRefreshAndCache 每次就会重新请求url 存储，更新缓存
     */
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"author"] =self.wid;
    parameters[@"iap"] = @"0";
    parameters[@"limit"] =@"50";
    parameters[@"offset"] = @"0";
    parameters[@"path"] = @"DetailViewController";
   self.currentTask=[ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
         //request.URLString=[NSString stringWithFormat:@"%@%@",server_URL,details_URL] ;
       request.URLString=details_URL;
       request.parameters=parameters;
       request.apiType=ZBRequestTypeCache;
       request.filtrationCacheKey=@[@"path"];
    }  success:^(id responseObject,ZBURLRequest *request){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            NSArray *array=[dataDict objectForKey:@"videos"];
            for (NSDictionary *dict in array) {
                DetailsModel *model=[[DetailsModel alloc]initWithDict:dict];
                [self.dataArray addObject:model];
            }
            [self.tableView reloadData];
            if (request.isCache==YES) {
                self.title=@"使用了缓存";
            }else{
                self.title=@"重新请求";
            }
        }
    
    } failure:^(NSError *error){
        if (error.code==NSURLErrorCancelled){
             NSLog(@"请求取消❌------------------");
        }else if (error.code==NSURLErrorTimedOut){
            [self alertTitle:@"请求超时" andMessage:@""];
        }else{
            [self alertTitle:@"请求失败" andMessage:@""];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *iden=@"iden";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:iden];
    
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    DetailsModel *model=[self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text=model.title;
    
    cell.detailTextLabel.text=[NSString stringWithFormat:@"发布时间:%@",model.date];
    //NSLog(@"model.thumb:%@",model.thumb);

    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:[UIImage imageNamed:@"h1.jpg"]];

    return cell;
}
//懒加载
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
    }
    return _tableView;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
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
