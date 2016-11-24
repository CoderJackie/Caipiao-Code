//
//  WinPopubView.h
//  TicketProject
//
//  Created by KAI on 15-1-19.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WinPopubViewDelegate.h"

@interface WinPopubView : UIView <UIGestureRecognizerDelegate>{
    UIView      *_overlayView;
    UIImageView *_winPopubBackImageView;
    UILabel     *_winMoneyLabel;
    
    id<WinPopubViewDelegate> _delegate;
    
    NSString    *_winMoney;
}

@property (nonatomic ,assign)id<WinPopubViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame winMoney:(NSString *)winMoney;

- (void)show;

@end
