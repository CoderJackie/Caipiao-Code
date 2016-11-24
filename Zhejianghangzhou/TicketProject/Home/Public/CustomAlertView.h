//
//  CustomAlertView.h
//  TicketProject
//
//  Created by KAI on 14-11-27.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewDelegate.h"


@class CustomAlertView;

@interface CustomAlertView : UIView {
    UIView       *_overlayView;
    
    UILabel      *_titleLabel;
    UIButton     *_bottomLeftBtn;
    UIButton     *_bottomRightBtn;
    
    id<CustomAlertViewDelegate> _delegate;
    
    UIView       *_secondBackView;
    UIView       *_redLineView;
    NSString     *_title;
    NSString     *_content;
    NSString     *_leftBtnText;
    NSString     *_rightBtnText;
    CGFloat       _aroundShadowViewWidth;
    CGFloat       _aroundShadowViewHeight;
    CGFloat       _contrastHeight;
    BOOL          _customView;
}

@property (nonatomic, retain) UIView *secondBackView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIView *redLineView;
@property (nonatomic, assign) id<CustomAlertViewDelegate> delegate;

- (id)initWithTitle:(NSString *)title delegate:(id<CustomAlertViewDelegate>)delegate content:(NSString *)content leftText:(NSString *)leftText rightText:(NSString *)rightText;

- (id)initWithTitle:(NSString *)title delegate:(id<CustomAlertViewDelegate>)delegate content:(NSString *)content;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title delegate:(id<CustomAlertViewDelegate>)delegate;

- (void)show;

@end
