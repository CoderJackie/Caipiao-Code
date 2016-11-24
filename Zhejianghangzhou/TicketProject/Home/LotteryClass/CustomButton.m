//
//  CustomButton.m
//  TicketProject
//
//  Created by sls002 on 14-3-5.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "CustomButton.h"
#import "Globals.h"

@implementation CustomButton
@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize customBtnSelect = _customBtnSelect;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:kRedColor forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setTitleColor:kRedColor forState:UIControlStateSelected | UIControlStateHighlighted];
        
        [self setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redLineButton.png"]] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redButton.png"]] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redButton.png"]] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateSelected];
        [self setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redLineButton.png"]] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateSelected | UIControlStateHighlighted];
        _normalTitleColor = [kRedColor retain];
        _normalSubTitleColor = [[UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f] retain];
        
        _selectTitleColor = [[UIColor whiteColor] retain];
        _selectSubTitleColor = [[UIColor whiteColor] retain];
        
        _highlightTitleColor = [[UIColor whiteColor] retain];
        _highlightSubTitleColor = [[UIColor whiteColor] retain];
        
        _highlightSelectTitleColor = [kRedColor retain];
        _highlightSelectSubTitleColor = [[UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f] retain];
        
        _customBtnSelect = NO;
        
        [self makeSubView];
    }
    return self;
}

- (void)dealloc {
    _titleLabel = nil;
    _subTitleLabel = nil;
    
    [_title release];
    _title = nil;
    [_subTitle release];
    _subTitle = nil;
    
    [_normalTitleColor release];
    _normalTitleColor = nil;
    [_selectTitleColor release];
    _selectTitleColor = nil;
    [_normalSubTitleColor release];
    _normalSubTitleColor = nil;
    [_selectSubTitleColor release];
    _selectSubTitleColor = nil;
    [_highlightTitleColor release];
    _highlightTitleColor = nil;
    [_highlightSubTitleColor release];
    _highlightSubTitleColor = nil;
    [_highlightSelectTitleColor release];
    _highlightSelectTitleColor = nil;
    [_highlightSelectSubTitleColor release];
    _highlightSelectSubTitleColor = nil;
    [super dealloc];
}

- (void)makeSubView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat titleMaginY = 5.0f;
    /********************** adjustment end ***************************/
    
    //titleLabel
    CGRect titleLabelRect = CGRectMake(0, titleMaginY, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) / 2 - titleMaginY);
    _titleLabel = [[UILabel alloc] initWithFrame:titleLabelRect];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setTextColor:_normalTitleColor];
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize16]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_titleLabel];
    [_titleLabel release];
    
    //subTitleLabel
    CGRect subTitleLabelRect = CGRectMake(0, CGRectGetMaxY(titleLabelRect), CGRectGetWidth(titleLabelRect), CGRectGetHeight(titleLabelRect));
    _subTitleLabel = [[UILabel alloc] initWithFrame:subTitleLabelRect];
    [_subTitleLabel setBackgroundColor:[UIColor clearColor]];
    [_subTitleLabel setTextColor:_normalSubTitleColor];
    [_subTitleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_subTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_subTitleLabel];
    [_subTitleLabel release];
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        [_title release];
        _title = [title copy];
        [_titleLabel setText:_title];
    }
}

- (void)setSubTitle:(NSString *)subTitle {
    if (![_subTitle isEqualToString:subTitle]) {
        [_subTitle release];
        _subTitle = [subTitle copy];
        [_subTitleLabel setText:_subTitle];
    }
}

- (void)setCustomBtnSelect:(BOOL)customBtnSelect {
    if (_customBtnSelect != customBtnSelect) {
        _customBtnSelect = customBtnSelect;
        [super setSelected:_customBtnSelect];
        if (_customBtnSelect) {
            [_titleLabel setTextColor:_selectTitleColor];
            [_subTitleLabel setTextColor:_selectSubTitleColor];
        } else {
            [_titleLabel setTextColor:_normalTitleColor];
            [_subTitleLabel setTextColor:_normalSubTitleColor];
        }
    }
}

- (void)setCustomTitleColor:(UIColor *)color forState:(UIControlState)state {
    if (state == UIControlStateNormal && ![_normalTitleColor isEqual:color]) {
        [_normalTitleColor release];
        _normalTitleColor = [color retain];
        if (!_customBtnSelect) {
            [_titleLabel setTextColor:_normalTitleColor];
        }
    } else if (state == UIControlStateSelected && ![_selectTitleColor isEqual:color]) {
        [_selectTitleColor release];
        _selectTitleColor = [color retain];
        if (_customBtnSelect) {
            [_titleLabel setTextColor:_selectTitleColor];
        }
    } else if (state == UIControlStateHighlighted && ![_highlightTitleColor isEqual:color]) {
        [_highlightTitleColor release];
        _highlightTitleColor = [color retain];
        
    } else if (state == (UIControlStateSelected | UIControlStateHighlighted) && ![_highlightTitleColor isEqual:color]) {
        [_highlightSelectTitleColor release];
        _highlightSelectTitleColor = [color retain];
        
    }
}

- (void)setCustomSubTitleColor:(UIColor *)color forState:(UIControlState)state {
    if (state == UIControlStateNormal && ![_normalSubTitleColor isEqual:color]) {
        [_normalSubTitleColor release];
        _normalSubTitleColor = [color retain];
        if (!_customBtnSelect) {
            [_subTitleLabel setTextColor:_normalTitleColor];
        }
    } else if (state == UIControlStateSelected && ![_selectSubTitleColor isEqual:color]) {
        [_selectSubTitleColor release];
        _selectSubTitleColor = [color retain];
        if (_customBtnSelect) {
            [_subTitleLabel setTextColor:_selectSubTitleColor];
        }
    } else if (state == UIControlStateHighlighted && ![_highlightSubTitleColor isEqual:color]) {
        [_highlightSubTitleColor release];
        _highlightSubTitleColor = [color retain];
        
    } else if (state == (UIControlStateSelected | UIControlStateHighlighted) && ![_highlightSelectSubTitleColor isEqual:color]) {
        [_highlightSelectSubTitleColor release];
        _highlightSelectSubTitleColor = [color retain];
        
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (_customBtnSelect) {
        [_titleLabel setTextColor:_highlightSelectTitleColor];
        [_subTitleLabel setTextColor:_highlightSelectSubTitleColor];
    } else {
        [_titleLabel setTextColor:_highlightTitleColor];
        [_subTitleLabel setTextColor:_highlightSubTitleColor];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    [super touchesMoved:touches withEvent:event];
    if (touchLocation.x > -70.0f && touchLocation.x <= (CGRectGetWidth(self.frame) + 70.0f) && touchLocation.y > -70.0f && touchLocation.y <= (CGRectGetHeight(self.frame) + 70.0f)) {
        if (_customBtnSelect) {
            [_titleLabel setTextColor:_highlightSelectTitleColor];
            [_subTitleLabel setTextColor:_highlightSelectSubTitleColor];
        } else {
            [_titleLabel setTextColor:_highlightTitleColor];
            [_subTitleLabel setTextColor:_highlightSubTitleColor];
        }
    } else {
        if (_customBtnSelect) {
            [_titleLabel setTextColor:_selectTitleColor];
            [_subTitleLabel setTextColor:_selectSubTitleColor];
        } else {
            [_titleLabel setTextColor:_normalTitleColor];
            [_subTitleLabel setTextColor:_normalSubTitleColor];
        }
    }
    
}

@end
