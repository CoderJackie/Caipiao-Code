//
//  CustomButton.h
//  TicketProject
//
//  Created by sls002 on 14-3-5.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIButton {
    UILabel *_titleLabel;
    UILabel *_subTitleLabel;
    
    NSString *_title;
    NSString *_subTitle;
    
    UIColor  *_normalTitleColor;
    UIColor  *_normalSubTitleColor;
    
    UIColor  *_selectTitleColor;
    UIColor  *_selectSubTitleColor;
    
    UIColor  *_highlightTitleColor;
    UIColor  *_highlightSubTitleColor;
    
    UIColor  *_highlightSelectTitleColor;
    UIColor  *_highlightSelectSubTitleColor;
    
    BOOL      _customBtnSelect;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, assign) BOOL customBtnSelect;

@property(nonatomic, strong)UILabel * titleLabel1, * subTitleLabel;

- (void)setCustomTitleColor:(UIColor *)color forState:(UIControlState)state;

- (void)setCustomSubTitleColor:(UIColor *)color forState:(UIControlState)state;

@end
