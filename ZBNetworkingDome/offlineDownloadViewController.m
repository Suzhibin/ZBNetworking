//
//  offlineDownloadViewController.m
//  ZBNetworkingDome
//
//  Created by NQ UEC on 16/9/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "offlineDownloadViewController.h"
#import "ZBNetworking.h"
#import "RootModel.h"
@interface offlineDownloadViewController ()<UITableViewDelegate,UITableViewDataSource,ZBURLSessionDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)ZBURLSessionManager *manager;
@end

@implementation offlineDownloadViewController
- (ZBURLSessionManager *)manager
{
    if (!_manager) {
        _manager = [ZBURLSessionManager manager];
    }
    return _manager;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"离开页面时 刷新上一页缓存大小");
    [self.delegate refreshSize];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray=[[NSMutableArray alloc]init];
    
    //保证频道是最新的 不要取缓存
    [self.manager getRequestWithUrlString:home_URL target:self apiType:ZBRequestTypeRefresh];
    
    [self.view addSubview:self.tableView];
    
    [self addItemWithTitle:@"离线下载" selector:@selector(btnClick) location:NO];
}
#pragma mark - ZBURLSessionManager Delegate
- (void)urlRequestFinished:(ZBURLSessionManager *)request
{
    //如果是离线数据
    if (request.apiType==ZBRequestTypeOffline) {
        
        NSLog(@"添加了几个离线下载 就会走几遍");
        
    }else{
      
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:NSJSONReadingMutableContainers error:nil];
        
        NSArray *array=[dict objectForKey:@"authors"];
        
        for (NSDictionary *dic in array) {
            RootModel *model=[[RootModel alloc]init];
            model.name=[dic objectForKey:@"name"];
            model.wid=[dic objectForKey:@"id"];
            [self.dataArray addObject:model];
            
        }
        [_tableView reloadData];
    
      }

}
- (void)urlRequestFailed:(ZBURLSessionManager *)request
{
    if (request.error.code==NSURLErrorCancelled)return;
    if (request.error.code==NSURLErrorTimedOut) {
        
        [self alertTitle:@"请求超时" andMessage:@""];
    }else{
        
        [self alertTitle:@"请求失败" andMessage:@""];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIde=@"cellIde";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
    }
    UISwitch *sw = [[UISwitch alloc] init];
    sw.center = CGPointMake(160, 90);
    sw.tag = indexPath.row;
    [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = sw;
    
    RootModel *model=[self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text=model.name;
        

    
    return cell;
}
- (void)switchValueChanged:(UISwitch *)sw
{
    RootModel *model=[self.dataArray objectAtIndex:sw.tag];
    NSString *url=[NSString stringWithFormat:details_URL,model.wid];
    
    
    if (sw.isOn == YES) {
        //添加请求列队
        [self.manager addObjectWithUrl:url];
        [self.manager addObjectWithName:model.name];
      
    }else{
        //删除请求列队
        [self.manager removeObjectWithUrl:url];
        [self.manager addObjectWithName:model.name];
        
    }
}


- (void)btnClick
{
    if (self.manager.offlineUrlArray.count==0) {
        
        [self alertTitle:@"请添加栏目" andMessage:@""];
        
    }else{
        
        for (NSString *name in self.manager.offlineNameArray) {
            NSLog(@"离线请求的name:%@",name);
        }
        
        NSLog(@"离线请求的url:%@",self.manager.offlineUrlArray);
        NSLog(@"离线请求的url个数:%ld",self.manager.offlineUrlArray.count);
        NSLog(@"为保证栏目是最新的数据，请求列队都是重新请求。如果之前有缓存 下载会覆盖之前的缓存，所以覆盖的缓存文件数量是不增长的");
        
        //离线请求 apiType:ZBRequestTypeOffline
        [self.manager offlineDownload:self.manager.offlineUrlArray target:self apiType:ZBRequestTypeOffline];
        
    }
}
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
