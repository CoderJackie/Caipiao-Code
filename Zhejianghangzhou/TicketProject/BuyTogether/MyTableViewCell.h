//
//  MyTableViewCell.h
//  TicketProject
//
//  Created by 杨宁 on 16/7/22.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell
@property(nonatomic,strong)UILabel *ticketNameLabel;
@property(nonatomic,strong)UILabel *namelabel;
@property(nonatomic,strong)UILabel *sponsorNameLabel;
@property(nonatomic,strong)UIButton *top;
@property(nonatomic,strong)UIButton *down;
@property(nonatomic,strong)UILabel *solutionAmountLabel;
@property(nonatomic,strong)UILabel *eachAmountLabel;
@property(nonatomic,strong)UILabel *remainCopiesLabel;
@property(nonatomic,strong)UILabel *solutionAmountPromptLabel;
@property(nonatomic,strong)UILabel *littleticketNameLabel;
@property(nonatomic,strong)UILabel *eachAmountPromptLabel;
@property(nonatomic,strong)UILabel *remainCopiesPromptLabel;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier target:(UIViewController *)target;
@end
