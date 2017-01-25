//
//  SecondViewController.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 16/12/20.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "SecondViewController.h"
#import "ZBNetworking.h"
#import "RootModel.h"
#import "DetailViewController.h"
#import "SettingViewController.h"
@interface SecondViewController ()<ZBURLSessionDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UIRefreshControl *refreshControl;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /**
     *  默认缓存路径/Library/Caches/ZBKit/AppCache
     *
     *  ZBAFNetworkManager(AFNetworking)与 ZBURLSessionManager(NSURLSession) 缓存策略都是ZBCacheManager来管理的 缓存文件是相通共用的   换句话说，俩个类的三种请求方法可以共存
     */  
    if (_functionType==AFNetworking) {
        //AFNetworking方法
        [self getAFNetworkWithApiType:ZBRequestTypeDefault];
 
    }else if (_functionType==sessionblock){
        //NSURLSessionBlock方法
        [self getSessionBlockWithApiType:ZBRequestTypeDefault];
 
    }else if(_functionType==sessiondelegate){
        //NSURLSessionDelegate方法
        //需要 ZBURLSessionDelegate 协议
        [[ZBURLSessionManager sharedManager]getRequestWithURL:list_URL target:self apiType:ZBRequestTypeDefault];
    }
    [self.tableView addSubview:self.refreshControl];
    [self.view addSubview:self.tableView];
    
    [self addItemWithTitle:@"设置" selector:@selector(btnClick) location:NO];

}
#pragma mark - AFNetworking
//apiType 是请求类型 在ZBURLRequest 里
- (void)getAFNetworkWithApiType:(apiType)requestType{
    
    [ZBNetworkManager requestWithConfig:^(ZBURLRequest *request){
        request.urlString=list_URL;
        request.methodType=ZBMethodTypeGET;//默认为GET
        request.apiType=requestType;//默认为default
        request.timeoutInterval=10;
       // request.parameters=@{@"1": @"one", @"2": @"two"};
       // [request setValue:@"1234567890" forHeaderField:@"apitype"];
    }  success:^(id responseObj,apiType type){
        NSLog(@"type:%zd",type);
        //如果是刷新的数据
        if (type==ZBRequestTypeRefresh) {
            [self.dataArray removeAllObjects];
            [_refreshControl endRefreshing];    //结束刷新
        }
        if (type==ZBRequestTypeLoadMore) {
            //上拉加载
        }
   
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
       // NSLog(@"ZBNetworkManagerdict:%@",dict);
        NSArray *array=[dict objectForKey:@"authors"];
        
        for (NSDictionary *dic in array) {
            RootModel *model=[[RootModel alloc]init];
            model.name=[dic objectForKey:@"name"];
            model.wid=[dic objectForKey:@"id"];
            model.detail=[dic objectForKey:@"detail"];
            [self.dataArray addObject:model];
        }
        [self.tableView reloadData];
        
    } failed:^(NSError *error){
        if (error.code==NSURLErrorCancelled)return;
        if (error.code==NSURLErrorTimedOut){
            [self alertTitle:@"请求超时" andMessage:@""];
        }else{
            [self alertTitle:@"请求失败" andMessage:@""];
        }
    }];
}
#pragma mark -sessionblock
//apiType 是请求类型 在ZBURLRequest 里
- (void)getSessionBlockWithApiType:(apiType)requestType{
    
    [[ZBURLSessionManager sharedManager]requestWithConfig:^(ZBURLRequest *request){
        request.urlString=list_URL;
        request.methodType=ZBMethodTypeGET;//默认为GET
        request.apiType=requestType;//默认为default
       
    } success:^(id responseObj,apiType type){
        NSLog(@"type:%zd",type);
        //如果是刷新的数据
        if (type==ZBRequestTypeRefresh) {
            [self.dataArray removeAllObjects];
            [_refreshControl endRefreshing];    //结束刷新
        }
        if (type==ZBRequestTypeLoadMore) {
            //上拉加载
        }

        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:nil];
        NSArray *array=[dict objectForKey:@"authors"];
        
        for (NSDictionary *dic in array) {
            RootModel *model=[[RootModel alloc]init];
            model.name=[dic objectForKey:@"name"];
            model.wid=[dic objectForKey:@"id"];
            model.detail=[dic objectForKey:@"detail"];
            [self.dataArray addObject:model];
        }
        [self.tableView reloadData];
    } failed:^(NSError *error){
        if (error.code==NSURLErrorCancelled)return;
        if (error.code==NSURLErrorTimedOut) {
            [self alertTitle:@"请求超时" andMessage:@""];
        }else{
            [self alertTitle:@"请求失败" andMessage:@""];
        }
    }];
    
}

