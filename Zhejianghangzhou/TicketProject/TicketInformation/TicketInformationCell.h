//
//  TicketInformationCell.h
//  TicketProject
//
//  Created by KAI on 15/5/7.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TicketInformationCell : UITableViewCell {
    UILabel  *_titleLabel;
    UILabel  *_dateLabel;
    UIView   *_blackLineView;
    
    NSString *_title;
    NSString *_date;
    BOOL      _bottomLineHidden;
    CGFloat   _cellHeight;
    CGFloat   _cellWidth;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, assign) BOOL bottomLineHidden;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellHeight:(CGFloat)cellHeight cellWidth:(CGFloat)cellWidth;
- (void)setTitle:(NSString *)title color:(NSString *)color;

@end
