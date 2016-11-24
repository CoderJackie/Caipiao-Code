//
//  CustomSFCTableViewCell.h
//  TicketProject
//
//  Created by sls002 on 13-6-3.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSFCTableViewCell : UITableViewCell {
    
    UILabel *_matchNumberLabel;
    UILabel *_gameLabel;
    UILabel *_matchTimeLabel;
    
    UILabel *_hostTeamLabel; //主队
    UILabel *_guestTeamLabel;//客队
    
    
    NSString *_matchNumber;
    NSString *_game;
    NSString *_matchTime;
    NSString *_hostTeamName;
    NSString *_guestTeamName;
    CGFloat _cellHight;
}

@property (nonatomic, copy) NSString *matchNumber;
@property (nonatomic, copy) NSString *game;
@property (nonatomic, copy) NSString *matchTime;
@property (nonatomic, copy) NSString *hostTeamName;
@property (nonatomic, copy) NSString *guestTeamName;
@property (nonatomic, readonly, getter = getHostTeamLabelFrame) CGRect hostTeamLabelFrame;

- (id)initWithCellHight:(CGFloat)hight reuseIdentifier:(NSString *)reuseIdentifier;

@end
