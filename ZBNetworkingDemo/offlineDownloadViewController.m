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

@property (nonatomic,strong)ZBURLRequest *request;
@end

@implementation offlineDownloadViewController

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
   
    NSLog(@"离开页面时 清空容器");
    [self.request removeOfflineArray];
    
    [self.delegate reloadJsonNumber];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray=[[NSMutableArray alloc]init];
    
    self.request=[[ZBURLRequest alloc]init];
    
    //保证频道是最新的 不要取缓存
    [[ZBURLSessionManager sharedManager] getRequestWithURL:list_URL target:self apiType:ZBRequestTypeDefault];
    
    [self.view addSubview:self.tableView];
  
    [self addItemWithTitle:@"离线下载" selector:@selector(offlineBtnClick) location:NO];
 
}
#pragma mark - ZBURLSessionManager Delegate
- (void)urlRequestFinished:(ZBURLRequest *)request{

    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.responseObj options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *array=[dict objectForKey:@"authors"];
    
    for (NSDictionary *dic in array) {
        RootModel *model=[[RootModel alloc]init];
        model.name=[dic objectForKey:@"name"];
        model.wid=[dic objectForKey:@"id"];
        [self.dataArray addObject:model];
        
    }
    [_tableView reloadData];
    
}
- (void)urlRequestFailed:(ZBURLRequest *)request{
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
- (void)switchValueChanged:(UISwitch *)sw{
    RootModel *model=[self.dataArray objectAtIndex:sw.tag];
    NSString *url=[NSString stringWithFormat:details_URL,model.wid];
    
    if (sw.isOn == YES) {
        //添加请求列队
        [self.request addObjectWithUrl:url];
        [self.request addObjectWithKey:model.name];
         NSLog(@"离线请求的url:%@",self.request.offlineUrlArray);
    }else{
        //删除请求列队
        [self.request removeObjectWithUrl:url];
        [self.request removeObjectWithKey:model.name];
         NSLog(@"离线请求的url:%@",self.request.offlineUrlArray);
    }
}


- (void)offlineBtnClick{
    
    if (self.request.offlineUrlArray.count==0) {
        
        [self alertTitle:@"请添加栏目" andMessage:@""];
        
    }else{
       
        NSLog(@"离线请求的栏目/url个数:%lu",self.request.offlineUrlArray.count);
    
        for (NSString *name in self.request.offlineKeyArray) {
            NSLog(@"离线请求的name:%@",name);
        }
       
        [self.delegate downloadWithArray:self.request.offlineUrlArray];
        
        [self.navigationController popViewControllerAnimated:YES];

    }
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
