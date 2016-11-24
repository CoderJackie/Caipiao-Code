//
//  BankCardTableViewCell.h
//  TicketProject
//
//  Created by jsonLuo on 16/9/22.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BankCardTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *backView;             /**< 背景 */
@property (nonatomic, strong) UIImageView *bankImageView;   /**< 银行图片 */
@property (nonatomic, strong) UILabel *bankInfomationLabel; /**< 银行卡信息 */
@property (nonatomic, strong) UILabel *cardNumberLabel;     /**< 银行卡号 */

/**cell的高度*/
+ (CGFloat)cellHeight;

@end
