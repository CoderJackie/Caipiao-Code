//
//  CustomSwitchView.m    自定义选项条
//  TicketProject
//
//  Created by sls002 on 13-6-21.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "CustomSwitchView.h"
#import "Globals.h"

@implementation CustomSwitchView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)items {
    self = [super initWithFrame:frame];
    if (self) {
        _switchItems = [items retain];
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    CGFloat itemWidth = CGRectGetWidth(self.frame) / _switchItems.count;
    CGSize btnSize = CGSizeMake(itemWidth, self.bounds.size.height);
    
    for (NSInteger i = 0; i < _switchItems.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(i * btnSize.width, 0, btnSize.width, btnSize.height)];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:0xfd/255.0 green:0xae/255.0f blue:0x24/255.0f alpha:1.0f] forState:UIControlStateSelected];
        [btn setTitle:[_switchItems objectAtIndex:i] forState:UIControlStateNormal];
        [btn setShowsTouchWhenHighlighted:YES];
        [btn setBackgroundImage:[[UIImage imageNamed:@"singleMatchNormalBtn.png"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
        [btn setTag:i + 1];
        [btn setSelected:i == 0];
        [btn addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    
    _switchImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 3, btnSize.width, 3)];
    [_switchImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]]];
    [self addSubview:_switchImageView];
}

- (void)itemSelected:(id)sender {
    UIButton *btn = sender;
    for (UIButton *btns in self.subviews) {
        if ([btns isKindOfClass:[UIButton class]]) {
            [btns setSelected:NO];
        }
    }
    [btn setSelected:YES];
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [_switchImageView setFrame:CGRectMake(CGRectGetMinX(btn.frame), self.bounds.size.height - 3, CGRectGetWidth(btn.frame), 3)];
    [UIView commitAnimations];
    
    if ([_delegate respondsToSelector:@selector(switchItemDidSelectedAtIndex:)]) {
        [_delegate switchItemDidSelectedAtIndex:btn.tag];
    }
}

- (void)selectBtnIndex:(NSInteger)index {
    for (UIButton *btns in self.subviews) {
        if ([btns isKindOfClass:[UIButton class]]) {
            if (btns.tag == index) {
                [btns setSelected:YES];
                [UIView beginAnimations:@"Curl" context:nil];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                [_switchImageView setFrame:CGRectMake(CGRectGetMinX(btns.frame), self.bounds.size.height - 3, CGRectGetWidth(btns.frame), 3)];
                [UIView commitAnimations];
            } else {
                [btns setSelected:NO];
            }
        }
    }
}

- (void)dealloc {
    [_switchImageView release];
    _switchImageView = nil;
    [_switchItems release];
    _switchItems = nil;
    
    [super dealloc];
}


@end