#pragma mark - ZBURLSessionManager Delegate
- (void)urlRequestFinished:(ZBURLRequest *)request{
    NSLog(@"sessiondelegate 请求类型:%zd",request.apiType);
    //如果是刷新的数据
    if (request.apiType==ZBRequestTypeRefresh) {
        [self.dataArray removeAllObjects];
        [_refreshControl endRefreshing]; //结束刷新
    }
    if (request.apiType==ZBRequestTypeLoadMore) {
        //上拉加载
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.responseObj options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *array=[dict objectForKey:@"authors"];
    
    for (NSDictionary *dic in array) {
        RootModel *model=[[RootModel alloc]init];
        model.name=[dic objectForKey:@"name"];
        model.wid=[dic objectForKey:@"id"];
        model.detail=[dic objectForKey:@"detail"];
        [self.dataArray addObject:model];
    }
    [self.tableView reloadData];
}
- (void)urlRequestFailed:(ZBURLRequest *)request{
    //如果是下拉刷新的数据
    if (request.apiType==ZBRequestTypeRefresh) {
        [_refreshControl endRefreshing];  //结束刷新
    }
    if (request.apiType==ZBRequestTypeLoadMore) {
        //上拉加载
    }
    if (request.error.code==NSURLErrorCancelled)return;
    if (request.error.code==NSURLErrorTimedOut) {
        [self alertTitle:@"请求超时" andMessage:@""];
    }else{
        [self alertTitle:@"请求失败" andMessage:@""];
    }
}


#pragma mark - 刷新
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
    [_refreshControl beginRefreshing];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中"];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer) userInfo:nil repeats:NO];
}

- (void)timer{
    /**
     *  下拉刷新是不读缓存的 要添加 apiType 类型 ZBRequestTypeRefresh  每次就会重新请求url
     *  请求下来的缓存会覆盖原有的缓存文件
     */
 
    if (_functionType==AFNetworking) {
        
        [self getAFNetworkWithApiType:ZBRequestTypeRefresh];
        
    }else if (_functionType==sessionblock){
        
        [self getSessionBlockWithApiType:ZBRequestTypeRefresh];
        
    }else if(_functionType==sessiondelegate){
        //需要 ZBURLSessionDelegate 协议
        [[ZBURLSessionManager sharedManager]getRequestWithURL:list_URL target:self apiType:ZBRequestTypeRefresh];
    }
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新..."];
    /**
     * 上拉加载 要添加 apiType 类型 ZBRequestTypeLoadMore
     */
}

#pragma mark tableView

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *iden=@"iden";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:iden];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    RootModel *model=[self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text=model.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"更新时间:%@",model.detail];
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RootModel *model=[self.dataArray objectAtIndex:indexPath.row];
    DetailViewController *detailsVC=[[DetailViewController alloc]init];
    
    NSString *url=[NSString stringWithFormat:details_URL,model.wid];
    detailsVC.urlString=url;
    [self.navigationController pushViewController:detailsVC animated:YES];
    
}

- (void)btnClick{
    
    SettingViewController *settingVC=[[SettingViewController alloc]init];
    
    [self.navigationController pushViewController:settingVC animated:YES];
    
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
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
