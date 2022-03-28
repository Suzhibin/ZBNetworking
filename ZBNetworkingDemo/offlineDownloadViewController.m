//
//  offlineDownloadViewController.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/9/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "offlineDownloadViewController.h"
#import "ZBNetworking.h"
#import "HomeModel.h"

@interface offlineDownloadViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)NSMutableArray *offlineArray;
@end

@implementation offlineDownloadViewController

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray=[[NSMutableArray alloc]init];
    
    [self.view addSubview:self.tableView];
  
    [self addItemWithTitle:@"离线下载" selector:@selector(offlineBtnClick) location:NO];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"path"] = @"offlineDownloadViewController";

    //请求最新频道列表 ZBApiType 默认ZBRequestTypeRefresh 重新请求 也不会存储缓存
    [ZBRequestManager requestWithConfig:^(ZBURLRequest *request) {
//        request.server=url_server;
        request.url=[NSString stringWithFormat:@"%@%@",url_server,url_path];
        request.parameters=parameters;
    } success:^(id responseObject,ZBURLRequest *request) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSArray *array=[dict objectForKey:@"authors"];
            
            for (NSDictionary *dic in array) {
                HomeModel *model=[[HomeModel alloc]init];
//                model.name=[dic objectForKey:@"name"];
//                model.wid=[dic objectForKey:@"id"];
                [self.dataArray addObject:model];
                
            }
            [self.tableView reloadData];
        }
    
    } failure:nil];
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
    
    HomeModel *model=[self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text=model.title;
    
    return cell;
}
- (void)switchValueChanged:(UISwitch *)sw{
    HomeModel *model=[self.dataArray objectAtIndex:sw.tag];
   
    if (sw.isOn == YES) {
        //添加请求列队
        if ([self.offlineArray containsObject:model]==NO) {
             [self.offlineArray addObject:model];
        }
    }else{
        //删除请求列队
        if ([self.offlineArray containsObject:model]==YES) {
             [self.offlineArray removeObject:model];
        }
    }
}

- (void)offlineBtnClick{
    
    if (self.offlineArray.count==0) {
        
        [self alertTitle:@"请添加栏目" andMessage:@"" completed:nil];
        
    }else{
       
        NSLog(@"离线请求的栏目/url个数:%lu",self.offlineArray.count);
    
        for (HomeModel *model in self.offlineArray) {
            NSLog(@"离线请求的name:%@",model.title);
        }
        if ([self.delegate respondsToSelector:@selector(downloadWithArray:)]){
               [self.delegate downloadWithArray:self.offlineArray];
        }
        
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
- (NSMutableArray *)offlineArray{
    if (!_offlineArray) {
        _offlineArray=[[NSMutableArray alloc]init];
    }
    return _offlineArray;
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
