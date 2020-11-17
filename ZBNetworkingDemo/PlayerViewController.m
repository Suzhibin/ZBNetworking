//
//  PlayerViewController.m
//  ZBNetworkingDemo
//
//  Created by Suzhibin on 2020/11/10.
//  Copyright © 2020 Suzhibin. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@interface PlayerViewController ()<AVPlayerViewControllerDelegate>{
    AVPlayerViewController      *_playerController;
    AVPlayer                    *_player;
}
@end

@implementation PlayerViewController
- (void)dealloc{
    NSLog(@"释放%s",__func__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _player = [AVPlayer playerWithURL:[NSURL URLWithString:self.videoUrl]];
    _playerController = [[AVPlayerViewController alloc] init];
    _playerController.player = _player;
    _playerController.videoGravity = AVLayerVideoGravityResizeAspect;
    _playerController.delegate = self;
    _playerController.allowsPictureInPicturePlayback = true;    //画中画，iPad可用
    _playerController.showsPlaybackControls = true;
    
    [self addChildViewController:_playerController];
    _playerController.view.translatesAutoresizingMaskIntoConstraints = true;    //AVPlayerViewController 内部可能是用约束写的，这句可以禁用自动约束，消除报错
    _playerController.view.frame = self.view.bounds;
    [self.view addSubview:_playerController.view];
    
    [_playerController.player play];    //自动播放
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
