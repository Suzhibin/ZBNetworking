//
//  DetailsViewController.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/6/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "DetailsViewController.h"
#import "DetailsModel.h"
#import "ZBNetworking.h"



@interface DetailsViewController ()<ZBURLSessionDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UITableView *tableView;
@end

@implementation DetailsViewController

- (void)dealloc{
    
#warning 必须实现
    /**
     *  在ViewController被销毁之前,将delegate置为nil
     */
    [[ZBRequestManager shareManager] clearDelegateForKey:_urlString];


#warning 可选实现
    /**
     防止网络不好 请求未完成用户就退出页面 ,而请求还在继续 浪费用户流量 ,所以页面退出 要释放session. 也可避免造成内存泄露.
     */
    [[ZBRequestManager shareManager] requestToCancel:YES];
    
    /**
     *  AFNetWorking 也有此方法[[AFHTTPSessionManager manager] invalidateSessionCancelingTasks:YES];
    
     */
   

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    _dataArray=[[NSMutableArray alloc]init];
    
//    NSLog(@"urlString:%@",_urlString);
  
    /**
     *  如果详情页面不想要缓存 要添加 apiType 类型 kRefreshType  每次就会重新请求url
     *  [ZBURLSessionManager getRequestWithUrlString:url target:self apiType:kRefreshType];
     */
    
    
    [ZBURLSessionManager getRequestWithUrlString:_urlString target:self];
   
    
    [self.view addSubview:self.tableView];
}

#pragma mark - ZBURLSessionManager Delegate
- (void)urlRequestFinished:(ZBURLSessionManager *)request
{
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:NSJSONReadingMutableContainers error:nil];
     NSArray *array=[dataDict objectForKey:@"videos"];
    
    for (NSDictionary *dict in array) {
        DetailsModel *model=[[DetailsModel alloc]init];

        [model setValuesForKeysWithDictionary:dict];
        [_dataArray addObject:model];

    }
     [_tableView reloadData];
    
    
}

- (void)urlRequestFailed:(ZBURLSessionManager *)request
{
    if (request.error.code==-999)return;
    if (request.error.code==NSURLErrorTimedOut) {
  
        [self alertTitle:@"请求超时" andMessage:@""];
    }else{

        [self alertTitle:@"请求失败" andMessage:@""];
    }
}


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
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
  
        
        
    }
    DetailsModel *model=[_dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text=model.title;

    cell.detailTextLabel.text=[NSString stringWithFormat:@"发布时间:%@",model.date];

    return cell;
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
