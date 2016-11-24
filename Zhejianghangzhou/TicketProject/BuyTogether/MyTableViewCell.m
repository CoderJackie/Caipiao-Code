//
//  MyTableViewCell.m
//  TicketProject
//
//  Created by 杨宁 on 16/7/22.
//  Copyright © 2016年 sls002. All rights reserved.
//

#define Mywidth ([UIScreen mainScreen].bounds.size.width)
#define kOncePageSize 30
#define LaunchChippedListViewTabelCellHeight (IS_PHONE ? 85.0f : 130.0f)

#import "MyTableViewCell.h"
#import "Globals.h"
@implementation MyTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier target:(UIViewController *)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        CGFloat ticketNameLabelWidth = IS_PHONE ? 80.0f : 120.0f;
        CGFloat ticketNameLabelWidth = (kScreenSize.width-60)/4.0;  /**< label宽度 */
        
        CGFloat radialViewOfFangAnTextLabelAddY = IS_PHONE ? 15.0f : 20.0f;    //方案进度
        CGFloat radialViewOfFangAnTextLabelHeight = IS_PHONE ? 13.0f : 18.0f;
        CGFloat radialViewOfBaoDiTextLabelAddY = IS_PHONE ? 26.0f : 37.0f;     //保底进度
        CGFloat radialViewOfBaoDiTextLabelHeight = IS_PHONE ? 14.0f : 20.0f;
        CGFloat radialProgressSize = IS_PHONE ? 49.0f : 69.0f;                //进度视图大小
        
        CGFloat leftSignImageViewMaginRightX = IS_PHONE ? 10.0f : 20.0f;   //右指向图标
        CGFloat leftSignImageViewWidth = IS_PHONE ? 15.0f : 30.0f;
        CGFloat leftSignImageViewHeight = IS_PHONE ? 14.0f : 28.0f;
        
        CGFloat lineMinX = IS_PHONE ? 10.0f : 20.0f;      //底部分隔线
        
        CGFloat allLabelHeight = IS_PHONE ? 21.0f : 30.0f;      //没特定制定的所有label高度
        
        CGFloat headImageViewAddX = IS_PHONE ? 6.0f : 80.0f;    //头像视图
        CGFloat headImageViewMinY = IS_PHONE ? 14.0f : 20.0f;
        CGSize headImageViewSize = IS_PHONE ? CGSizeMake(40.0f, 15.0f) : CGSizeMake(25.0f, 25.0f);
        CGFloat sponsorNameMaginHeadImageView = IS_PHONE ? 3.0f : 12.0;    //发起人
        
        CGFloat levelViewAndSponsorNameLabelLandscapeInterval = IS_PHONE ? 3.0f : 28.0f; //等级视图
        CGFloat levelViewMinY = IS_PHONE ? 6.0f : 8.0f;
        CGFloat levelViewLabelHeightAddSponsorNameLabelHeight = IS_PHONE ? 3.0f : 5.0f;
        
        CGFloat solutionAmountPromptLabelMinY = IS_PHONE ? 32.0f : 50.0f; //总金额
        CGFloat solutionAmountPromptLabelWidthAddTicketNameLabelWidth = IS_PHONE ? -5.0f : 60.0f;
        CGFloat promptLabelLandscapeMagin = IS_PHONE ? 1.0f : 10.0f;
        CGFloat promptLabelVerticalMagin = IS_PHONE ? -2.0f : 4.0f;
        /********************** adjustment end ***************************/
        //backImageView 背景
        //        CGRect backImageViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), LaunchChippedListViewTabelCellHeight) ;
        //        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
        //        [backImageView setBackgroundColor:[UIColor cyanColor]];
        //        [cell.contentView addSubview:backImageView];
        //        [backImageView release];
        
        //leftSignImageView
        CGRect leftSignImageViewRect = CGRectMake(Mywidth - leftSignImageViewWidth - leftSignImageViewMaginRightX, (LaunchChippedListViewTabelCellHeight - leftSignImageViewHeight) / 2.0f , leftSignImageViewWidth, leftSignImageViewHeight);
        UIImageView *leftSignImageView = [[UIImageView alloc] initWithFrame:leftSignImageViewRect];
        [leftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
        //        [cell.contentView addSubview:leftSignImageView];

        
        
        //line
        CGRect lineRect = CGRectMake(lineMinX, LaunchChippedListViewTabelCellHeight - AllLineWidthOrHeight, Mywidth - lineMinX * 2, AllLineWidthOrHeight);
        [Globals makeLineWithFrame:lineRect inSuperView:self.contentView];
        
        //ticketNameLabel 彩种名称
        CGRect ticketNameLabelRect = CGRectMake(0, solutionAmountPromptLabelMinY, ticketNameLabelWidth, allLabelHeight);
        _ticketNameLabel = [[UILabel alloc] initWithFrame:ticketNameLabelRect];
        [_ticketNameLabel setTextAlignment:NSTextAlignmentCenter];
        [_ticketNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [_ticketNameLabel setBackgroundColor:[UIColor clearColor]];
        [_ticketNameLabel setTextColor:[UIColor blackColor]];//[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
        [_ticketNameLabel setTag:204];
        [self.contentView addSubview:_ticketNameLabel];
//        ticketNameLabel.text = model.lotteryName;
        
        //radialView 方案进度视图        ---      自定义进度图部分
        CGRect radialViewRect = CGRectMake((ticketNameLabelWidth - radialProgressSize) / 2.0f, CGRectGetMaxY(ticketNameLabelRect), radialProgressSize, radialProgressSize);

        
        //fanganRateLabel 方案进度        ---      自定义进度图部分
        CGRect fanganRateLabelRect = CGRectMake(CGRectGetMinX(radialViewRect), CGRectGetMinY(radialViewRect) + radialViewOfFangAnTextLabelAddY, CGRectGetWidth(radialViewRect), radialViewOfFangAnTextLabelHeight) ;
        UILabel *fanganRateLabel = [[UILabel alloc]initWithFrame:fanganRateLabelRect];
        [fanganRateLabel setTextAlignment:NSTextAlignmentCenter];
        [fanganRateLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [fanganRateLabel setBackgroundColor:[UIColor clearColor]];
        [fanganRateLabel setTag:202];
        //        [backImageView addSubview:fanganRateLabel];

        
        //baoRateLabel 方案保底        ---      自定义进度图部分
        CGRect baoRateLabelRect = CGRectMake(CGRectGetMinX(fanganRateLabelRect), CGRectGetMinY(radialViewRect) + radialViewOfBaoDiTextLabelAddY, CGRectGetWidth(fanganRateLabelRect), radialViewOfBaoDiTextLabelHeight);
        UILabel *baoRateLabel = [[UILabel alloc]initWithFrame:baoRateLabelRect];
        [baoRateLabel setTextAlignment:NSTextAlignmentCenter];
        [baoRateLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize8]];
        [baoRateLabel setTextColor:[UIColor orangeColor]];
        [baoRateLabel setBackgroundColor:[UIColor clearColor]];
        [baoRateLabel setTag:203];
        //        [backImageView addSubview:baoRateLabel];

        //
        //headImageView 头像
        CGRect headImageViewRect = CGRectMake(CGRectGetMaxX(ticketNameLabelRect) + headImageViewAddX, headImageViewMinY, headImageViewSize.width, headImageViewSize.height);
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:headImageViewRect];
        [headImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"head.png"]]];
        //        [backImageView addSubview:headImageView];

        
        CGRect headNmae = CGRectMake(CGRectGetMaxX(ticketNameLabelRect) + headImageViewAddX, headImageViewMinY, headImageViewSize.width+100, headImageViewSize.height);
        _namelabel = [[UILabel alloc]initWithFrame:headNmae];
        _namelabel.text = @"发起人:";
        //        namelabel.textAlignment = NSTextAlignmentCenter;
        _namelabel.font = [UIFont systemFontOfSize:11];
        _namelabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_namelabel];

        
        //sponsorNameLabel 发起用户名
        CGRect sponsorNameLabelRect = CGRectMake(CGRectGetMaxX(headImageViewRect) + sponsorNameMaginHeadImageView, CGRectGetMinY(headImageViewRect) - (allLabelHeight - headImageViewSize.height) / 2.0f, CGRectGetWidth(ticketNameLabelRect), allLabelHeight);
        _sponsorNameLabel = [[UILabel alloc] initWithFrame:sponsorNameLabelRect];
        [_sponsorNameLabel setTextAlignment:NSTextAlignmentLeft];
        [_sponsorNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [_sponsorNameLabel setTextColor:[UIColor blackColor]];
        [_sponsorNameLabel setBackgroundColor:[UIColor clearColor]];
        [_sponsorNameLabel setTag:205];
        [self.contentView addSubview:_sponsorNameLabel];

        
        
        CGRect topbtn = CGRectMake(Mywidth-55, LaunchChippedListViewTabelCellHeight/2-25, 50, 20);
        _top = [UIButton buttonWithType:0];
        _top.backgroundColor = [UIColor redColor];
        _top.layer.masksToBounds = YES;
        _top.layer.cornerRadius = 10;
        
        _top.titleLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize14];
        [_top setTitle:@"复制" forState:UIControlStateNormal];
        _top.frame = topbtn;
        [self.contentView addSubview:_top];
        
        
        CGRect downbtn = CGRectMake(Mywidth-55, LaunchChippedListViewTabelCellHeight/2+5, 50, 20);
        _down = [UIButton buttonWithType:0];
        _down.backgroundColor = [UIColor blueColor];
        _down.layer.masksToBounds = YES;
        _down.layer.cornerRadius = 10;
        [_down setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _down.titleLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize14];
        [_down setTitle:@"详情" forState:UIControlStateNormal];
        _down.frame = downbtn;
        [self.contentView addSubview:_down];
        
        //levelView 等级图案
        CGRect levelViewRect = CGRectMake(CGRectGetMaxX(sponsorNameLabelRect) + levelViewAndSponsorNameLabelLandscapeInterval, levelViewMinY, CGRectGetWidth(ticketNameLabelRect), CGRectGetHeight(sponsorNameLabelRect) + levelViewLabelHeightAddSponsorNameLabelHeight);
        UIView *levelView = [[UIView alloc] initWithFrame:levelViewRect];
        [levelView setTag:206];
        //        [backImageView addSubview:levelView];

        
        //solutionAmountPromptLabel 方案金额 提示文字
        
        
        //solutionAmountLabel 方案金额
        CGRect solutionAmountPromptLabelRect = CGRectMake(CGRectGetMinX(headImageViewRect), solutionAmountPromptLabelMinY, CGRectGetWidth(ticketNameLabelRect) + solutionAmountPromptLabelWidthAddTicketNameLabelWidth, allLabelHeight);
        
        
        _solutionAmountLabel = [[UILabel alloc] initWithFrame:solutionAmountPromptLabelRect];
        [_solutionAmountLabel setTextAlignment:NSTextAlignmentLeft];
        [_solutionAmountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
        [_solutionAmountLabel setTag:207];
        [_solutionAmountLabel setTextColor:[UIColor blackColor]];
        [_solutionAmountLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_solutionAmountLabel];

        
        //eachAmountLabel 每份金额
        
        
        CGRect eachAmountPromptLabelRect = CGRectMake(CGRectGetMaxX(solutionAmountPromptLabelRect) + promptLabelLandscapeMagin, CGRectGetMinY(solutionAmountPromptLabelRect), CGRectGetWidth(solutionAmountPromptLabelRect), CGRectGetHeight(solutionAmountPromptLabelRect));
        
        
        _eachAmountLabel = [[UILabel alloc] initWithFrame:eachAmountPromptLabelRect];
        [_eachAmountLabel setTextAlignment:NSTextAlignmentLeft];
        [_eachAmountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
        [_eachAmountLabel setTag:208];
        [_eachAmountLabel setTextColor:[UIColor blackColor]];
        [_eachAmountLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_eachAmountLabel];

        
        //remainCopiesPromptLabel 剩余份数
        CGRect remainCopiesPromptLabelRect = CGRectMake(CGRectGetMaxX(eachAmountPromptLabelRect) + promptLabelLandscapeMagin, CGRectGetMinY(solutionAmountPromptLabelRect), CGRectGetWidth(solutionAmountPromptLabelRect), CGRectGetHeight(solutionAmountPromptLabelRect));
        
         _remainCopiesLabel = [[UILabel alloc] initWithFrame:remainCopiesPromptLabelRect];
        [_remainCopiesLabel setTextAlignment:NSTextAlignmentLeft];
        [_remainCopiesLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
        [_remainCopiesLabel setTag:209];
        [_remainCopiesLabel setTextColor:[UIColor blackColor]];
        [_remainCopiesLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_remainCopiesLabel];

        
        
        CGRect solutionAmountLabelRect = CGRectMake(CGRectGetMinX(solutionAmountPromptLabelRect), CGRectGetMaxY(solutionAmountPromptLabelRect) + promptLabelVerticalMagin, CGRectGetWidth(solutionAmountPromptLabelRect), allLabelHeight);
        _solutionAmountPromptLabel = [[UILabel alloc] initWithFrame:solutionAmountLabelRect];
        [_solutionAmountPromptLabel setText:@"方案总额"];
        [_solutionAmountPromptLabel setTextAlignment:NSTextAlignmentLeft];
        [_solutionAmountPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [_solutionAmountPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
        [_solutionAmountPromptLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_solutionAmountPromptLabel];

        
        CGRect littleticketNameLabelRect = CGRectMake(0, CGRectGetMaxY(solutionAmountPromptLabelRect) + promptLabelVerticalMagin, ticketNameLabelWidth, allLabelHeight);
        _littleticketNameLabel = [[UILabel alloc] initWithFrame:littleticketNameLabelRect];
        [_littleticketNameLabel setTextAlignment:NSTextAlignmentCenter];
        [_littleticketNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [_littleticketNameLabel setBackgroundColor:[UIColor clearColor]];
        [_littleticketNameLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
        _littleticketNameLabel.text = @"待定";
        [_littleticketNameLabel setTag:204];
        [self.contentView addSubview:_littleticketNameLabel];

        
        
        //eachAmountLabelPrompt 每份金额 提示文字
        
        CGRect eachAmountLabelRect = CGRectMake(CGRectGetMinX(eachAmountPromptLabelRect), CGRectGetMinY(solutionAmountLabelRect), CGRectGetWidth(eachAmountPromptLabelRect), CGRectGetHeight(solutionAmountLabelRect));
        
        _eachAmountPromptLabel = [[UILabel alloc] initWithFrame:eachAmountLabelRect];
        [_eachAmountPromptLabel setText:@"单倍金额"];
        [_eachAmountPromptLabel setTextAlignment:NSTextAlignmentLeft];
        [_eachAmountPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [_eachAmountPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
        [_eachAmountPromptLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_eachAmountPromptLabel];

        
        //remainCopiesPromptLabel 剩余份数 提示文字
        CGRect remainCopiesLabelRect = CGRectMake(CGRectGetMinX(remainCopiesPromptLabelRect), CGRectGetMinY(solutionAmountLabelRect), CGRectGetWidth(remainCopiesPromptLabelRect), CGRectGetHeight(solutionAmountLabelRect));
        _remainCopiesPromptLabel = [[UILabel alloc] initWithFrame:remainCopiesLabelRect];
        [_remainCopiesPromptLabel setText:@"参与人数"];
        [_remainCopiesPromptLabel setTextAlignment:NSTextAlignmentLeft];
        [_remainCopiesPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [_remainCopiesPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
        [_remainCopiesPromptLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_remainCopiesPromptLabel];
    }
    return self;
}


@end
