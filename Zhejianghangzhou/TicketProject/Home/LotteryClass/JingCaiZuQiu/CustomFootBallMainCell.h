//
//  CustomFootBallMainCell.h
//  TicketProject
//
//  Created by sls002 on 13-6-26.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomFootBallMainCell : UITableViewCell {
    UIImageView *_backImageView;
    UIView  *_lineView;
    UILabel *_matchNOLabel;
    UILabel *_gameNameLabel;
    UILabel *_matchDateLabel;
    UILabel *_mainTeamLabel;
    UILabel *_guestTeamLabel;
    UILabel *_mainLoseBallLabel;
    CGFloat _cellHight;
}

@property (nonatomic, copy) NSString *matchNO;
@property (nonatomic, copy) NSString *gameName;
@property (nonatomic, copy) NSString *matchDate;
@property (nonatomic, copy) NSString *guestTeam;
@property (nonatomic, copy) NSString *mainTeam;
@property (nonatomic, copy) NSString *mainLoseBall;
@property (nonatomic, assign) BOOL boldmainLoseBallLabel;
@property (nonatomic, strong) UILabel *labelOne;
@property (nonatomic, strong) UILabel *labelTwo;
@property (nonatomic, strong) UIImageView *buttonImageView;

@property (nonatomic, assign) CGFloat cellHight;

- (id)initWithCellHight:(CGFloat)hight reuseIdentifier:(NSString *)reuseIdentifier ;

@end
