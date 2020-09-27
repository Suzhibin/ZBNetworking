//
//  HomeViewController.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/8/24.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "HomeViewController.h"
#import "ZBNetworking.h"
#import "HomeModel.h"
#import "DetailViewController.h"
#import "SettingViewController.h"
#import "DataManager.h"
@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UIRefreshControl *refreshControl;
@end

@implementation HomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     NSLog(@"当前是否有网：%d 状态：%ld",[ZBRequestManager isNetworkReachable],[ZBRequestManager networkReachability]);
    [DataManager sharedInstance].tag=@"6666";
    
    #pragma mark -  公共配置 RequestTool
    /**
     公共配置
     插件机制
     证书设置
     */
    [RequestTool setupPublicParameters]; //设置在所有请求前 一般放在AppDelegate 中调用

    [self.tableView addSubview:self.refreshControl];
    [self.view addSubview:self.tableView];
     
    /**
     *  ZBRequestTypeRefresh          每次会重新请求 不存储缓存
     *  ZBRequestTypeRefreshAndCache  每次会重新请求 存储，更新缓存
     *  ZBRequestTypeCache            有缓存使用缓存 无缓存就重新请求 存储，更新缓存
     *  ZBRequestTypeRefreshMore      每次会重新请求 不存储缓存 （业务类型，可不使用，只是为了区分上拉加载业务）
     *  支持内存缓存 和 沙盒缓存
     *  沙盒默认缓存路径/Library/Caches/ZBKit/AppCache
     */
    [self getDataWithApiType:ZBRequestTypeCache];
    
    [self addItemWithTitle:@"设置缓存" selector:@selector(btnClick) location:NO];
}

#pragma mark - request
//apiType 是请求类型 在ZBRequestConst 里
- (void)getDataWithApiType:(ZBApiType)apiType{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"path"] = @"HomeViewController";
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"headers"] = @"herader";
    [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
       //request.server=server_URL; 优先级大于 公共配置baseServer 兼容了同一环境，有多个服务器地址的问题
        request.url=list_URL;
        request.methodType=ZBMethodTypeGET;//默认为GET
        request.apiType=apiType;//（默认为ZBRequestTypeRefresh 不读取缓存，不存储缓存）
        request.parameters=parameters;//与公共配置 Parameters 兼容
        request.headers= headers;//与公共配置 Headers 兼容
        /**
         多次请求同一个接口 保留第一次或最后一次请求结果 只在请求时有用  读取缓存无效果。默认ZBResponseKeepNone 什么都不做
         使用场景是在 重复点击造成的 多次请求，如发帖，评论，搜索等业务
         */
        //request.keepType=ZBResponseKeepNone;
       // request.retryCount=1;//请求失败 单次请求 重新连接次数 优先级大于 全局设置，不影响其他请求设置
        request.filtrationCacheKey=@[@""];//与公共配置 filtrationCacheKey 兼容
        request.requestSerializer=ZBJSONRequestSerializer; //单次请求设置 请求格式 默认JSON，优先级大于 公共配置，不影响其他请求设置
        request.responseSerializer=ZBJSONResponseSerializer; //单次请求设置 响应格式 默认JSON，优先级大于 公共配置,不影响其他请求设置
        request.timeoutInterval=10;//默认30 //优先级 高于 公共配置,不影响其他请求设置
        request.userInfo=@{@"tag":[DataManager sharedInstance].tag};//与公共配置 UserInfo 不兼容 优先级大于 公共配置
    }  success:^(id responseObject,ZBURLRequest * request){
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSArray *array=[dict objectForKey:@"authors"];
            //如果是刷新的数据
            if (request.apiType==ZBRequestTypeRefreshAndCache) {
                [self.dataArray removeAllObjects];
               
            }
            //上拉加载 业务 apiType 类型 ZBRequestTypeRefreshMore(重新请求)， 也可以不遵守此类型
            if (request.apiType==ZBRequestTypeRefreshMore) {
                //上拉加载
            }
            
            for (NSDictionary *dic in array) {
                HomeModel *model=[[HomeModel alloc]initWithDict:dic];
                [self.dataArray addObject:model];
            }
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];    //结束刷新
            if (request.isCache==YES) {
                self.navigationItem.title=@"使用了缓存";
                [DataManager sharedInstance].cacheKey=request.cacheKey;
            }else{
                self.navigationItem.title=@"重新请求";
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)request.response;
                NSDictionary *allHeaders = response.allHeaderFields;
                NSLog(@"allHeaders:%@",allHeaders);
            }
        }
        
    } failure:^(NSError *error){
        [self.refreshControl endRefreshing];  //结束刷新
    } finished:^(id responseObject, NSError *error, ZBURLRequest *request) {
        NSLog(@"请求完成userInfo:%@",request.userInfo);
    }];
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
           [self getDataWithApiType:ZBRequestTypeRefreshAndCache];
           
           self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新..."];
           
           /**
            * 上拉加载 要添加 apiType 类型 ZBRequestTypeRefreshMore(重新请求)
            */
    });
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
    
    HomeModel *model=[self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text=model.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"更新时间:%@",model.detail];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeModel *model=[self.dataArray objectAtIndex:indexPath.row];
    DetailViewController *detailsVC=[[DetailViewController alloc]init];
    detailsVC.wid=model.wid;
    detailsVC.hidesBottomBarWhenPushed=YES;
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

- (void)btnClick{
    
    SettingViewController *settingVC=[[SettingViewController alloc]init];
    settingVC.hidesBottomBarWhenPushed = YES;
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
