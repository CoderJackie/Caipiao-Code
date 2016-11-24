//
//  CustomizedButton.m 两个label的按钮
//  TicketProject
//
//  Created by KAI on 14-11-13.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "CustomizedButton.h"
#import "Globals.h"

#pragma mark -
#pragma mark @implementation CustomizedButton
@implementation CustomizedButton
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:YES];
        _textTextColor = [[UIColor blackColor] retain];
        _oddsTextColor = [[UIColor blackColor] retain];
        _textTextSelectColor = [[UIColor blackColor] retain];
        _oddsTextSelectColor = [[UIColor blackColor] retain];
        
        [self makeSubView];
        _landscapeInterval = IS_PHONE ? 5.0f : 8.0f;
        _verticalInterval = IS_PHONE ? 0.0f : 3.0f;
        _topMagin = IS_PHONE ? 6.0f : 10.0f;
        _bottomMagin = IS_PHONE ? 4.0f : 6.0f;
        
    }
    return self;
}

- (void)dealloc {
    _textLabel = nil;
    _oddsLabel = nil;
    
    [_textString release];
    _textString = nil;
    [_oddsString release];
    _oddsString = nil;
    [_textTextColor release];
    _textTextColor = nil;
    [_textTextSelectColor release];
    _textTextSelectColor = nil;
    [_oddsTextColor release];
    _oddsTextColor = nil;
    [_oddsTextSelectColor release];
    _oddsTextSelectColor = nil;
    
    [super dealloc];
}

- (void)makeSubView {
    _textLabel = [[UILabel alloc] init];
    [_textLabel setOpaque:YES];
    [_textLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    [_textLabel setTextColor:_textTextColor];
    [self addSubview:_textLabel];
    [_textLabel release];
    
    _oddsLabel = [[UILabel alloc] init];
    [_oddsLabel setOpaque:YES];
    [_oddsLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [_oddsLabel setTextAlignment:NSTextAlignmentCenter];
    [_oddsLabel setTextColor:_oddsTextColor];
    [self addSubview:_oddsLabel];
    [_oddsLabel release];
    
    [self makeButtonFrame];
}

- (void)makeButtonLandscape {
    CGRect textLabelRect = CGRectMake(0, 0, (CGRectGetWidth(self.frame) - _landscapeInterval) / 2.0f, CGRectGetHeight(self.frame));
    [_textLabel setFrame:textLabelRect];
    [_textLabel setTextAlignment:NSTextAlignmentRight];
    
    CGRect oddsLabelRect = CGRectMake(CGRectGetMaxX(textLabelRect) + _landscapeInterval, 0, CGRectGetWidth(textLabelRect), CGRectGetHeight(self.frame));
    [_oddsLabel setFrame:oddsLabelRect];
    [_oddsLabel setTextAlignment:NSTextAlignmentLeft];
}

- (void)makeButtonVertical {
    CGRect textLabelRect = CGRectMake(0, _topMagin, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) / 2.0f - _topMagin - _verticalInterval / 2.0f);
    [_textLabel setFrame:textLabelRect];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    
    CGRect oddsLabelRect = CGRectMake(0, CGRectGetHeight(self.frame) / 2.0f + _verticalInterval / 2.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) / 2.0f - _bottomMagin - _verticalInterval / 2.0f);
    [_oddsLabel setFrame:oddsLabelRect];
    [_oddsLabel setTextAlignment:NSTextAlignmentCenter];
}

#pragma mark -AttributeMethod
- (void)setCustomizedButtonType:(CustomizedButtonType)customizedButtonType {
    if (_customizedButtonType != customizedButtonType) {
        _customizedButtonType = customizedButtonType;
        [self makeButtonFrame];
    }
}

- (void)setTextFontSize:(CGFloat)textFontSize {
    if (!(textFontSize < 0.0f || textFontSize > 100.0f)) {
        [_textLabel setFont:[UIFont systemFontOfSize:textFontSize]];
    }
}

- (void)setOddsLabelFontSize:(CGFloat)oddsLabelFontSize {
    if (!(oddsLabelFontSize < 0.0f || oddsLabelFontSize > 100.0f)) {
        [_oddsLabel setFont:[UIFont systemFontOfSize:oddsLabelFontSize]];
    }
}

- (void)setTextString:(NSString *)textString {
    if (![_textString isEqualToString:textString]) {
        [_textString release];
        _textString = [textString copy];
        [_textLabel setText:_textString];
    }
}

- (void)setOddsString:(NSString *)oddsString {
    if (![_oddsString isEqualToString:oddsString]) {
        [_oddsString release];
        _oddsString = [oddsString copy];
        [_oddsLabel setText:_oddsString];
    }
}

- (void)setTextTextColor:(UIColor *)textTextColor {
    if (![_textTextColor isEqual:textTextColor]) {
        [_textTextColor release];
        _textTextColor = [textTextColor retain];
        [_textLabel setTextColor:_textTextColor];
    }
}

- (void)setTextTextSelectColor:(UIColor *)textTextSelectColor {
    if (![_textTextSelectColor isEqual:textTextSelectColor]) {
        [_textTextSelectColor release];
        _textTextSelectColor = [textTextSelectColor retain];
    }
}

- (void)setOddsTextColor:(UIColor *)oddsTextColor {
    if (![_oddsTextColor isEqual:oddsTextColor]) {
        [_oddsTextColor release];
        _oddsTextColor = [oddsTextColor retain];
        [_oddsLabel setTextColor:_oddsTextColor];
    }
}

- (void)setOddsTextSelectColor:(UIColor *)oddsTextSelectColor {
    if (![_oddsTextSelectColor isEqual:oddsTextSelectColor]) {
        [_oddsTextSelectColor release];
        _oddsTextSelectColor = [oddsTextSelectColor retain];
    }
}

- (void)setLandscapeInterval:(CGFloat)landscapeInterval {
    if (_landscapeInterval != landscapeInterval) {
        _landscapeInterval = landscapeInterval;
        [self makeButtonFrame];
    }
}

- (void)setVerticalInterval:(CGFloat)verticalInterval {
    if (_verticalInterval != verticalInterval) {
        _verticalInterval = verticalInterval;
        [self makeButtonFrame];
    }
}

- (void)setTopMagin:(CGFloat)topMagin {
    if (_topMagin != topMagin) {
        _topMagin = topMagin;
        [self makeButtonFrame];
    }
}

- (void)setBottomMagin:(CGFloat)bottomMagin {
    if (_bottomMagin != bottomMagin) {
        _bottomMagin = bottomMagin;
        [self makeButtonFrame];
    }
}

- (void)setSelected:(BOOL)selected {
    if (_customSelfSelect != selected) {
        _customSelfSelect = selected;
        [super setSelected:selected];
        if (_customSelfSelect) {
            [_textLabel setTextColor:_textTextSelectColor];
            [_oddsLabel setTextColor:_oddsTextSelectColor];
        } else {
            [_textLabel setTextColor:_textTextColor];
            [_oddsLabel setTextColor:_oddsTextColor];
        }
    }
}

#pragma mark -
#pragma mark -Delegate

#pragma mark -
#pragma mark -Customized(Action)


#pragma mark -Customized: Private (General)
- (void)makeButtonFrame {
    if (_customizedButtonType == CustomizedButtonTypeLandscape) {
        [self makeButtonLandscape];
    } else if (_customizedButtonType == CustomizedButtonTypeVertical) {
        [self makeButtonVertical];
    }
}

@end
