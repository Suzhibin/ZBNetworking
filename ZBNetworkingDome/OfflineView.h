//
//  OfflineView.h
//  ZBNetworkingDome
//
//  Created by NQ UEC on 16/9/26.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfflineView : UIView
@property (nonatomic,strong)UIProgressView *pv;
@property (nonatomic,strong)UILabel *progressLabel;
@property (nonatomic,strong)UIButton *cancelButton;
@property (nonatomic,strong)UIView *bjView;

- (void)hide;
@end
