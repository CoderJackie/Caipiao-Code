//
//  TitleOrDetailCell.m
//  TicketProject
//
//  Created by sls002 on 16/9/6.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import "TitleOrDetailCell.h"

@implementation TitleOrDetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGRect newFrame = self.frame;
        newFrame.size.height = TDCellHeight;
        self.frame = newFrame;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(Intelval_X, 0, TitleWidth, TDCellHeight)];
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_titleLabel.frame)+10, 0, kScreenSize.width-(CGRectGetMaxX(_titleLabel.frame)), TDCellHeight)];
        
        [_titleLabel setFont:[UIFont systemFontOfSize:AllFontSize]];
        [_detailLabel setFont:[UIFont systemFontOfSize:AllFontSize]];
        [_titleLabel setTextAlignment:NSTextAlignmentRight];
        
        _titleLabel.textColor = Title_color;
        _detailLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_detailLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
