//
//  RootViewController.m
//  ZBNetworking
//
//  Created by NQ UEC on 16/6/21.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "RootViewController.h"


@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];

}

- (void)addItemWithTitle:(NSString *)title selector:(SEL)selector location:(BOOL)isLeft{
    
    UIBarButtonItem *item =[[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStylePlain  target:self action:selector];
    
    if (isLeft == YES) {
        //左
        self.navigationItem.leftBarButtonItem = item;
    }else{
        //右边
        self.navigationItem.rightBarButtonItem = item;
    }
    
}
- (void)customItemWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle selector:(SEL)selector location:(BOOL)isLeft{
     UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [itemBtn setFrame:CGRectMake(0, 0, 100, 44)];
    [itemBtn setTitle:title forState:UIControlStateNormal];
    [itemBtn setTitle:selectedTitle forState:UIControlStateSelected];
    [itemBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [itemBtn setTitleColor:[UIColor colorWithRed:0.09f green:0.52f blue:1.00f alpha:1.00f] forState:UIControlStateSelected];
    [itemBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];

        UIBarButtonItem * rightBtnItem =[[UIBarButtonItem alloc] initWithCustomView: itemBtn];
         if (isLeft == YES) {
              //左
              self.navigationItem.leftBarButtonItem = rightBtnItem;
          }else{
              //右边
              self.navigationItem.rightBarButtonItem = rightBtnItem;
          }
}
- (void)alertTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
