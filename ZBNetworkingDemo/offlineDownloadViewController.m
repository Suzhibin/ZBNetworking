//
//  offlineDownloadViewController.m
//  ZBNetworking
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

- (ZBURLSessionManager *)session {
    
    return [ZBURLSessionManager sharedManager];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
   
    NSLog(@"离开页面时 清空容器");
    [self.manager removeOfflineArray];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray=[[NSMutableArray alloc]init];
 
    //创建单例
     self.manager=[self session];
    
    //保证频道是最新的 不要取缓存
    [self.manager getRequestWithUrlString:home_URL target:self apiType:ZBRequestTypeRefresh];
    
    [self.view addSubview:self.tableView];
  
    [self addItemWithTitle:@"离线下载" selector:@selector(offlineBtnClick) location:NO];
 
}
#pragma mark - ZBURLSessionManager Delegate
- (void)urlRequestFinished:(ZBURLSessionManager *)request
{

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
        [self alertTitle:@"请求超时" andMessage:@"" isother:nil];
    }else{
        [self alertTitle:@"请求失败" andMessage:@"" isother:nil];
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
         NSLog(@"离线请求的url:%@",self.manager.offlineUrlArray);
    }else{
        //删除请求列队
        [self.manager removeObjectWithUrl:url];
        [self.manager removeObjectWithName:model.name];
         NSLog(@"离线请求的url:%@",self.manager.offlineUrlArray);
    }
}


- (void)offlineBtnClick
{
    
    if (self.manager.offlineUrlArray.count==0) {
        
        [self alertTitle:@"请添加栏目" andMessage:@"" isother:nil];
        
    }else{
       
        NSLog(@"离线请求的栏目/url个数:%lu",self.manager.offlineUrlArray.count);
        
        for (NSString *name in self.manager.offlineNameArray) {
            NSLog(@"离线请求的name:%@",name);
        }

        [self.delegate downloadWithArray:self.manager.offlineUrlArray];
        
        [self.navigationController popViewControllerAnimated:YES];

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
