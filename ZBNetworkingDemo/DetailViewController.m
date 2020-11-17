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
#import "DataManager.h"
@interface DetailViewController ()<UITableViewDataSource,UITableViewDelegate,ZBURLRequestDelegate>
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UIRefreshControl *refreshControl;
@property (nonatomic,assign)NSUInteger identifier;
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
    [ZBRequestManager cancelRequest:self.identifier];//取消本次请求

    [[SDWebImageManager sharedManager] cancelAll];//取消图片下载
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets=NO;
    [self.tableView addSubview:self.refreshControl];
    [self.view addSubview:self.tableView];
    
    [self getDetailDataWithApiType:ZBRequestTypeCache];
}
- (void)getDetailDataWithApiType:(ZBApiType)apiType{
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
    self.identifier=[ZBRequestManager requestWithConfig:^(ZBURLRequest * _Nullable request) {
        request.url=details_URL;
        request.parameters=parameters;
        request.apiType=apiType;
    } target:self];
    /*
    self.identifier=[ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
       request.url=details_URL;
       request.parameters=parameters;
       request.apiType=apiType;
    }  success:^(id responseObject,ZBURLRequest * request){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            //如果是刷新的数据
            if (request.apiType==ZBRequestTypeRefreshAndCache) {
                [self.dataArray removeAllObjects];
                          
            }
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            NSArray *array=[dataDict objectForKey:@"videos"];
            for (NSDictionary *dict in array) {
                DetailsModel *model=[[DetailsModel alloc]initWithDict:dict];
                [self.dataArray addObject:model];
            }
            [self.tableView reloadData];
             [self.refreshControl endRefreshing];    //结束刷新
            if (request.isCache==YES) {
                self.title=@"使用了缓存";
                NSLog(@"filePath:%@",request.filePath);
            }else{
                self.title=@"重新请求";
            }
        }
    
    } failure:^(NSError *error) {
         [self.refreshControl endRefreshing];    //结束刷新
    }];
     */
}
#pragma mark - ZBURLRequestDelegate
- (void)request:(ZBURLRequest *)request successForResponseObject:(id)responseObject{
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        //如果是刷新的数据
        if (request.apiType==ZBRequestTypeRefreshAndCache) {
            [self.dataArray removeAllObjects];
                      
        }
        NSDictionary *dataDict = (NSDictionary *)responseObject;
        NSArray *array=[dataDict objectForKey:@"videos"];
        for (NSDictionary *dict in array) {
            DetailsModel *model=[[DetailsModel alloc]initWithDict:dict];
            [self.dataArray addObject:model];
        }
        [self.tableView reloadData];
         [self.refreshControl endRefreshing];    //结束刷新
        if (request.isCache==YES) {
            self.title=@"使用了缓存";
            NSLog(@"filePath:%@",request.filePath);
        }else{
            self.title=@"重新请求";
        }
    }
}
- (void)request:(ZBURLRequest *)request failedForError:(NSError *)error{
    NSLog(@"请求失败");
}
- (void)request:(ZBURLRequest *)request forProgress:(NSProgress *)progress{
    NSLog(@"onProgress: %.f", 100.f * progress.completedUnitCount/progress.totalUnitCount);
}
- (void)request:(ZBURLRequest *)request finishedForResponseObject:(id)responseObject forError:(NSError *)error{
    NSLog(@"url:%@ code:%ld",request.url,error.code);
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
#pragma mark - refresh
- (UIRefreshControl *)refreshControl{
    if (!_refreshControl) {
        
        //下拉刷新
        _refreshControl = [[UIRefreshControl alloc] init];
        //标题
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新..."];
        //事件
        [_refreshControl addTarget:self action:@selector(refreshDown) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (void)refreshDown{
    //开始刷新
    [self.refreshControl beginRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        /**
            *  下拉刷新是不读缓存的 要添加 apiType 类型 ZBRequestTypeRefreshAndCache  每次就会重新请求url
            *  请求下来的缓存会覆盖原有的缓存文件
            */
           [self getDetailDataWithApiType:ZBRequestTypeRefreshAndCache];
           
           self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新..."];
           
           /**
            * 上拉加载 要添加 apiType 类型 ZBRequestTypeRefreshMore(重新请求)
            */
    });
}
- (void)viewDidLayoutSubviews{
    [self.refreshControl.superview sendSubviewToBack:self.refreshControl];
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
