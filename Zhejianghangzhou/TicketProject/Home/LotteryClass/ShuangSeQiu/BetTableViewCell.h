//
//  BetTableViewCell.h
//  TicketProject
//
//  Created by sls002 on 13-5-24.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

#define betNumberLabelMinX (IS_PHONE ? 30.0f : 60.0f)
#define betNumberLabelMinY (IS_PHONE ? 16.0f : 24.0f)
#define betNumberLabelMaginRight (IS_PHONE ? 30.0f : 50.0f)
#define deleteBtnMaginRight (IS_PHONE ? 30.0f : 50.0)

@class AttributedLabel;
@class CustomLabel;

@interface BetTableViewCell : UITableViewCell {
    
    CustomLabel *_betNumberLabel;
    UILabel     *_selectedNumberLabel;
    UILabel     *_betTypeLabel;
    UILabel     *_betCountLabel;
    UIImageView *_backImageView;
    UIButton    *_deleteBtn;
    UIView      *_lineView;
    
    CGFloat  _cellWidth;
    CGFloat  _cellHeight;
}

@property (nonatomic, assign) UIImage *backImage;
@property (nonatomic, assign) NSString *betNumberString;
@property (nonatomic, assign) NSString *selectedNumberString;
@property (nonatomic, assign) NSString *betTypeString;
@property (nonatomic, assign) NSString *betCountString;

- (id)initWithCellWidth:(CGFloat)width Height:(CGFloat)height Style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)backImageViewFrame:(CGRect)frame;

- (void)setLineWithCellHeight:(CGFloat)cellHeight;

- (UIButton *)getDeleteButton;

- (void)setDeleteButtonFrameWithCellHeight:(CGFloat)height;
@end
