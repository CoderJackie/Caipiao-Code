//
//  AddCardTableViewCell.m
//  TicketProject
//
//  Created by jsonLuo on 16/9/23.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import "AddCardTableViewCell.h"
#import "Globals.h"

@implementation AddCardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dealloc{
    _titleLabel = nil;
    _contentTectFiedld = nil;
    [super dealloc];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        /*******调整及适配******/
        CGFloat cellHeight = [AddCardTableViewCell cellHeight]; /**< cell的高度 */
        CGFloat interval = IS_PHONE ? 15.0f : 20.0f;            /**< 前后间隔 */
        CGFloat titelWidth = IS_PHONE ? 60.0f : 80.0f;          /**< 标题宽度 */
        /*********************/
        
        CGRect cellrect = self.frame;
        cellrect.size.height = cellHeight;
        self.frame = cellrect;
        
        //标题
        CGRect titleRect = CGRectMake(interval, 0, titelWidth, cellHeight);
        _titleLabel = [[UILabel alloc] initWithFrame:titleRect];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel release];
        
        //内容
        CGRect contentRect = CGRectMake(CGRectGetMaxX(titleRect), 0, CGRectGetWidth(cellrect)-CGRectGetMaxX(titleRect)-interval, cellHeight);
        _contentTectFiedld = [[UITextField alloc] initWithFrame:contentRect];
        [_contentTectFiedld setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [self.contentView addSubview:_contentTectFiedld];
        [_contentTectFiedld release];
        
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight{
    return IS_PHONE ? 35.0f : 45.0f;
}

@end
