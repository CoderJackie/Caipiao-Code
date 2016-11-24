//
//  BankCardTableViewCell.m
//  TicketProject
//
//  Created by jsonLuo on 16/9/22.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import "BankCardTableViewCell.h"
#import "Globals.h"

@implementation BankCardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dealloc{
    _backView = nil;
    _bankImageView = nil;
    _bankInfomationLabel = nil;
    _cardNumberLabel = nil;
    [super dealloc];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        /******调整及适配******/
        CGFloat cellHeight = [BankCardTableViewCell cellHeight];             /**< cell的高度 */
        CGFloat interval = IS_PHONE ? 10.0f : 15.0f;        /**< 前后上间距 */
        CGFloat imageWidth = IS_PHONE ? 30.0f : 40.0f;      /**< 图标宽度 */
        /********************/
        
        CGRect cellrect = self.frame;
        cellrect.size.height = cellHeight;
        self.frame = cellrect;
        
        //背景
        CGRect backRect = CGRectMake(interval, interval, cellrect.size.width-interval*2.0, cellHeight-interval);
        _backView = [[UIView alloc] initWithFrame:backRect];
        [_backView setBackgroundColor:kGreenColor];
        [_backView.layer setCornerRadius:10.0f];//暂时处理layer，待优化
        [self.contentView addSubview:_backView];
        [_backView release];
        
        //图标
        CGRect imageRect = CGRectMake(interval, interval, imageWidth, imageWidth);
        _bankImageView = [[UIImageView alloc] initWithFrame:imageRect];
        [_backView addSubview:_bankImageView];
        [_bankImageView setHidden:YES];//隐藏图标
        [_bankImageView release];
        
        //银行卡信息
        CGRect infoRect = CGRectMake(CGRectGetMaxX(imageRect)+interval, CGRectGetMinY(imageRect), CGRectGetWidth(backRect)-CGRectGetMaxX(imageRect)-interval*2, CGRectGetHeight(imageRect));
        _bankInfomationLabel = [[UILabel alloc] initWithFrame:infoRect];
        [_bankInfomationLabel setNumberOfLines:0];
        [_bankInfomationLabel setTextColor:[UIColor whiteColor]];
        [_bankInfomationLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
        [_backView addSubview:_bankInfomationLabel];
        [_bankInfomationLabel release];
        
        //银行卡号
        CGRect numberRect = CGRectMake(CGRectGetMinX(infoRect), CGRectGetMaxY(infoRect), CGRectGetWidth(infoRect), CGRectGetHeight(backRect)-CGRectGetMaxY(infoRect));
        _cardNumberLabel = [[UILabel alloc] initWithFrame:numberRect];
        [_cardNumberLabel setTextColor:[UIColor whiteColor]];
        [_cardNumberLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize21]];
        [_backView addSubview:_cardNumberLabel];
        [_cardNumberLabel release]; 
    }
    return self;
}

+ (CGFloat)cellHeight{
    return IS_PHONE ? 100.0f : 130.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
