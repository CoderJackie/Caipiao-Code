//
//  CustomBottomView.h
//  TicketProject
//
//  Created by sls002 on 13-7-1.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBottomView : UIView {
    UIView  *_contentView;
}

@property (nonatomic,strong) UIImage *backImage;
@property (nonatomic,retain) CustomLabel *contentLabel;
@property (nonatomic,retain) CustomLabel *contentLabel1;
@property (nonatomic,retain) UIButton *leftButton;
@property (nonatomic,retain) UIButton *rightButton;
@property (nonatomic,retain) UIView *contentView;
@property (nonatomic,copy) NSString *contentString;

- (id)initWithFrame:(CGRect)frame Type:(NSInteger)type;

- (void)setTextWithMatchCount:(NSInteger)matchCount hasMatch:(BOOL)hasMatch;

- (void)setMatchCount:(NSInteger)matchCount money:(NSInteger)money;

- (void)setMatchCount:(NSInteger)matchCount money:(NSInteger)money winMoney1:(float)winMoney1 winMoney2:(float)winMoney2;

@end
