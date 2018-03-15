//
//  DetailViewController.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/8/24.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailsModel.h"
#import "ZBNetworking.h"
#import <UIImageView+WebCache.h>
@interface DetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UITableView *tableView;

@end

@implementation DetailViewController
- (void)dealloc{
   NSLog(@"释放%s",__func__);
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    /**
     防止网络不好 请求未完成用户就退出页面 ,而请求还在继续 浪费用户流量 ,所以页面退出 要取消对应的请求。
     */
    [ZBRequestManager cancelRequest:_urlString completion:^(BOOL results, NSString *urlString) {
        //如果请求成功 或 读缓存 会返回null 无法取消。请求未完成的会取消并返回对应url results 为yes
        //NSLog(@"取消对应url:%@ ",urlString);
    }];
    
    [[SDWebImageManager sharedManager] cancelAll];//取消图片下载
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    /**
     *  如果页面不想使用缓存 要添加 apiType 类型 ZBRequestTypeRefresh  每次就会重新请求url
     */
    
   [ZBRequestManager requestWithConfig:^(ZBURLRequest *request){
        request.urlString=_urlString;
        request.apiType=ZBRequestTypeDetailCache;
    }  success:^(id responseObject,apiType type){
       // NSLog(@"type:%zd",type);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray *array=[dataDict objectForKey:@"videos"];
        for (NSDictionary *dict in array) {
            DetailsModel *model=[[DetailsModel alloc]initWithDict:dict];
            [self.dataArray addObject:model];
        }
        [self.view addSubview:self.tableView];
        [self.tableView reloadData];
        
    } failed:^(NSError *error){
        if (error.code==NSURLErrorCancelled)return;
        if (error.code==NSURLErrorTimedOut){
            [self alertTitle:@"请求超时" andMessage:@""];
        }else{
            [self alertTitle:@"请求失败" andMessage:@""];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *iden=@"iden";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:iden];
    
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    DetailsModel *model=[self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text=model.title;
    
    cell.detailTextLabel.text=[NSString stringWithFormat:@"发布时间:%@",model.date];
    //NSLog(@"model.thumb:%@",model.thumb);

    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:[UIImage imageNamed:@"h1.jpg"]];

    return cell;
}
//懒加载
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
    }
    return _tableView;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
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
