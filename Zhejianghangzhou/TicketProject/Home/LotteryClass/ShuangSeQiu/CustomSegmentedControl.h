//
//  CustomSegmentedControl.h
//  TicketProject
//
//  Created by sls002 on 13-5-28.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSegmentedControl : UISegmentedControl

@property (nonatomic,retain) UIImage *backImage;

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)items;

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)items normalImageName:(NSString *)normalImageName selectImageName:(NSString *)selectImageName;

- (void)setSegmentTitleColor:(UIColor *)color forState:(UIControlState)state;

@end
