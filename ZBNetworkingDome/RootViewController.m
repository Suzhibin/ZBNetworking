//
//  RootViewController.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/6/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "RootViewController.h"
#import "ZBNetworking.h"
#import "RootModel.h"
#import "DetailsViewController.h"
#import "SettingViewController.h"

#define Root_URL @"http://api.dotaly.com/lol/api/v1/authors?iap=0&ident=6B82A117-E1CB-40C0-97A8-1D6C78D53069&jb=0&token=a545841af74a6712006a029528729392"

#define details_URL @"http://api.dotaly.com/lol/api/v1/shipin/latest?author=%@&iap=0&ident=6B82A117-E1CB-40C0-97A8-1D6C78D53069&jb=0&limit=50&offset=0&token=51bea81c7e1dda99290115e4fbd6092f"

@interface RootViewController ()<ZBURLSessionDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UIRefreshControl *refreshControl;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    _dataArray=[[NSMutableArray alloc]init];
    

    /**
     *  默认缓存路径/Library/Caches/ZBCache
     */
   
    [ZBURLSessionManager getRequestWithUrlString:Root_URL target:self];
    
    
    [self refresh];
    
    [self.view addSubview:self.tableView];

  
    
    UIBarButtonItem *rightbtn=[[UIBarButtonItem alloc]initWithTitle:@"清除缓存" style:UIBarButtonItemStylePlain  target:self action:@selector(btnclick)];
    
    self.navigationItem.rightBarButtonItem = rightbtn;

}

#pragma mark - ZBURLSessionManager Delegate
- (void)urlRequestFinished:(ZBURLSessionManager *)request
{

    
    //如果是刷新的数据
    if (request.apiType==kRefreshType) {
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
    if (request.apiType==kRefreshType) {
        //结束刷新
        [_refreshControl endRefreshing];
    }
    if (request.error.code==-999)return;
    if (request.error.code==NSURLErrorTimedOut) {

        [self alertTitle:@"请求超时" andMessage:@""];
    }else{

       [self alertTitle:@"请求失败" andMessage:@""];
    }
}

#pragma mark - 刷新
- (void)refresh
{
    //下拉刷新
    _refreshControl = [[UIRefreshControl alloc] init];
    //标题
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新..."];
    //事件
    [_refreshControl addTarget:self action:@selector(refreshDown) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
}
- (void)refreshDown{
    //开始刷新
    [_refreshControl beginRefreshing];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中"];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer) userInfo:nil repeats:NO];
}

- (void)timer{
    /**
     *  刷新正常是不读缓存的 要添加 apiType 类型 kRefreshType  每次就会重新请求url
     */
    /**
     *  类方法
     *  [ZBURLSessionManager getRequestWithUrlString:Root_URL target:self apiType:kRefreshType];
     */
   
    /**
     *  实例方法
     */
    ZBURLSessionManager *manager=[ZBURLSessionManager manager];
    [manager setTimeoutInterval:10];//更改超时时间 默认15秒
    [manager getRequestWithUrlString:Root_URL target:self apiType:kRefreshType];

    [_tableView reloadData];
   
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
    DetailsViewController *detailsVC=[[DetailsViewController alloc]init];
    
    NSString *url=[NSString stringWithFormat:details_URL,model.wid];
    detailsVC.urlString=url;
    [self.navigationController pushViewController:detailsVC animated:YES];
    
    
}


- (void)btnclick
{
    
    SettingViewController *settingVC=[[SettingViewController alloc]init];
    
    [self.navigationController pushViewController:settingVC animated:YES];
    
}
- (void)viewDidLayoutSubviews
{
    [self.refreshControl.superview sendSubviewToBack:self.refreshControl];
}
- (void)alertTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //
    [alertView show];
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
