//
//  PicTableViewCell.h
//  TicketProject
//
//  Created by 杨宁 on 16/8/4.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicTableViewCell : UITableViewCell
@property(nonatomic,strong)UIImageView *myimage;
@property(nonatomic,strong)UILabel *title;
@property(nonatomic,strong)UIButton *btn;
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier target:(UIViewController *)target;
@end
