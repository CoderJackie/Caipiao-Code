//
//  CustomSFCTableViewCell.m 购彩大厅－胜负彩任九场选号tabelcell
//  TicketProject
//
//  Created by sls002 on 13-6-3.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140923 10:22（洪晓彬）：修改代码规范，改进生命周期，处理各种内存问题
//20140923 10:39（洪晓彬）：进行ipad适配

#import "CustomSFCTableViewCell.h"

#import "Globals.h"

@implementation CustomSFCTableViewCell
@synthesize hostTeamName = _hostTeamName;
@synthesize guestTeamName = _guestTeamName;
@synthesize matchNumber = _matchNumber;
@synthesize game = _game;
@synthesize matchTime = _matchTime;

- (id)initWithCellHight:(CGFloat)hight reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellHight = hight;
        [self makeCell];
    }
    return self;
}

- (void)makeCell {
    /********************** adjustment 控件调整 ***************************/
    CGFloat firstColFirstLabelMinY = IS_PHONE ? 5.5 : 8.0f;
    CGFloat firstColLabelVerticalInterval = 0.0;
    CGFloat firstColLabelWidth = IS_PHONE ? 80.0f : 160.0f;
    CGFloat firstColLabelHeight = IS_PHONE ? 18.0f : 25.0f;
    
    CGFloat secondLabelMaginX = 14.0f;
    CGFloat secondLabelMinY = 2.0f;
    CGFloat secondCenterLabelWidth = 30.0f;
    CGFloat secondBothSideLabelWidth = (kWinSize.width - firstColLabelWidth - secondCenterLabelWidth - secondLabelMaginX * 2) / 2.0f;
    CGFloat secondLabelHeight = IS_PHONE ? 21.0f : 30.0f;
    /********************** adjustment end ***************************/
    CGRect backImageViewRect = CGRectMake(0, 0, kWinSize.width, _cellHight);
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
    [backImageView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:backImageView];
    [backImageView release];
    
    //matchNumberLabel
    CGRect matchNumberLabelRect = CGRectMake(0, firstColFirstLabelMinY, firstColLabelWidth, firstColLabelHeight);
    _matchNumberLabel = [[UILabel alloc] initWithFrame:matchNumberLabelRect];
    [_matchNumberLabel setBackgroundColor:[UIColor clearColor]];
    [_matchNumberLabel setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
    [_matchNumberLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize11]];
    [_matchNumberLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_matchNumberLabel];
    [_matchNumberLabel release];
    
    //gameLabel
    CGRect gameLabelRect = CGRectMake(0, CGRectGetMaxY(matchNumberLabelRect) + firstColLabelVerticalInterval, firstColLabelWidth, firstColLabelHeight);
    _gameLabel = [[UILabel alloc] initWithFrame:gameLabelRect];
    [_gameLabel setBackgroundColor:[UIColor clearColor]];
    [_gameLabel setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
    [_gameLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize12]];
    [_gameLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_gameLabel];
    [_gameLabel release];
    
    //timeLabel
    CGRect matchTimeLabelRect = CGRectMake(0, CGRectGetMaxY(gameLabelRect) + firstColLabelVerticalInterval, firstColLabelWidth, firstColLabelHeight);
    _matchTimeLabel = [[UILabel alloc] initWithFrame:matchTimeLabelRect];
    [_matchTimeLabel setBackgroundColor:[UIColor clearColor]];
    [_matchTimeLabel setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
    [_matchTimeLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize12]];
    [_matchTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_matchTimeLabel];
    [_matchTimeLabel release];
    
    //hostTeamLabel
    CGRect hostTeamLabelRect = CGRectMake(CGRectGetMaxX(matchNumberLabelRect) + secondLabelMaginX, secondLabelMinY, secondBothSideLabelWidth, secondLabelHeight);
    _hostTeamLabel = [[UILabel alloc] initWithFrame:hostTeamLabelRect];
    [_hostTeamLabel setBackgroundColor:[UIColor clearColor]];
    [_hostTeamLabel setTextColor:[UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f]];
    [_hostTeamLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_hostTeamLabel setTextAlignment:NSTextAlignmentRight];
    [self addSubview:_hostTeamLabel];
    [_hostTeamLabel release];
    
    //promptLabel
    CGRect promptLabelRect = CGRectMake(CGRectGetMaxX(hostTeamLabelRect) , secondLabelMinY, secondCenterLabelWidth, secondLabelHeight);
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [promptLabel setTextColor:[UIColor colorWithRed:0x80/255.0f green:0x80/255.0f blue:0x80/255.0f alpha:1.0f]];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel setText:@"VS"];
    [self addSubview:promptLabel];
    [promptLabel release];
    
    //guestTeamLabel
    CGRect guestTeamLabelRect = CGRectMake(CGRectGetMaxX(promptLabelRect), secondLabelMinY, secondBothSideLabelWidth, secondLabelHeight);
    _guestTeamLabel = [[UILabel alloc] initWithFrame:guestTeamLabelRect];
    [_guestTeamLabel setBackgroundColor:[UIColor clearColor]];
    [_guestTeamLabel setTextColor:[UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f]];
    [_guestTeamLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_guestTeamLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_guestTeamLabel];
    [_guestTeamLabel release];
    
    CGRect lineRect = CGRectMake(0, _cellHight - AllLineWidthOrHeight, kWinSize.width, AllLineWidthOrHeight);
    [Globals makeLineWithFrame:lineRect inSuperView:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setMatchNumber:(NSString *)matchNumber {
    if (![_matchNumber isEqualToString:matchNumber]) {
        [_matchNumber release];
        _matchNumber = [matchNumber copy];
        [_matchNumberLabel setText:_matchNumber];
    }
}

- (void)setGame:(NSString *)game {
    if (![_game isEqualToString:game]) {
        [_game release];
        _game = [game copy];
        [_gameLabel setText:_game];
    }
}

- (void)setMatchTime:(NSString *)matchTime {
    if (![_matchTime isEqualToString:matchTime]) {
        [_matchTime release];
        _matchTime = [matchTime copy];
        [_matchTimeLabel setText:_matchTime];
    }
}

- (void)setHostTeamName:(NSString *)hostTeamName {
    if(![_hostTeamName isEqualToString:hostTeamName]) {
        [_hostTeamName release];
        _hostTeamName = [hostTeamName copy];
        _hostTeamLabel.text = _hostTeamName;
    }
}

- (void)setGuestTeamName:(NSString *)guestTeamName {
    if(![_guestTeamName isEqualToString:guestTeamName]) {
        [_guestTeamName release];
        _guestTeamName = [guestTeamName copy];
        [_guestTeamLabel setText:_guestTeamName];
    }
}

- (CGRect)getHostTeamLabelFrame {
    if (_hostTeamLabel) {
        return _hostTeamLabel.frame;
    }
    return CGRectMake(0, 0, 0, 0);
}

- (void)dealloc {
    [_matchNumber release];
    [_game release];
    [_matchTime release];
    [_hostTeamName release];
    [_guestTeamName release];
    
    [super dealloc];
}

@end
