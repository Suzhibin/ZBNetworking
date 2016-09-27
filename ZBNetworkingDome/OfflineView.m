//
//  OfflineView.m
//  ZBNetworkingDome
//
//  Created by NQ UEC on 16/9/26.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "OfflineView.h"
@interface OfflineView()

@end

@implementation OfflineView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // self.backgroundColor=[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1.0];
        
        self.backgroundColor=[[UIColor colorWithRed:0.60f green:0.60f blue:0.60f alpha:1.00f] colorWithAlphaComponent:0.5];
        
        [self addSubview:self.bjView];
        [self.bjView addSubview:self.cancelButton];
        [self.bjView addSubview:self.progressLabel];
        [self.bjView addSubview:self.pv];
        
    }
    return self;
}

- (void)hide
{
    [UIView animateWithDuration:0.50 animations:^{
        self.alpha = 0.0f;
    
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
  
    }];
}

- (UIView *)bjView
{
    if (!_bjView) {
        _bjView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,self.frame.size.width, 64)];
        _bjView.backgroundColor=[UIColor whiteColor];
    }
    return _bjView;

}
- (UIProgressView *)pv{
    if (!_pv) {
        _pv = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 30, 150, 5)];
        _pv.center = CGPointMake(200, 30);
    }
    return _pv;
    
}
- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        _cancelButton.frame=CGRectMake(10, 30, 100, 30);
        [_cancelButton setTitle:@"取消下载" forState:UIControlStateNormal];
    }
    return _cancelButton;
}

- (UILabel *)progressLabel{
    if (!_progressLabel) {
        _progressLabel=[[UILabel alloc]initWithFrame:CGRectMake(140, 40, 150, 20)];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
    
    }
    return _progressLabel;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
