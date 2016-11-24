//
//  CustomBetViewCell.h
//  TicketProject
//
//  Created by sls002 on 13-7-1.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBetViewCell : UITableViewCell {
    
    UILabel *_mainTeamLabel;
    UILabel *_letBallLabel;
    UILabel *_guestTeamLabel;
    
    UILabel *_oneLabel;
    UILabel *_twoLabel;
    
    CGFloat _seltHeight;
    
    UIImageView *_backImageView;
    NSString    *_letBall;
}


@property (nonatomic, assign) UIImage *backImage;
@property (nonatomic,copy) NSString *mainTeamName;
@property (nonatomic,copy) NSString *guestTeamName;
@property (nonatomic,copy) NSString *letBall;
@property (strong, nonatomic) UILabel *oneLabel;
@property (strong, nonatomic) UILabel *twoLabel;

- (id)initWithHeihgt:(CGFloat)height style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;


@end
