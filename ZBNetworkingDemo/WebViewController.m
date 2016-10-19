//
//  WebViewController.m
//  ZBNetworkingDemo
//
//  Created by NQ UEC on 16/10/17.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "ZBNetworking.h"
#import "ZBHTMLManager.h"
@interface WebViewController ()<UIWebViewDelegate>
@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong)WKWebView *wkWebView;
@end


@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    /**
     *  默认缓存路径/Library/Caches/AppCache/WebCache
     */
   
    int num = arc4random()%2;
    if (num) {
           //UIWebView 内存泄漏 内存会上涨
        self.title=@"UIWebView";
        self.webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:self.webView];
        
        if ([[ZBHTMLManager shareManager]diskhtmlUrl:self.weburl]==YES) {
            NSLog(@"UIWebView读缓存");
            NSString *html=[[ZBHTMLManager shareManager]htmlString:self.weburl];
            [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:self.weburl]];
        }else{
            NSLog(@"UIWebView重新请求");
            NSURL *url = [NSURL URLWithString:self.weburl];
            [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        }
    }else{
        //WKWebView  读缓存会慢一点,暂时没找到原因
         self.title=@"WKWebView";
        self.wkWebView=[[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:self.wkWebView];
        
        if ([[ZBHTMLManager shareManager]diskhtmlUrl:self.weburl]==YES) {
            NSLog(@"WKWebView读缓存");
            NSString *html=[[ZBHTMLManager shareManager]htmlString:self.weburl];
            [self.wkWebView loadHTMLString:html baseURL:[NSURL URLWithString:self.weburl]];
        }else{
            NSLog(@"WKWebView重新请求");
            NSURL *url = [NSURL URLWithString:self.weburl];
            [self.wkWebView loadRequest:[NSURLRequest requestWithURL:url]];
            
        }
    }
  
  
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.webView.delegate = nil;
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self.webView stopLoading];
    [self.webView removeFromSuperview];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self.delegate reloadData];
    
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
