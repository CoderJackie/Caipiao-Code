//
//  IntegralExchangeCollectionCell.m
//  TicketProject
//
//  Created by KAI on 15/5/11.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "IntegralExchangeCollectionCell.h"

#import "Globals.h"

@implementation IntegralExchangeCollectionCell
@synthesize photoImageName = _photoImageName;
@synthesize prompt = _prompt;
@synthesize btnTag = _btnTag;
@synthesize cellHeight = _cellHeight;
@synthesize cellWidth = _cellWidth;


- (id)init {
    self = [super init];
    if (self) {
        [self makeSubView];
    }
    return self;
}

- (void)dealloc {
    _photoImageView = nil;
    _promptLabel = nil;
    _exchangeBtn = nil;
    
    [_photoImageName release];
    _photoImageName = nil;
    [_prompt release];
    _prompt = nil;
    [super dealloc];
}

- (void)makeSubView {
    self.hasMakeSubView = YES;
    /********************** adjustment 控件调整 ***************************/
    CGFloat photoImageViewMinY = IS_PHONE ? 15.0f : 25.0f;
    CGFloat photoImageViewSize = IS_PHONE ? 60.0f : 90.0f;
    
    CGFloat promptLabelHeight = IS_PHONE ? 30.0f : 60.0f;
    
    CGFloat exchangeBtnWidth = IS_PHONE ? 80.0f : 130.0f;
    CGFloat exchangeBtnHeight = IS_PHONE ? 25.0f : 40.0f;
    /********************** adjustment end ***************************/
    
    //photoImageView
    CGRect photoImageViewRect = CGRectMake((_cellWidth - photoImageViewSize) / 2.0f, photoImageViewMinY, photoImageViewSize, photoImageViewSize);
    _photoImageView = [[UIImageView alloc] initWithFrame:photoImageViewRect];
    [_photoImageView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_photoImageView];
    [_photoImageView release];
    
    //promptLabel
    CGRect promptLabelRect = CGRectMake(0, CGRectGetMaxY(photoImageViewRect), CGRectGetWidth(self.frame), promptLabelHeight);
    _promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [_promptLabel setBackgroundColor:[UIColor clearColor]];
    [_promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_promptLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:_promptLabel];
    [_promptLabel release];
    
    //exchangeBtn
    CGRect exchangeBtnRect = CGRectMake((_cellWidth - exchangeBtnWidth) / 2.0f, CGRectGetMaxY(promptLabelRect), exchangeBtnWidth, exchangeBtnHeight);
    _exchangeBtn = [[UIButton alloc] initWithFrame:exchangeBtnRect];
    [_exchangeBtn setBackgroundColor:[UIColor clearColor]];
    [_exchangeBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_exchangeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_exchangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_exchangeBtn setTitle:@"立即兑换" forState:UIControlStateNormal];
    [_exchangeBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redLineButton.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [_exchangeBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redButton.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    [self.contentView addSubview:_exchangeBtn];
    [_exchangeBtn release];
}

- (void)setPhotoImageName:(NSString *)photoImageName {
    if (![_photoImageName isEqualToString:photoImageName]) {
        [_photoImageName release];
        _photoImageName = nil;
        _photoImageName = [photoImageName copy];
        [_photoImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:_photoImageName]]];
    }
}

- (void)setPrompt:(NSString *)prompt {
    if (![_prompt isEqualToString:prompt]) {
        [_prompt release];
        _prompt = nil;
        _prompt = [prompt copy];
        [_promptLabel setText:_prompt];
    }
}

- (void)setBtnTag:(NSInteger)btnTag {
    if (_btnTag != btnTag) {
        _btnTag = btnTag;
        [_exchangeBtn setTag:_btnTag];
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [_exchangeBtn addTarget:target action:action forControlEvents:controlEvents];
}

@end
