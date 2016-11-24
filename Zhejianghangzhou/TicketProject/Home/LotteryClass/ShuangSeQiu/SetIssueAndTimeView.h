//
//  SetIssueAndTimeView.h
//  TicketProject
//
//  Created by sls002 on 13-5-23.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectBallsDetailViewControllerDelegate.h"

@interface SetIssueAndTimeView : UIView<UITextFieldDelegate,UIGestureRecognizerDelegate> {
    
    UIView      *_superView;
    UIView      *_chaseView;
    UIView      *_overlayView;
    UITextField *_issueField;
    UITextField *_timesField;
    
    NSInteger    _totalChaseCount;
    NSString    *_targetText;
    NSArray     *_listArray;
    
    BOOL         _isDLT;     // 是否是大乐透，如果是，则需要增加追号投注功能
    BOOL         _hasWinStopView;
    
    id<SelectBallsDetailViewControllerDelegate> _delegate;
}

@property (nonatomic,assign) NSInteger chase;       // 追的期数
@property (nonatomic,assign) NSInteger multiple;    // 倍数
@property (nonatomic,assign) BOOL isZhuiQiStop;     // 是否中奖后停止追号
@property (nonatomic,assign) BOOL isZhuiHao;        // 是否追号投注

@property (nonatomic,assign) id<SelectBallsDetailViewControllerDelegate> delegate;

- (id)initWithFrame:(CGRect)frame superView:(UIView *)view isDLT:(BOOL)flag hasWinStopView:(BOOL)hasWinStopView;

- (void)tapResignKeyboard:(UITapGestureRecognizer *)tapGesture;

@end
