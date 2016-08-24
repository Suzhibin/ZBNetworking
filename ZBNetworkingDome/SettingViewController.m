//
//  SettingViewController.m
//  ZBNetworkingDome
//
//  Created by NQ UEC on 16/8/24.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "SettingViewController.h"
#import "ZBNetworking.h"
@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    [self.view addSubview:self.tableView];

}
#pragma mark - UITableView dataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIde=@"cellIde";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIde];
    }
    if (indexPath.row==0) {
        cell.textLabel.text=@"清除缓存";
        
        float size=[[ZBCacheManager shareCacheManager]getFileSize];
        size=size/1000.0f/1000.0f;
        if (size>0) {
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%.2fM",size];
        }else{
            cell.detailTextLabel.text=@"0M";
            
        }
        
        
    }
    if (indexPath.row==1) {
        cell.textLabel.text=@"缓存文件数量";
        
        float count=[[ZBCacheManager shareCacheManager]getFileCount];
        
        cell.detailTextLabel.text= [NSString stringWithFormat:@"%.f",count];
        
        
    }
    
    
    return cell;
}
#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row==0) {
        
        [[NSURLCache sharedURLCache]removeAllCachedResponses];
        
        //删除ZBCache 缓存
        [[ZBCacheManager shareCacheManager]clearDiskOnOperation:^{
            [[ZBCacheManager shareCacheManager]getFileSize];
            [_tableView reloadData];
            [self alertTitle:@"" andMessage:@"缓存已删除"];
        }];
        
        
        
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
