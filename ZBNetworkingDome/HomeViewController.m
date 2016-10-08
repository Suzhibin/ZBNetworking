//
//  HomeViewController.m
//  ZBNetworkingDome
//
//  Created by NQ UEC on 16/8/24.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "HomeViewController.h"
#import "ZBNetworking.h"
#import "RootModel.h"
#import "DetailViewController.h"
#import "SettingViewController.h"

@interface HomeViewController ()<ZBURLSessionDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UIRefreshControl *refreshControl;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataArray=[[NSMutableArray alloc]init];
   
    /**
     *  默认缓存路径/Library/Caches/AppCache
     */
    [[ZBURLSessionManager shareManager]getRequestWithUrlString:home_URL target:self];

    [self.tableView addSubview:self.refreshControl];
    [self.view addSubview:self.tableView];
    
    [self addItemWithTitle:@"设置" selector:@selector(btnClick) location:NO];

}

#pragma mark - ZBURLSessionManager Delegate
- (void)urlRequestFinished:(ZBURLSessionManager *)request
{
     //如果是刷新的数据
    if (request.apiType==ZBRequestTypeRefresh) {
        
        [_dataArray removeAllObjects];
        //结束刷新
        [_refreshControl endRefreshing];
        
    }
  
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:NSJSONReadingMutableContainers error:nil];

    NSArray *array=[dict objectForKey:@"authors"];
    
    for (NSDictionary *dic in array) {
        RootModel *model=[[RootModel alloc]init];
        model.name=[dic objectForKey:@"name"];
        model.wid=[dic objectForKey:@"id"];
        model.detail=[dic objectForKey:@"detail"];
        [_dataArray addObject:model];
        
    }
    [_tableView reloadData];
    
}
- (void)urlRequestFailed:(ZBURLSessionManager *)request
{
    //如果是刷新的数据
    if (request.apiType==ZBRequestTypeRefresh) {
        //结束刷新
        [_refreshControl endRefreshing];
    }
    if (request.error.code==NSURLErrorCancelled)return;
    if (request.error.code==NSURLErrorTimedOut) {
        [self alertTitle:@"请求超时" andMessage:@""];
    }else{
        [self alertTitle:@"请求失败" andMessage:@""];
    }
}


#pragma mark - 刷新
- (UIRefreshControl *)refreshControl
{
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
     *  刷新是不读缓存的 要添加 apiType 类型 ZBRequestTypeRefresh  每次就会重新请求url
     *  请求下来的缓存会覆盖原有的缓存文件
     */
   [[ZBURLSessionManager shareManager] getRequestWithUrlString:home_URL target:self apiType:ZBRequestTypeRefresh];
    
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新..."];
    
}


#pragma mark tableView

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *iden=@"iden";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:iden];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    RootModel *model=[_dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text=model.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"更新时间:%@",model.detail];
    
    
    
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RootModel *model=[_dataArray objectAtIndex:indexPath.row];
    DetailViewController *detailsVC=[[DetailViewController alloc]init];
    
    NSString *url=[NSString stringWithFormat:details_URL,model.wid];
    detailsVC.urlString=url;
    [self.navigationController pushViewController:detailsVC animated:YES];
    
    
}


- (void)btnClick
{
    
    SettingViewController *settingVC=[[SettingViewController alloc]init];
    
    [self.navigationController pushViewController:settingVC animated:YES];
    
}
- (void)viewDidLayoutSubviews
{
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
