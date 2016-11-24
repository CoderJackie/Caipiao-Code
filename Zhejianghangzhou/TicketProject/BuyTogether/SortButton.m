//
//  SortButton.m
//  TicketProject
//
//  Created by KAI on 14-12-3.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "SortButton.h"

#import "Globals.h"

@implementation SortButton
@synthesize title = _title;
@synthesize isAscendingOrder = _isAscendingOrder;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAdjustsImageWhenHighlighted:NO];
        [self setBackgroundImage:[[UIImage imageNamed:@"singleMatchNormalBtn.png"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowBottomLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
        [self makeButtonSubView];
    }
    return self;
}

- (void)dealloc {
    [_title release];
    [super dealloc];
}

- (void)makeButtonSubView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat bottomMagin = IS_PHONE ? 1.0f : 2.0f;
    
    CGFloat sortButtonSize = IS_PHONE ? 8.0f : 12.0f;
    /********************** adjustment end ***************************/
    //titleLabel
    CGRect titleLabelRect = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - bottomMagin);
    _titleLabel = [[UILabel alloc] initWithFrame:titleLabelRect];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_titleLabel];
    [_titleLabel release];
    
    //sortImageImageView
    CGRect sortImageImageViewRect = CGRectMake(0, (CGRectGetHeight(self.frame) - sortButtonSize - bottomMagin) / 2.0f, sortButtonSize, sortButtonSize);
    _sortImageImageView = [[UIImageView alloc] initWithFrame:sortImageImageViewRect];
    [_sortImageImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"unAscendingOrder.png"]]];
    [self addSubview:_sortImageImageView];
    [_sortImageImageView release];
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        [_title release];
        _title = [title copy];
        [_titleLabel setText:_title];
        [self changeLabelAndImageFrame];
    }
}

- (void)setIsAscendingOrder:(BOOL)isAscendingOrder {
    if (_isAscendingOrder != isAscendingOrder) {
        _isAscendingOrder = isAscendingOrder;
        [self changeSortButtonImageState];
    }
}

- (void)setSelected:(BOOL)selected {
    if (_sortButtonIsSelect != selected) {
        _sortButtonIsSelect = selected;
        [super setSelected:_sortButtonIsSelect];
        if (_sortButtonIsSelect) {
            [_titleLabel setTextColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f]];
        } else {
            [_titleLabel setTextColor:[UIColor blackColor]];
        }
        [self changeSortButtonImageState];
    }
}

- (void)changeSortButtonImageState {
    if (_sortButtonIsSelect && _isAscendingOrder) {
        [_sortImageImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"ascendingOrder_Select.png"]]];
    } else if (_sortButtonIsSelect && !_isAscendingOrder){
        [_sortImageImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"unAscendingOrder_Select.png"]]];
    } else if (!_sortButtonIsSelect && _isAscendingOrder) {
        [_sortImageImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"ascendingOrder.png"]]];
    } else {
        [_sortImageImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"unAscendingOrder.png"]]];
    }
}

- (void)changeLabelAndImageFrame {
    /********************** adjustment 控件调整 ***************************/
    CGFloat bottomMagin = IS_PHONE ? 1.0f : 2.0f;
    
    CGFloat sortImageMaginLabel = IS_PHONE ? 2.0f : 4.0f;
    CGFloat sortButtonSize = IS_PHONE ? 8.0f : 12.0f;
    /********************** adjustment end ***************************/
    CGSize titleSize = [Globals defaultSizeWithString:_title fontSize:XFIponeIpadFontSize12];
    CGRect titleLabelRect = CGRectMake((CGRectGetWidth(self.frame) - (titleSize.width - XFIponeIpadFontSize12 / 2.0f)) / 2.0f - sortImageMaginLabel - sortButtonSize, 0, titleSize.width, CGRectGetHeight(self.frame) - bottomMagin);
    [_titleLabel setFrame:titleLabelRect];
    
    CGRect sortImageImageViewRect = CGRectMake(CGRectGetMaxX(titleLabelRect) + sortImageMaginLabel, (CGRectGetHeight(self.frame) - sortButtonSize - bottomMagin) / 2.0f, sortButtonSize, sortButtonSize);
    [_sortImageImageView setFrame:sortImageImageViewRect];
}

@end
