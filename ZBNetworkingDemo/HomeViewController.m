//
//  HomeViewController.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/8/24.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "HomeViewController.h"
#import "SecondViewController.h"
#import "ZBNetworking.h"
@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *titleArr=[NSArray arrayWithObjects:@"AFNetworking",@"NSURLSessionBlock",@"NSURLSessionDelegate", nil];
    for (int i=0; i<titleArr.count; i++) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(30,150+i*80,SCREEN_WIDTH-60, 40);
        btn.backgroundColor=[UIColor blackColor];
        [btn setTitle:[titleArr objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.tag=i+100;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
  
}
- (void)btnClicked:(UIButton *)sender{
    SecondViewController *secondVC=[[SecondViewController alloc]init];
    switch (sender.tag) {
        case 100:
            secondVC.functionType=AFNetworking;
            [self.navigationController pushViewController:secondVC animated:YES];
            break;
        case 101:
            secondVC.functionType=sessionblock;
            [self.navigationController pushViewController:secondVC animated:YES];
            break;
        case 102:
            secondVC.functionType=sessiondelegate;
            [self.navigationController pushViewController:secondVC animated:YES];
            break;
        default:
            break;
    }
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
