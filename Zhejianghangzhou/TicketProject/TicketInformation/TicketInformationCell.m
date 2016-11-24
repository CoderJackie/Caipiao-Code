//
//  TicketInformationCell.m
//  TicketProject
//
//  Created by KAI on 15/5/7.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "TicketInformationCell.h"

#import "Globals.h"

@implementation TicketInformationCell
@synthesize title = _title;
@synthesize date = _date;
@synthesize bottomLineHidden = _bottomLineHidden;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellHeight:(CGFloat)cellHeight cellWidth:(CGFloat)cellWidth {
    _cellHeight = cellHeight;
    _cellWidth = cellWidth;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self makeSubView];
    }
    return self;
}

- (void)dealloc {
    _titleLabel = nil;
    _dateLabel = nil;
    _blackLineView = nil;
    
    [_title release];
    _title = nil;
    [_date release];
    _date = nil;
    
    [super dealloc];
}

- (void)makeSubView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat titleLabelMinX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat titleLabelMinY = IS_PHONE ? 10.0f : 15.0f;
    CGFloat titleLabelWidth = IS_PHONE ? 280.0f : 500.0f;
    
    CGFloat AllLabelHeight = IS_PHONE ? 21.0f : 30.0f;
    CGFloat labelsVerticalInterval = 0.0f;
    
    CGFloat leftSignMaginRight = IS_PHONE ? 10.0f : 20.0f;
    CGFloat leftSignWidth = IS_PHONE ? 15.0f : 22.5f;
    CGFloat leftSignHeight = IS_PHONE ? 14.0f : 21.0f;
    /********************** adjustment end ***************************/
    
    //leftSignImageView
    CGRect leftSignImageViewRect = CGRectMake(_cellWidth - leftSignMaginRight - leftSignWidth, (_cellHeight - leftSignHeight) / 2.0f , leftSignWidth, leftSignHeight);
    UIImageView *leftSignImageView = [[UIImageView alloc] initWithFrame:leftSignImageViewRect];
    [leftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
    [self.contentView addSubview:leftSignImageView];
    [leftSignImageView release];
    
    //新闻标题
    CGRect titleLabelRect = CGRectMake(titleLabelMinX, titleLabelMinY, titleLabelWidth, AllLabelHeight);
    _titleLabel = [[UILabel alloc] initWithFrame:titleLabelRect];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setHighlightedTextColor:[UIColor blackColor]];
    [_titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [self.contentView addSubview:_titleLabel];
    [_titleLabel release];
    
    //时间
    CGRect dateLabelRect = CGRectMake(CGRectGetMinX(titleLabelRect), CGRectGetMaxY(titleLabelRect) + labelsVerticalInterval, CGRectGetWidth(titleLabelRect), CGRectGetHeight(titleLabelRect));
    _dateLabel = [[UILabel alloc] initWithFrame:dateLabelRect];
    [_dateLabel setBackgroundColor:[UIColor clearColor]];
    [_dateLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [_dateLabel setHighlightedTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [_dateLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [self.contentView addSubview:_dateLabel];
    [_dateLabel release];
    
    //底线
    CGRect bottomLineRect = CGRectMake(0, _cellHeight - AllLineWidthOrHeight, _cellWidth, AllLineWidthOrHeight);
    _blackLineView = [[UIView alloc] initWithFrame:bottomLineRect];
    [_blackLineView setBackgroundColor:[UIColor lightGrayColor]];
    [_blackLineView setHidden:_bottomLineHidden];
    [self.contentView addSubview:_blackLineView];
    [_blackLineView release];
}

- (void)setTitle:(NSString *)title color:(NSString *)color {
    if (![_title isEqualToString:title]) {
        [_title release];
        _title = nil;
        _title = [title copy];
        [_titleLabel setText:_title];
        if ([color isEqualToString:@"red"]) {
            [_titleLabel setTextColor:[UIColor redColor]];
        }
    }
}

- (void)setDate:(NSString *)date {
    if (![_date isEqualToString:date]) {
        [_date release];
        _date = nil;
        _date = [date copy];
        [_dateLabel setText:_date];
    }
}

- (void)setBottomLineHidden:(BOOL)bottomLineHidden {
    if (_bottomLineHidden != bottomLineHidden) {
        _bottomLineHidden = bottomLineHidden;
        [_blackLineView setHidden:_bottomLineHidden];
    }
}

@end
