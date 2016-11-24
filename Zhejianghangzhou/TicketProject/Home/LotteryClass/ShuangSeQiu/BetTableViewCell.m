//
//  BetTableViewCell.m 购彩大厅-投注页面的tableViewCell
//  TicketProject
//
//  Created by sls002 on 13-5-24.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20141010 15:44（洪晓彬）：修改代码规范，改进生命周期
//20141010 15:58（洪晓彬）：进行ipad适配

#import "BetTableViewCell.h"

#import "Globals.h"
#import "MyTool.h"

#define imageLabelInterval (IS_PHONE ? 1.0 : 2.0f)


@implementation BetTableViewCell

- (id)initWithCellWidth:(CGFloat)width Height:(CGFloat)height Style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellWidth = width;
        _cellHeight = height;
        [self setBackgroundColor:[UIColor clearColor]];
        [self makeCell];
    }
    return self;
}

- (void)dealloc {
    [_betNumberString release];
    [_backImage release];
    [_betTypeString release];
    [_betCountString release];
    
    [super dealloc];
}

- (void)makeCell {
    /********************** adjustment 控件调整 ***************************/
    CGFloat backImageHeight = IS_PHONE ? 1.0f : 2.0f;
    
    CGFloat labelHeight = IS_PHONE ? 20.0f : 30.0f;
    CGFloat betTypeLabelWidth = 90.0f;
    
    CGFloat deleteBtnSize = IS_PHONE ? 18.0f : 27.0f;
    
    CGFloat lineMinX = 25.0f;
    /********************** adjustment end ***************************/
    //backImageView
    CGRect backImageViewRect = CGRectMake(0, 0, _cellWidth, _cellHeight);
    _backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
    [_backImageView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_backImageView];
    [_backImageView release];
    
    //betNumberLabel 双色label
    CGRect selectedNumberLabelRect = CGRectMake(betNumberLabelMinX, betNumberLabelMinY, _cellWidth - betNumberLabelMinX * 2 - betNumberLabelMaginRight, _cellHeight - backImageHeight - labelHeight - imageLabelInterval);
    _betNumberLabel = [[CustomLabel alloc]initWithFrame:selectedNumberLabelRect];
    [_betNumberLabel setBackgroundColor:[UIColor clearColor]];
    [_betCountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [self.contentView addSubview:_betNumberLabel];  
    [_betNumberLabel release];
    
    //selectedNumberLabel  单色label
    _selectedNumberLabel = [[UILabel alloc] initWithFrame:selectedNumberLabelRect];
    [_selectedNumberLabel setNumberOfLines:3];
    [_selectedNumberLabel setTextColor:[UIColor colorWithRed:187.0/255.0 green:48.0/255.0 blue:65.0/255.0 alpha:1.0]];
    [_selectedNumberLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_selectedNumberLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_selectedNumberLabel];
    [_selectedNumberLabel release];
    
    //betTypeLabel 玩法类型
    CGRect betTypeLabelRect = CGRectMake(betNumberLabelMinX, _cellHeight - backImageHeight - labelHeight - imageLabelInterval, betTypeLabelWidth, labelHeight);
    _betTypeLabel = [[UILabel alloc] initWithFrame:betTypeLabelRect];
    [_betTypeLabel setBackgroundColor:[UIColor clearColor]];
    [_betTypeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_betTypeLabel setTextAlignment:NSTextAlignmentLeft];
    [_betTypeLabel setTextColor:[UIColor colorWithRed:0xa0/255.0f green:0xa0/255.0f blue:0xa0/255.0f alpha:1.0f]];
    [self.contentView addSubview:_betTypeLabel];
    [_betTypeLabel release];
    
    //betCountLabel 玩法注数
    CGRect betCountLabelRect = CGRectMake(CGRectGetMaxX(betTypeLabelRect), CGRectGetMinX(betTypeLabelRect), _cellWidth / 2.0f - betNumberLabelMinX, labelHeight);
    _betCountLabel = [[UILabel alloc] initWithFrame:betCountLabelRect];
    [_betCountLabel setBackgroundColor:[UIColor clearColor]];
    [_betCountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_betCountLabel setTextAlignment:NSTextAlignmentLeft];
    [_betCountLabel setTextColor:[UIColor colorWithRed:0xa0/255.0f green:0xa0/255.0f blue:0xa0/255.0f alpha:1.0f]];
    [self.contentView addSubview:_betCountLabel];
    [_betCountLabel release];
    
    //deleteBtn
    CGRect deleteBtnRect = CGRectMake(_cellWidth - deleteBtnMaginRight - deleteBtnSize, (_cellHeight - deleteBtnSize) / 2.0f, deleteBtnSize, deleteBtnSize);
    _deleteBtn = [[UIButton alloc] initWithFrame:deleteBtnRect];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"betDeleteButton.png"]] forState:UIControlStateNormal];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"betDeleteButton.png"]] forState:UIControlStateHighlighted];
    [self.contentView addSubview:_deleteBtn];
    [_deleteBtn release];

    //lineView
    CGRect lineViewRect = CGRectMake(lineMinX, _cellHeight - AllLineWidthOrHeight, _cellWidth - lineMinX * 2, AllLineWidthOrHeight);
    _lineView = [[UIView alloc] initWithFrame:lineViewRect];
    [_lineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"pointLine.png"]]]];
    [self.contentView addSubview:_lineView];
    [_lineView release];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setBetNumberString:(NSString *)betNumberString {
    if(![betNumberString isEqual:_betNumberString]) {
        [_betNumberString release];
        _betNumberString = [betNumberString copy];
        [_betNumberLabel setAttString:[self attString:_betNumberString]];
        [_betNumberLabel setHidden:_betNumberString.length == 0];
        [_betNumberLabel setNeedsDisplay];
    }
}

