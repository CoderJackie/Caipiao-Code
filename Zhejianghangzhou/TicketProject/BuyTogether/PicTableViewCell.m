//
//  PicTableViewCell.m
//  TicketProject
//
//  Created by 杨宁 on 16/8/4.
//  Copyright © 2016年 sls002. All rights reserved.
//
#define Mywidth ([UIScreen mainScreen].bounds.size.width)
#import "PicTableViewCell.h"

@implementation PicTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier target:(UIViewController *)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat imagesizewidth = IS_PHONE ? 80.0f : 120.0f;
//        CGFloat imagesizeheight = IS_PHONE ? 100.0f : 150.0f;
//        CGFloat titlesizex = IS_PHONE ? 80.0f : 120.0f;
        _myimage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, imagesizewidth, imagesizewidth)];
        _myimage.layer.masksToBounds = YES;
        _myimage.layer.cornerRadius = 10;
        [self addSubview:_myimage];
        
        _title = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_myimage.frame)+10, (CGRectGetMaxY(_myimage.frame)+10)/2-20, 200, 40)];
//        _title.backgroundColor = [UIColor yellowColor];
        _title.textColor = [UIColor blackColor];
        _title.font = [UIFont systemFontOfSize:14];
        [self addSubview:_title];
        
        _btn = [UIButton buttonWithType:0];

        _btn.frame = CGRectMake(Mywidth-50, (CGRectGetMaxY(_myimage.frame)+10)/2-20, 40, 40);
//        _btn.backgroundColor = [UIColor cyanColor];
        [self addSubview:_btn];
        
    }
    return self;
}




















@end
