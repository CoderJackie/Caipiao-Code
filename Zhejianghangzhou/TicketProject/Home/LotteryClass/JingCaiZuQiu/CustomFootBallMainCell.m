//
//  CustomFootBallMainCell.m
//  TicketProject
//
//  Created by sls002 on 13-6-26.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//胜平负
//20140927 10:00（洪晓彬）：修改代码规范，改进生命周期
//20140927 10:10（洪晓彬）：进行ipad适配

#import "CustomFootBallMainCell.h"

#import "Globals.h"

#define fisrtColLabelMinX 9.0f
#define fisrtColLabelWidth (IS_PHONE ? 57.0f : 100.0f)
#define firstColLabelHeight (IS_PHONE ? 16.0f : 25.0f)
#define firstColLabelVerticalInterval ( IS_PHONE ? 0.0f : 5.0f)

#define lineImageViewLabelLandscape (IS_PHONE ?  11.0f : 20.0f)
#define lineImageViewWidth 4.0f

#define buttonImageViewCutY (IS_PHONE ? 5.0f : 10.0f)

#pragma mark -
#pragma mark @implementation CustomFootBallMainCell
@implementation CustomFootBallMainCell
@synthesize cellHight = _cellHight;
#pragma mark Lifecircle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeCell];
        _boldmainLoseBallLabel = NO;
    }
    return self;
}

- (id)initWithCellHight:(CGFloat)hight reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellHight = hight;
        _boldmainLoseBallLabel = NO;
        [self makeCell];
    }
    return self;
}

- (void)dealloc {
    [_matchNO release];
    [_gameName release];
    [_matchDate release];
    [_mainTeam release];
    [_guestTeam release];
    [_mainLoseBall release];
    
    [super dealloc];
}

