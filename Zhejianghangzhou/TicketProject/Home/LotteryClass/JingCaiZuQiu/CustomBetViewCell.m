//
//  CustomBetViewCell.m 购彩大厅－竞彩投注cell
//  TicketProject
//
//  Created by sls002 on 13-7-1.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20141013 09:27（洪晓彬）：修改代码规范
//  20141013 09:47（洪晓彬）：进行ipad适配
//  20150727 11:15（刘科）：适配iPhone各种型号。

#import "CustomBetViewCell.h"
#import "Globals.h"

#pragma mark -
#pragma mark @implementation CustomBetViewCell
@implementation CustomBetViewCell
@synthesize oneLabel = _oneLabel;
@synthesize twoLabel = _twoLabel;
#pragma mark Lifecircle

- (id)initWithHeihgt:(CGFloat)height style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _seltHeight = height;
        [self makeCell];
    }
    return self;
}

- (void)makeCell {
    /********************** adjustment 控件调整 ***************************/
    CGFloat firstRowFirstLabelMinX = IS_PHONE ? 19.0f : 80.0f;
    CGFloat firstRowLabelMinY = IS_PHONE ? 7.0f : 12.0f;
    CGFloat firstRowLabelWidth = IS_PHONE ? 100.0f : 190.0f;
    CGFloat firstRowCenterLabelWidth = 25.0f;
    CGFloat firstRowLabelLandscapeInterval = IS_PHONE ? 0.0f : 15.0f;
    CGFloat allLabelHeight = IS_PHONE ? 21.0f : 30.0f;
    
    CGFloat firstColLabelMinX = IS_PHONE ? 27.0f : 40.0f;
    CGFloat firstColLabelWidth = IS_PHONE ? 21.0f : 30.0f;
    CGFloat firstColLabelVerticalInterval = IS_PHONE ? 4.0f : 8.0f;
    
    CGFloat lineMinX = 25.0f;
    /********************** adjustment end ***************************/
    //backImageView
    CGRect backImageViewRect = CGRectMake(0, 0, kWinSize.width, _seltHeight);
    _backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
    [_backImageView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_backImageView];
    [_backImageView release];
    
    //mainTeamLabel
    CGRect mainTeamLabelRect = CGRectMake(firstRowFirstLabelMinX, firstRowLabelMinY, kWinSize.width / 2 - firstRowFirstLabelMinX - 10, allLabelHeight);
    _mainTeamLabel = [[UILabel alloc] initWithFrame:mainTeamLabelRect];
    [_mainTeamLabel setBackgroundColor:[UIColor clearColor]];
    [_mainTeamLabel setTextAlignment:NSTextAlignmentRight];
    [_mainTeamLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [self.contentView addSubview:_mainTeamLabel];
    [_mainTeamLabel release];
    
    //letBallLabel
    CGRect letBallLabelRect = CGRectMake(CGRectGetMaxX(mainTeamLabelRect) + firstRowLabelLandscapeInterval, firstRowLabelMinY, firstRowCenterLabelWidth, allLabelHeight);
    _letBallLabel = [[UILabel alloc] initWithFrame:letBallLabelRect];
    [_letBallLabel setBackgroundColor:[UIColor clearColor]];
    [_letBallLabel setTextAlignment:NSTextAlignmentCenter];
    [_letBallLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_letBallLabel setMinimumScaleFactor:0.5];
    [_letBallLabel setAdjustsFontSizeToFitWidth:YES];
    [self.contentView addSubview:_letBallLabel];
    [_letBallLabel release];
    
    //guestTeamLabel
    CGRect guestTeamLabelRect = CGRectMake(CGRectGetMaxX(letBallLabelRect) + firstRowLabelLandscapeInterval, firstRowLabelMinY, firstRowLabelWidth, allLabelHeight);
    _guestTeamLabel = [[UILabel alloc] initWithFrame:guestTeamLabelRect];
    [_guestTeamLabel setBackgroundColor:[UIColor clearColor]];
    [_guestTeamLabel setTextAlignment:NSTextAlignmentLeft];
    [_guestTeamLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [self.contentView addSubview:_guestTeamLabel];
    [_guestTeamLabel release];
    
    //oneLabel
    CGRect oneLabelRect = CGRectMake(firstColLabelMinX, CGRectGetMaxY(guestTeamLabelRect) + firstColLabelVerticalInterval, firstColLabelWidth, allLabelHeight);
    _oneLabel = [[UILabel alloc] initWithFrame:oneLabelRect];
    [_oneLabel setBackgroundColor:[UIColor clearColor]];
    [_oneLabel setTextAlignment:NSTextAlignmentLeft];
    [_oneLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize17]];
    [self.contentView addSubview:_oneLabel];
    [_oneLabel release];
    
    //twoLabel
    CGRect twoLabelRect =CGRectMake(firstColLabelMinX, CGRectGetMaxY(oneLabelRect) + firstColLabelVerticalInterval, firstColLabelWidth, allLabelHeight);
    _twoLabel = [[UILabel alloc] initWithFrame:twoLabelRect];
    [_twoLabel setBackgroundColor:[UIColor clearColor]];
    [_twoLabel setTextAlignment:NSTextAlignmentCenter];
    [_twoLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize17]];
    [self.contentView addSubview:_twoLabel];
    [_twoLabel release];
    
    //lineView
    CGRect lineViewRect = CGRectMake(lineMinX, _seltHeight - AllLineWidthOrHeight, kWinSize.width - lineMinX * 2, AllLineWidthOrHeight);
    UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
    [lineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"pointLine.png"]]]];
    [self.contentView addSubview:lineView];
    [lineView release];
}

