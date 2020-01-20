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
     NSLog(@"当前是否有网：%d",[ZBRequestManager isNetworkReachable]);
    /**
     基础配置
     需要在请求之前配置，设置后所有请求都会带上 此基础配置
     */
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"github"] = @"https://github.com/Suzhibin/ZBNetworking";
    parameters[@"jianshu"] = @"https://www.jianshu.com/p/55cda3341d11";
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.2f",timeInterval];
    parameters[@"timeString"] =timeString;//时间戳

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"Token"] = @"Token";

    [ZBRequestManager setupBaseConfig:^(ZBConfig * _Nullable config) {
        config.baseURL=server_URL;//如果同一个环境，有多个域名 不要设置baseURL
        config.baseParameters=parameters;//公告参数
        // filtrationCacheKey因为时间戳是变动参数，缓存key需要过滤掉 变动参数,如果 不使用缓存功能 或者 没有变动参数 则不需要设置。
        config.baseFiltrationCacheKey=@[@"timeString"];
        config.baseHeaders=headers;//请求头
        config.baseRequestSerializer=ZBJSONRequestSerializer; //全局设置 请求格式 默认JSON
        config.baseResponseSerializer=ZBJSONResponseSerializer; //全局设置 响应格式 默认JSON
        config.baseTimeoutInterval=15;//超时时间  优先级 小于 单个请求重新设置
        //config.baseRetryCount=2;//请求失败 所有请求重新连接次数
        config.consoleLog=YES;//开log
        config.baseUserInfo=@{@"info":@"ZBNetworking"};//请求的信息，可以用来注释和判断使用
    }];

   
   
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
    [self customItemWithTitle:@"拦截请求" selectedTitle:@"取消拦截" selector:@selector(leftBtnClick:) location:YES];
}
- (void)leftBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    /**
    自定义 所有 请求,响应 处理逻辑的方法
    比如 1.自定义缓存逻辑 感觉ZBNetworking缓存不好，想使用yycache 等
        2.自定义响应逻辑 服务器会在成功回调里做 返回code码的操作
        3.一个应用有多个服务器地址，在此进行配置
        4. ......
    */
    [ZBRequestManager requestProcessHandler:^(ZBURLRequest * _Nullable request,id _Nullable __autoreleasing * _Nullable setObject) {
        NSLog(@"请求之前");
        /**
         请求前的 逻辑处理
        */
        if ([request.userInfo[@"tag"]isEqualToString:@"1000"]) {
            //比如 我们可以根据参数寻找一个业务的请求 ，给改该请求做一个替换响应数据的操作
//            NSString *path= request.parameters[@"path"];
//            if ([path isEqualToString:@"HomeViewController"]||[path isEqualToString:@"DetailViewController"]) {
                if (sender.selected==YES) {
                    /**
                    //⚠️setObject 赋值 就会走成功回调
                    如判断内的请求包含keep请求，keep功能将不会受此影响
                    request.keepType=ZBResponseKeepFirst
                    request.keepType=ZBResponseKeepLast
                    */
                    *setObject=@{ @"authors":@[@{@"errorCode":@"400"}],
                                                        @"videos":@[@{@"errorCode":@"400"}]
                                                       };
                }else{
                    *setObject=nil;
                }
           // }
        }
        if ([request.userInfo[@"tag"]isEqualToString:@"8888"]){
            /**
             如果服务器有多个域名 可以在此配置，并不可以使用config.baseURL。
             也可以在每个请求的URLString赋值时拼接
             */
            NSString *URL;
            if ([request.userInfo[@"tag"]isEqualToString:@"111"]){
                URL=[NSString stringWithFormat:@"https://AAAURL.com/%@",request.URLString] ;
            }
            if ([request.userInfo[@"tag"]isEqualToString:@"222"]){
                URL=[NSString stringWithFormat:@"https://BBBURL.com/%@",request.URLString] ;
            }
            if ([request.userInfo[@"tag"]isEqualToString:@"333"]){
                URL=[NSString stringWithFormat:@"https://CCCURL.com/%@",request.URLString] ;
            }
            request.URLString=URL;
        }
        if ([request.userInfo[@"tag"]isEqualToString:@"9999"]) {
        
            //自定义缓存逻辑时apiType需要设置为 request.apiType=ZBRequestTypeRefresh（默认）这样就不会走ZBNetworking自带缓存了
            request.apiType=ZBRequestTypeRefresh;
            //排除上传和下载请求
            if (request.methodType!=ZBMethodTypeUpload||request.methodType!=ZBMethodTypeDownLoad) {
                NSDictionary *dict= [[DataManager sharedInstance] dataInfoWithKey:[NSString stringWithFormat:@"%@%@",request.URLString,request.parameters[@"author"]]];
                if (dict) {
                    if (sender.selected==YES) {
                        //⚠️setObject 赋值 就会走成功回调
                        *setObject=dict;
                    }else{
                        *setObject=nil;
                    }
                }
            }
        }
       
    } responseProcessHandler:^(ZBURLRequest * _Nullable request, id  _Nullable responseObject, NSError * _Nullable __autoreleasing *error) {
        NSLog(@"成功回调 数据返回之前");
        if ([request.userInfo[@"tag"]isEqualToString:@"1000"]) {
            /**
            网络请求 自定义响应结果的处理逻辑
            比如服务器会在成功回调里做 返回code码的操作 ，可以进行逻辑处理
             */
            // 举个例子 假设服务器成功回调内返回了code码
            NSArray * authors;
            NSString *path= request.parameters[@"path"];
            if ([path isEqualToString:@"HomeViewController"]) {
              authors=responseObject[@"authors"];
            }
            if ([path isEqualToString:@"DetailViewController"]) {
                authors=responseObject[@"videos"];
            }
          
            NSString * errorCode= [[authors objectAtIndex:0]objectForKey:@"errorCode"];
            if ([errorCode isEqualToString:@"400"]) {//假设400 登录过期
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"登录过期"};
                NSLog(@"重新开始业务请求：%@ 参数：%@",request.URLString,request.parameters[@"path"]);
            
                if (sender.selected==YES) {
                      //⚠️给*error指针 错误信息，网络请求就会走 失败回调
                      *error = [NSError errorWithDomain:NSURLErrorDomain code:[errorCode integerValue] userInfo:userInfo];
                }else{
                      *error = nil;
                }
            }
        }
        if ([request.userInfo[@"tag"]isEqualToString:@"8888"]){
            
        }
        if([request.userInfo[@"tag"]isEqualToString:@"9999"]){
              //自定义缓存逻辑时apiType需要设置为 request.apiType=ZBRequestTypeRefresh（默认）这样就不会走ZBNetworking自带缓存了
            //排除上传和下载请求
            if (request.methodType!=ZBMethodTypeUpload||request.methodType!=ZBMethodTypeDownLoad) {
                [[DataManager sharedInstance] saveDataInfo:responseObject key:[NSString stringWithFormat:@"%@%@",request.URLString,request.parameters[@"author"]]];
            }
        }
    }];
}
#pragma mark - request
//apiType 是请求类型 在ZBRequestConst 里
- (void)getDataWithApiType:(ZBApiType)apiType{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"path"] = @"HomeViewController";
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"headers"] = @"herader";
    [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        //request.URLString=[NSString stringWithFormat:@"%@%@",server_URL,list_URL] ;
        request.URLString=list_URL;
        request.methodType=ZBMethodTypeGET;//默认为GET
        request.apiType=apiType;//（默认为ZBRequestTypeRefresh 不读取缓存，不存储缓存）
        request.parameters=parameters;//与baseParameters 兼容
        request.headers= headers;//与baseHeaders 兼容
        /**
         保留第一次或最后一次请求结果 只在请求时有用  读取缓存无效果。默认ZBResponseKeepNone 什么都不做
         使用场景是在 重复点击造成的 多次请求，如发帖，评论，搜索等业务
         */
        //request.keepType=ZBResponseKeepNone;
       // request.retryCount=1;//请求失败 单次请求 重新连接次数 优先级大于 全局设置，不影响其他请求设置
        request.filtrationCacheKey=@[@""];//与basefiltrationCacheKey 兼容
        request.requestSerializer=ZBJSONRequestSerializer; //单次请求设置 请求格式 默认JSON，优先级大于 全局设置，不影响其他请求设置
        request.responseSerializer=ZBJSONResponseSerializer; //单次请求设置 响应格式 默认JSON，优先级大于 全局设置,不影响其他请求设置
        request.timeoutInterval=10;//默认30 //优先级 高于 全局设置,不影响其他请求设置
        request.userInfo=@{@"tag":requestTag};//与baseUserInfo 不兼容 优先级大于 全局设置
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
                self.title=@"使用了缓存";
            }else{
                self.title=@"重新请求";
            }
        }
        
    } failure:^(NSError *error){
        if (error.code==NSURLErrorCancelled)return;
        if (error.code==NSURLErrorTimedOut){
            [self alertTitle:@"请求超时" andMessage:@""];
        }else{
            [self alertTitle:@"请求失败" andMessage:[error.userInfo objectForKey:NSLocalizedDescriptionKey]];
        }
        [self.refreshControl endRefreshing];  //结束刷新
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
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer) userInfo:nil repeats:NO];
}

- (void)timer{
    /**
     *  下拉刷新是不读缓存的 要添加 apiType 类型 ZBRequestTypeRefreshAndCache  每次就会重新请求url
     *  请求下来的缓存会覆盖原有的缓存文件
     */
    [self getDataWithApiType:ZBRequestTypeRefreshAndCache];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新..."];
    
    /**
     * 上拉加载 要添加 apiType 类型 ZBRequestTypeRefreshMore(重新请求)
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
    
    HomeModel *model=[self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text=model.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"更新时间:%@",model.detail];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeModel *model=[self.dataArray objectAtIndex:indexPath.row];
    DetailViewController *detailsVC=[[DetailViewController alloc]init];
    detailsVC.wid=model.wid;
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