- (void)makeCell {
    /********************** adjustment 控件调整 ***************************/
    CGFloat firstRowLabelMinY = IS_PHONE ? 3.0f : 6.0f;
    CGFloat firstRowLabelHight = IS_PHONE ? 21.0f : 30.0f;
    CGFloat firstRowLabelLandscapeInterval = 10.0f;
    CGFloat buttonImageViewIntervalRight = IS_PHONE ? 12.0f : 24.0f;
    
    CGFloat secondColLabelWidht = IS_PHONE ? 13.0f : 24.0f;
    CGFloat secondColLabelHeight = IS_PHONE ? 28.0f : 35.0f;
    CGFloat secondColLabelVerticalInterval = IS_PHONE ? 0.0f : 3.0f;
    
    CGFloat mainLoseBallLabelWidth = IS_PHONE ? 40.0f : 80.0f;
    /********************** adjustment end ***************************/
    CGRect backImageViewRect = CGRectMake(0, 0, kWinSize.width, _cellHight);
    _backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
    [_backImageView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_backImageView];
    [_backImageView release];
    
    //lineView
    CGRect lineViewRect = CGRectMake(0, _cellHight - AllLineWidthOrHeight, kWinSize.width, AllLineWidthOrHeight);
    _lineView = [[UIView alloc] initWithFrame:lineViewRect];
    [_lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
    [self addSubview:_lineView];
    [_lineView release];
    
    //matchNOLabel
    CGRect matchNOLabelRect = CGRectMake(fisrtColLabelMinX, (_cellHight - firstColLabelVerticalInterval * 2 - firstColLabelHeight * 3) / 2.0f, fisrtColLabelWidth, firstColLabelHeight);
    _matchNOLabel = [[UILabel alloc] initWithFrame:matchNOLabelRect];
    [_matchNOLabel setBackgroundColor:[UIColor clearColor]];
    [_matchNOLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [_matchNOLabel setTextColor:[UIColor colorWithRed:0x90/255.0 green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
    [_matchNOLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_matchNOLabel];
    [_matchNOLabel release];
    
    //gameNameLabel
    CGRect gameNameLabelRect = CGRectMake(fisrtColLabelMinX, CGRectGetMaxY(matchNOLabelRect) + firstColLabelVerticalInterval, fisrtColLabelWidth, firstColLabelHeight);
    _gameNameLabel = [[UILabel alloc] initWithFrame:gameNameLabelRect];
    [_gameNameLabel setBackgroundColor:[UIColor clearColor]];
    [_gameNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_gameNameLabel setTextColor:[UIColor colorWithRed:0x90/255.0 green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
    [_gameNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_gameNameLabel];
    [_gameNameLabel release];
    
    //matchDateLabel
    CGRect matchDateLabelRect = CGRectMake(fisrtColLabelMinX, CGRectGetMaxY(gameNameLabelRect) + firstColLabelVerticalInterval, fisrtColLabelWidth, firstColLabelHeight);
    _matchDateLabel = [[UILabel alloc] initWithFrame:matchDateLabelRect];
    [_matchDateLabel setBackgroundColor:[UIColor clearColor]];
    [_matchDateLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_matchDateLabel setTextColor:[UIColor colorWithRed:0x90/255.0 green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
    [_matchDateLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_matchDateLabel];
    [_matchDateLabel release];
    
    //lineImageView
    CGRect lineImageViewRect = CGRectMake(CGRectGetMaxX(matchDateLabelRect) + lineImageViewLabelLandscape, 0, lineImageViewWidth, _cellHight);
    
    //mainTeamLabel
    CGRect mainTeamLabelRect = CGRectMake(CGRectGetMaxX(lineImageViewRect) + lineImageViewLabelLandscape, firstRowLabelMinY, (kWinSize.width - CGRectGetMaxX(lineImageViewRect) - lineImageViewLabelLandscape - buttonImageViewIntervalRight - firstRowLabelLandscapeInterval * 2 - mainLoseBallLabelWidth) / 2.0, firstRowLabelHight);
    _mainTeamLabel = [[UILabel alloc] initWithFrame:mainTeamLabelRect];
    [_mainTeamLabel setBackgroundColor:[UIColor clearColor]];
    [_mainTeamLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_mainTeamLabel setTextColor:[UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f]];
    [_mainTeamLabel setTextAlignment:NSTextAlignmentRight];
    [self addSubview:_mainTeamLabel];
    [_mainTeamLabel release];
    
    //mainLoseBallLabel
    CGRect mainLoseBallLabelRect = CGRectMake(CGRectGetMaxX(mainTeamLabelRect) + firstRowLabelLandscapeInterval, firstRowLabelMinY, mainLoseBallLabelWidth, firstRowLabelHight);
    _mainLoseBallLabel = [[UILabel alloc] initWithFrame:mainLoseBallLabelRect];
    [_mainLoseBallLabel setBackgroundColor:[UIColor clearColor]];
    [_mainLoseBallLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_mainLoseBallLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_mainLoseBallLabel];
    [_mainLoseBallLabel release];
    
    //guestTeamLabel
    CGRect guestTeamLabelRect = CGRectMake(CGRectGetMaxX(mainLoseBallLabelRect) + firstRowLabelLandscapeInterval, firstRowLabelMinY, CGRectGetWidth(mainTeamLabelRect), firstRowLabelHight);
    _guestTeamLabel = [[UILabel alloc] initWithFrame:guestTeamLabelRect];
    [_guestTeamLabel setBackgroundColor:[UIColor clearColor]];
    [_guestTeamLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_guestTeamLabel setTextColor:[UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f]];
    [_guestTeamLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_guestTeamLabel];
    [_guestTeamLabel release];
    
    //labelOne
    CGRect labelOneRect = CGRectMake(CGRectGetMinX(mainTeamLabelRect), CGRectGetMaxY(mainTeamLabelRect) + secondColLabelVerticalInterval, secondColLabelWidht, secondColLabelHeight);
    _labelOne = [[UILabel alloc] initWithFrame:labelOneRect];
    [_labelOne setBackgroundColor:[UIColor clearColor]];
    [_labelOne setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize7]];
    [_labelOne setNumberOfLines:3];
    [_labelOne setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_labelOne];
    [_labelOne release];
    
    //labelTwo
    CGRect labelTwoRect = CGRectMake(CGRectGetMinX(mainTeamLabelRect), CGRectGetMaxY(labelOneRect) + secondColLabelVerticalInterval, secondColLabelWidht, secondColLabelHeight);
    _labelTwo = [[UILabel alloc] initWithFrame:labelTwoRect];
    [_labelTwo setBackgroundColor:[UIColor clearColor]];
    [_labelTwo setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize7]];
    [_labelTwo setNumberOfLines:3];
    [_labelTwo setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_labelTwo];
    [_labelTwo release];
    
    //buttonImageView
    CGRect buttonImageViewRect = CGRectMake(CGRectGetMinX(labelOneRect), CGRectGetMaxY(mainTeamLabelRect), kWinSize.width - CGRectGetMaxX(labelOneRect), _cellHight - CGRectGetMaxY(mainTeamLabelRect) - buttonImageViewCutY);
    _buttonImageView = [[UIImageView alloc] initWithFrame:buttonImageViewRect];
    [_buttonImageView setBackgroundColor:[UIColor clearColor]];
    [_buttonImageView setUserInteractionEnabled:YES];
    [self addSubview:_buttonImageView];
    [_buttonImageView release];
}

- (void)setMatchNO:(NSString *)matchNO {
    if(![matchNO isEqualToString:_matchNO]) {
        [_matchNO release];
        _matchNO = [matchNO copy];
        _matchNOLabel.text = _matchNO;
    }
}

- (void)setGameName:(NSString *)gameName {
    if(![gameName isEqualToString:_gameName]) {
        [_gameName release];
        _gameName = [gameName copy];
        _gameNameLabel.text = _gameName;
    }
}

- (void)setMatchDate:(NSString *)matchDate {
    if(![matchDate isEqualToString:_matchDate]) {
        [_matchDate release];
        _matchDate = [matchDate copy];
        _matchDateLabel.text = _matchDate;
    }
}

- (void)setMainTeam:(NSString *)mainTeam {
    if(![mainTeam isEqualToString:_mainTeam]) {
        [_mainTeam release];
        _mainTeam = [mainTeam copy];
        _mainTeamLabel.text = _mainTeam;
    }
}

- (void)setGuestTeam:(NSString *)guestTeam {
    if(![guestTeam isEqualToString:_guestTeam]) {
        [_guestTeam release];
        _guestTeam = [guestTeam copy];
        _guestTeamLabel.text = _guestTeam;
    }
}

- (void)setMainLoseBall:(NSString *)mainLoseBall {
    if(![mainLoseBall isEqualToString:_mainLoseBall]) {
        [_mainLoseBall release];
        _mainLoseBall = [mainLoseBall copy];
        if ([_mainLoseBall integerValue] > 0) {
            [_mainLoseBallLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
        } else if ([_mainLoseBall integerValue] < 0) {
            [_mainLoseBallLabel setTextColor:[UIColor colorWithRed:0x1a/255.0f green:0xaf/255.0f blue:0x3c/255.0f alpha:1.0f]];
        } else {
            [_mainLoseBallLabel setTextColor:[UIColor colorWithRed:0x80/255.0f green:0x80/255.0f blue:0x80/255.0f alpha:1.0f]];
        }
        _mainLoseBallLabel.text = _mainLoseBall;
    }
}

- (void)setBoldmainLoseBallLabel:(BOOL)boldmainLoseBallLabel {
    if (_boldmainLoseBallLabel != boldmainLoseBallLabel) {
        _boldmainLoseBallLabel = boldmainLoseBallLabel;
        if (_boldmainLoseBallLabel) {
            [_mainLoseBallLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize13]];
        } else {
            [_mainLoseBallLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        }
    }
}

- (void)setCellHight:(CGFloat)cellHight {
    if (_cellHight != cellHight) {
        _cellHight = cellHight;
        [self refreshSelfFrame];
    }
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -Customized: Private (General)
- (void)refreshSelfFrame {
    CGRect backImageViewRect = CGRectMake(0, 0, kWinSize.width, _cellHight);
    [_backImageView setFrame:backImageViewRect];
    
    CGRect lineViewRect = CGRectMake(0, _cellHight - AllLineWidthOrHeight, kWinSize.width, AllLineWidthOrHeight);
    [_lineView setFrame:lineViewRect];
    
    CGRect matchNOLabelRect = CGRectMake(fisrtColLabelMinX, (_cellHight - firstColLabelVerticalInterval * 2 - firstColLabelHeight * 3) / 2.0f, fisrtColLabelWidth, firstColLabelHeight);
    [_matchNOLabel setFrame:matchNOLabelRect];
    
    CGRect gameNameLabelRect = CGRectMake(fisrtColLabelMinX, CGRectGetMaxY(matchNOLabelRect) + firstColLabelVerticalInterval, fisrtColLabelWidth, firstColLabelHeight);
    [_gameNameLabel setFrame:gameNameLabelRect];
    
    CGRect matchDateLabelRect = CGRectMake(fisrtColLabelMinX, CGRectGetMaxY(gameNameLabelRect) + firstColLabelVerticalInterval, fisrtColLabelWidth, firstColLabelHeight);
    [_matchDateLabel setFrame:matchDateLabelRect];
    
    CGRect buttonImageViewRect = CGRectMake(CGRectGetMinX(_labelOne.frame), CGRectGetMaxY(_mainTeamLabel.frame), kWinSize.width - CGRectGetMaxX(_labelOne.frame), _cellHight - CGRectGetMaxY(_mainTeamLabel.frame) - buttonImageViewCutY);
    [_buttonImageView setFrame:buttonImageViewRect];
}



@end
