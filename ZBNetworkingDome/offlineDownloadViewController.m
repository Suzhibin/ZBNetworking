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
@property (nonatomic,strong) NSMutableArray *channelArray;
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
    self.channelArray=[[NSMutableArray alloc]init];
    
    //此页的数据也是有缓存的
    [self.manager getRequestWithUrlString:home_URL target:self];
    [self.view addSubview:self.tableView];
    
    [self addItemWithTitle:@"离线下载" selector:@selector(btnClick) location:NO];
}
#pragma mark - ZBURLSessionManager Delegate
- (void)urlRequestFinished:(ZBURLSessionManager *)request
{

    //如果是离线数据
    if (request.apiType==ZBRequestTypeOffline) {
        NSLog(@"添加了几个离线下载 就会走几遍");
    }
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
    
    BOOL isThere = [self.channelArray containsObject: url];
    
    if (sw.isOn == YES) {

        if (isThere==1) {
            NSLog(@"已经包含该频道");
        }else{
            [self.channelArray addObject:url];
        
        }
      
    }else{
 
        if (isThere==1) {
            [self.channelArray removeObject:url];
    
        }else{
           NSLog(@"已经删除该频道");
        }
        
       
    }
}


- (void)btnClick
{
    if (self.channelArray.count==0) {
        [self alertTitle:@"没有数据" andMessage:@"请添加频道"];
    }else{
          NSLog(@"离线请求的url:%@",self.channelArray);
        //离线请求
        [self.manager offlineDownload:self.channelArray target:self apiType:ZBRequestTypeOffline];
        
      //  [self alertTitle:@"被点击的频道" andMessage:@"如果之前有缓存 点击将不会下载"];
         NSLog(@"被点击的频道,如果之前有缓存 点击将不会下载");
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
