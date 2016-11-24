//
//  MatchTypeButton.m
//  TicketProject
//
//  Created by KAI on 14-12-6.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "MatchTypeButton.h"

#import "Globals.h"

@implementation MatchTypeButton
@synthesize selected = _selfIsSelect;

- (id)initWithFrame:(CGRect)frame buttonType:(MatchButtonType)buttonType title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        _matchButtonType = buttonType;
        _selfIsSelect = NO;
        [self setClipsToBounds:YES];
        _title = [title copy];
        [self makeSubView];
    }
    return self;
}

- (void)dealloc {
    [_title release];
    _title = nil;
    [super dealloc];
}

- (void)makeSubView {
    /********************** adjustment 控件调整 ***************************/
    CGSize leftCheckSize = CGSizeMake(15.0f, 31.0f);
    /********************** adjustment end ***************************/
    //leftBtnImageView
    CGRect leftBtnImageViewRect = CGRectMake(0, 0, CGRectGetHeight(self.frame) / leftCheckSize.height * leftCheckSize.width , CGRectGetHeight(self.frame));
    _leftBtnImageView =[[UIImageView alloc] initWithFrame:leftBtnImageViewRect];
    [self addSubview:_leftBtnImageView];
    [_leftBtnImageView release];
    
    //rightBtnImageView
    CGRect rightBtnImageViewRect = CGRectMake(CGRectGetMaxX(leftBtnImageViewRect), 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(leftBtnImageViewRect), CGRectGetHeight(self.frame));
    _rightBtnImageView = [[UIImageView alloc] initWithFrame:rightBtnImageViewRect];
    [self addSubview:_rightBtnImageView];
    [_rightBtnImageView release];
    
    //textLabel
    CGRect textLabelRect = rightBtnImageViewRect;
    _textLabel = [[UILabel alloc] initWithFrame:textLabelRect];
    [_textLabel setBackgroundColor:[UIColor clearColor]];
    [_textLabel setText:_title];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    [_textLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [self addSubview:_textLabel];
    [_textLabel release];
    
    [self makeLeftImageSelect:NO];
    [self makeRightImageSelect:NO];
}

- (void)setSelected:(BOOL)selected {
    if (_selfIsSelect != selected) {
        _selfIsSelect = selected;
        [super setSelected:_selfIsSelect];
        [self makeLeftImageSelect:_selfIsSelect];
        [self makeRightImageSelect:_selfIsSelect];
    }
}

- (void)makeLeftImageSelect:(BOOL)select {
    if (_matchButtonType == MatchButtonTypeOfGou && select == NO) {
        [_leftBtnImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftCheck_gou.png"]]];
        
    } else if (_matchButtonType == MatchButtonTypeOfGou && select == YES) {
        [_leftBtnImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftCheck_gou_select.png"]]];
        
    } else if (_matchButtonType == MatchButtonTypeOfYuan && select == NO) {
        [_leftBtnImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftCheck_yuan.png"]]];
        
    } else {
        [_leftBtnImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftCheck_yuan_select.png"]]];
    }
}

- (void)makeRightImageSelect:(BOOL)select {
    if (!select) {
        [_rightBtnImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"rightCheck.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    } else {
        [_rightBtnImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"rightCheck_select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    }
}

@end
