//
//  TitleOrDetailCell.h
//  TicketProject
//
//  Created by sls002 on 16/9/6.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TDCellHeight IS_PHONE ? 35.0f : 42.0f  //cell高度
#define Intelval_X IS_PHONE ? 10.0f : 15.0f //文字间间距
#define Title_color [UIColor grayColor] //标题颜色
#define TitleWidth IS_PHONE ? 100.0f : 140.0f //标题宽度
#define AllFontSize IS_PHONE ? 14.0f : 17.0f //文字大小

@interface TitleOrDetailCell : UITableViewCell

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UILabel *detailLabel;

@end
