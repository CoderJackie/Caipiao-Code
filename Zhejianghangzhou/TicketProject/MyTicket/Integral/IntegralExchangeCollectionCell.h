//
//  IntegralExchangeCollectionCell.h
//  TicketProject
//
//  Created by KAI on 15/5/11.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntegralExchangeCollectionCell : UICollectionViewCell {
    UIImageView   *_photoImageView;
    UILabel       *_promptLabel;
    UIButton      *_exchangeBtn;
    
    NSString *_photoImageName;
    NSString *_prompt;
    
    CGFloat _cellWidth;
    CGFloat _cellHeight;
    NSInteger _btnTag;
}

@property (nonatomic, copy) NSString *photoImageName;
@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, assign) NSInteger btnTag;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) BOOL hasMakeSubView;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

- (void)makeSubView;

@end
