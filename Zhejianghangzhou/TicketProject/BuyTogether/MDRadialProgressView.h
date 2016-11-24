//
//  MDRadialProgressView.h
//  MDRadialProgress
//
//  Created by Marco Dinacci on 25/03/2013.
//  Copyright (c) 2013 Marco Dinacci. All rights reserved.
//


/**
 *  合买大厅中合买方案的进度显示
 */

#import <UIKit/UIKit.h>

@interface MDRadialProgressView : UIView

@property (assign, nonatomic) NSUInteger progressTotal;
@property (assign, nonatomic) NSUInteger progressCurrent;

@property (assign, nonatomic) NSInteger completedRate;    // 完成的进度
@property (assign, nonatomic) NSInteger baodiRate;        // 保底比例

@property (strong, nonatomic) UIColor *completedColor;
@property (strong, nonatomic) UIColor *incompletedColor;

@property (assign, nonatomic) CGFloat thickness;

@property (strong, nonatomic) UIColor *sliceDividerColor;
@property (assign, nonatomic) BOOL sliceDividerHidden;
@property (assign, nonatomic) NSUInteger sliceDividerThickness;

@end