- (void)setSelectedNumberString:(NSString *)selectedNumberString {
    if(![selectedNumberString isEqual:_selectedNumberString]) {
        [_selectedNumberString release];
        _selectedNumberString = [selectedNumberString copy];
        [_selectedNumberLabel setText:[self selectedNumberText:_selectedNumberString]];
        [_selectedNumberLabel setNeedsDisplay];
    }
}

- (void)setBackImage:(UIImage *)backImage {
    if(![backImage isEqual:_backImage]) {
        [_backImage release];
        _backImage = [backImage copy];
        _backImageView.image = _backImage;
        [_backImageView setNeedsDisplay];
    }
}

- (void)setBetTypeString:(NSString *)betTypeString {
    if(![betTypeString isEqual:_betTypeString]) {
        [_betTypeString release];
        _betTypeString = [betTypeString copy];
        _betTypeLabel.text = _betTypeString;
    }
}

- (void)setBetCountString:(NSString *)betCountString {
    if(![betCountString isEqual:_betCountString]) {
        [_betCountString release];
        _betCountString = [betCountString copy];
        _betCountLabel.text = _betCountString;
    }
}

- (void)backImageViewFrame:(CGRect)frame {
    [_backImageView setFrame:frame];
}

- (NSString *)selectedNumberText:(NSString *)selectNumberText {
    CGSize expectedSize = [selectNumberText sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]
                                constrainedToSize:CGSizeMake(_cellWidth - betNumberLabelMinX * 2 - betNumberLabelMaginRight - XFIponeIpadFontSize14 / 2.0f, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect selectedNumberLabelRect = _selectedNumberLabel.frame;
    [_selectedNumberLabel setFrame:CGRectMake(CGRectGetMinX(selectedNumberLabelRect), CGRectGetMinY(selectedNumberLabelRect), _cellWidth - betNumberLabelMinX * 2 - betNumberLabelMaginRight, expectedSize.height)];

    
    [self setViewFrameWithNumberLabelHeight:CGRectGetMaxY(_selectedNumberLabel.frame)];
    
    return selectNumberText;
}

- (NSAttributedString *)attString:(NSString *)betNumber {
    NSArray *array;
    if ([MyTool string:betNumber containCharacter:@"+"]) {
        array = [betNumber componentsSeparatedByString:@"+"];
    } else if ([MyTool string:betNumber containCharacter:@"-"]) {
        array = [betNumber componentsSeparatedByString:@"-"];
    } else {
        return (NSAttributedString *)@"";
    }
    if ([array count] <= 1) {
        return (NSAttributedString *)@"";;
    }
    NSString *redNumber = [array objectAtIndex:0];
    NSString *blueNumber = [array objectAtIndex:1];
    
    NSString *text = [NSString stringWithFormat:@"<font color=\"%@\">%@ </font><font color=\"%@\">%@</font>",tRedColorText,redNumber,tBlueColorText,blueNumber];
    MarkupParser *p = [[[MarkupParser alloc]init] autorelease];
    NSAttributedString *attString = [p attrStringFromMarkup:text];
    
    CGFloat betMaxWidth = _cellWidth - betNumberLabelMinX * 2 - betNumberLabelMaginRight;
    CGSize expectedSize = [attString.string sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]
                                constrainedToSize:CGSizeMake(betMaxWidth + XFIponeIpadFontSize14, NSIntegerMax) lineBreakMode:NSLineBreakByClipping];
    [_betNumberLabel setFrame:CGRectMake(betNumberLabelMinX, betNumberLabelMinY, betMaxWidth, expectedSize.height)];
    [self setViewFrameWithNumberLabelHeight:CGRectGetMaxY(_betNumberLabel.frame)];
    
    return attString;
}

- (void)setViewFrameWithNumberLabelHeight:(CGFloat)labelHight {
    CGRect betTypeLabelRect = _betTypeLabel.frame;
    [_betTypeLabel setFrame:CGRectMake(CGRectGetMinX(betTypeLabelRect), labelHight, CGRectGetWidth(betTypeLabelRect), CGRectGetHeight(betTypeLabelRect))];
    
    CGRect betCountLabelRect = _betCountLabel.frame;
    [_betCountLabel setFrame:CGRectMake(CGRectGetMinX(betCountLabelRect), labelHight, CGRectGetWidth(betCountLabelRect), CGRectGetHeight(betCountLabelRect))];
    
    CGRect backImageViewRect = _backImageView.frame;
    [_backImageView setFrame:CGRectMake(0, 0, CGRectGetWidth(backImageViewRect), CGRectGetHeight(backImageViewRect))];
}

- (void)setLineWithCellHeight:(CGFloat)cellHeight {
    CGRect lineViewRect = _lineView.frame;
    [_lineView setFrame:CGRectMake(CGRectGetMinX(lineViewRect), cellHeight - AllLineWidthOrHeight, CGRectGetWidth(lineViewRect), CGRectGetHeight(lineViewRect))];
}

- (UIButton *)getDeleteButton {
    return _deleteBtn;
}

- (void)setDeleteButtonFrameWithCellHeight:(CGFloat)height {
    //deleteBtn
    CGRect deleteBtnOriginalRect = _deleteBtn.frame;
    CGRect deleteBtnRect = CGRectMake(CGRectGetMinX(deleteBtnOriginalRect), (height - CGRectGetHeight(deleteBtnOriginalRect)) / 2.0f, CGRectGetWidth(deleteBtnOriginalRect), CGRectGetHeight(deleteBtnOriginalRect));
    [_deleteBtn setFrame:deleteBtnRect];
    [_deleteBtn setHidden:height < (IS_PHONE ? 40.0f : 70.0)];
}

@end
