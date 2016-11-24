//
//  XYMPromptView.m
//
//  Created by Michael on 3/1/12.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kXYMPromptView_fontSize       XFIponeIpadFontSize14
#define kXYMPromptView_width          200
#define kMax_ConstrainedSize        CGSizeMake(200, 100)

@interface XYMPromptView : UIView{
    CGColorRef bgcolor_;
    NSString *info_;
    CGSize fontSize_;
}

// info为提示信息，frame为提示框大小，view是为消息框的superView（推荐Tabbarcontroller.view)
// vertical 为垂直方向上出现的位置 从 取值 0 ~ 1。
+ (void)showInfo:(NSString*)info bgColor:(CGColorRef)color inView:(UIView*)view isCenter:(BOOL)flag vertical:(float)height;

+ (void)defaultShowInfo:(NSString *)info isCenter:(BOOL)flag;

@end
