//
//  CustomizedButton.h 自定义
//  TicketProject
//
//  Created by KAI on 14-11-13.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CustomizedButtonTypeLandscape,
    CustomizedButtonTypeVertical,
} CustomizedButtonType;


@interface CustomizedButton : UIButton {
    UILabel *_textLabel;
    UILabel *_oddsLabel;
    
    CustomizedButtonType _customizedButtonType;
    
    UIColor *_textTextColor;
    UIColor *_textTextSelectColor;
    UIColor *_oddsTextColor;
    UIColor *_oddsTextSelectColor;
    
    NSString *_textString;
    NSString *_oddsString;
    CGFloat   _landscapeInterval;
    CGFloat   _verticalInterval;
    CGFloat   _topMagin;
    CGFloat   _bottomMagin;
    
    BOOL      _customSelfSelect;
}

@property (nonatomic, assign) CustomizedButtonType customizedButtonType;
@property (nonatomic, assign) CGFloat textFontSize;
@property (nonatomic, assign) CGFloat oddsLabelFontSize;
@property (nonatomic, copy) NSString *textString;
@property (nonatomic, copy) NSString *oddsString;
@property (nonatomic, retain) UIColor *textTextColor;
@property (nonatomic, retain) UIColor *textTextSelectColor;
@property (nonatomic, retain) UIColor *oddsTextColor;
@property (nonatomic, retain) UIColor *oddsTextSelectColor;


@property (nonatomic, assign) CGFloat landscapeInterval;
@property (nonatomic, assign) CGFloat verticalInterval;
@property (nonatomic, assign) CGFloat topMagin;
@property (nonatomic, assign) CGFloat bottomMagin;

@end
