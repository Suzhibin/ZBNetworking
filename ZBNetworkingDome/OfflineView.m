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
        
        [self addSubview:self.cancelButton];
        [self addSubview:self.progressLabel];
        [self addSubview:self.pv];
        
    }
    return self;
}
- (UIProgressView *)pv{
    if (!_pv) {
        _pv = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 5, 150, 5)];
        _pv.center = CGPointMake(200, 10);
    }
    return _pv;
    
}
- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        _cancelButton.frame=CGRectMake(10, 5, 100, 30);
        [_cancelButton setTitle:@"取消下载" forState:UIControlStateNormal];
    }
    return _cancelButton;
}

- (UILabel *)progressLabel{
    if (!_progressLabel) {
        _progressLabel=[[UILabel alloc]initWithFrame:CGRectMake(140, 20, 150, 20)];
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