- (void)dealloc {
    _mainTeamLabel = nil;
    _letBallLabel = nil;
    _guestTeamLabel = nil;
    _oneLabel = nil;
    _twoLabel = nil;
    
    [_mainTeamName release];
    _mainTeamName = nil;
    [_guestTeamName release];
    _guestTeamName = nil;
    [_letBall release];
    _letBall = nil;
    [super dealloc];
}

- (void)setBackImage:(UIImage *)backImage {
    if(![backImage isEqual:_backImage]) {
        [_backImage release];
        _backImage = [backImage copy];
        _backImageView.image = _backImage;
        [_backImageView setNeedsDisplay];
    }
}


#pragma mark -
#pragma mark -Customized(Action)
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -Customized: Private (General)
- (void)setMainTeamName:(NSString *)mainTeamName {
    if(![mainTeamName isEqualToString:_mainTeamName]) {
        [_mainTeamName release];
        _mainTeamName = [mainTeamName copy];

        [_mainTeamLabel setText:_mainTeamName];
    }
}

- (void)setGuestTeamName:(NSString *)guestTeamName {
    if(![guestTeamName isEqualToString:_guestTeamName]) {
        [_guestTeamName release];
        _guestTeamName = [guestTeamName copy];
        
        [_guestTeamLabel setText:_guestTeamName];
    }
}

- (void)setLetBall:(NSString *)mainLoseBall {
    if(![mainLoseBall isEqualToString:_letBall]) {
        [_letBall release];
        _letBall = [mainLoseBall copy];
        if ([_letBall integerValue] > 0) {
            [_letBallLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
        } else if ([_letBall integerValue] < 0) {
            [_letBallLabel setTextColor:[UIColor colorWithRed:0x1a/255.0f green:0xaf/255.0f blue:0x3c/255.0f alpha:1.0f]];
        } else {
            [_letBallLabel setTextColor:[UIColor colorWithRed:0x80/255.0f green:0x80/255.0f blue:0x80/255.0f alpha:1.0f]];
        }
        _letBallLabel.text = _letBall;
    }
}

@end
