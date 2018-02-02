//
//  HomeViewController.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/8/24.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "HomeViewController.h"
#import "ZBNetworking.h"
#import "RootModel.h"
#import "DetailViewController.h"
#import "SettingViewController.h"
#import "otherMethodViewController.h"
@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UIRefreshControl *refreshControl;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"GET请求";
    /**
     *  ZBRequestTypeCache 为 有缓存使用缓存 无缓存就重新请求
     *  默认缓存路径/Library/Caches/ZBKit/AppCache
     */
    [self getDataWithApiType:ZBRequestTypeCache];
    
    
    [self.tableView addSubview:self.refreshControl];
    [self.view addSubview:self.tableView];
    
    [self addItemWithTitle:@"设置缓存" selector:@selector(btnClick) location:NO];
    
    [self addItemWithTitle:@"其他方法" selector:@selector(otherbtnClick) location:YES];
    
}
#pragma mark - AFNetworking
//apiType 是请求类型 在ZBRequestConst 里
- (void)getDataWithApiType:(apiType)requestType{
    
    [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        request.urlString=list_URL;
        request.methodType=ZBMethodTypeGET;//默认为GET
        request.apiType=requestType;//默认为ZBRequestTypeRefresh
        request.timeoutInterval=10;
    }  success:^(id responseObject,apiType type){
        //如果是刷新的数据
        if (type==ZBRequestTypeRefresh) {
            [self.dataArray removeAllObjects];
           
        }
        //上拉加载 要添加 apiType 类型 ZBRequestTypeCacheMore(读缓存)或ZBRequestTypeRefreshMore(重新请求)， 也可以不遵守此枚举
        if (type==ZBRequestTypeRefreshMore) {
            //上拉加载 
        }
 
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray *array=[dict objectForKey:@"authors"];
        
        for (NSDictionary *dic in array) {
            RootModel *model=[[RootModel alloc]init];
            model.name=[dic objectForKey:@"name"];
            model.wid=[dic objectForKey:@"id"];
            model.detail=[dic objectForKey:@"detail"];
            [self.dataArray addObject:model];
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];    //结束刷新
        
    } failed:^(NSError *error){
        if (error.code==NSURLErrorCancelled)return;
        if (error.code==NSURLErrorTimedOut){
            [self alertTitle:@"请求超时" andMessage:@""];
        }else{
            [self alertTitle:@"请求失败" andMessage:@""];
        }
        [self.refreshControl endRefreshing];  //结束刷新
    }];
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
    [self.refreshControl beginRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中"];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer) userInfo:nil repeats:NO];
}

- (void)timer{
    /**
     *  下拉刷新是不读缓存的 要添加 apiType 类型 ZBRequestTypeRefresh  每次就会重新请求url
     *  请求下来的缓存会覆盖原有的缓存文件
     */
    
    [self getDataWithApiType:ZBRequestTypeRefresh];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新..."];
    
    /**
     * 上拉加载 要添加 apiType 类型 ZBRequestTypeLoadMore(读缓存)或ZBRequestTypeRefreshMore(重新请求)
     */
}

#pragma mark tableView

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

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
- (void)otherbtnClick{
    otherMethodViewController *settingVC=[[otherMethodViewController alloc]init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)btnClick{
    
    SettingViewController *settingVC=[[SettingViewController alloc]init];
    [self.navigationController pushViewController:settingVC animated:YES];
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
