//
//  CustomSegmentedControl.m   自定义SegmentedControl
//  TicketProject
//
//  Created by sls002 on 13-5-28.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//

#import "CustomSegmentedControl.h"

#import "Globals.h"

@implementation CustomSegmentedControl

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)items {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSegmentItems:items];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)items normalImageName:(NSString *)normalImageName selectImageName:(NSString *)selectImageName {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithSegmentItems:items normalImageName:normalImageName selectImageName:selectImageName];
    }
    
    return self;
}

- (void)dealloc {
    [_backImage release];
    [super dealloc];
}

- (void)initSegmentItems:(NSArray *)items {
    for (int i = 0; i < items.count; i++) {
        [self insertSegmentWithTitle:[items objectAtIndex:i] atIndex:i animated:NO];
    }
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f]] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blackLineAngleButton.png"]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f],UITextAttributeTextColor,[UIFont systemFontOfSize:XFIponeIpadFontSize10],UITextAttributeFont, nil] forState:UIControlStateNormal];
    
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,[UIFont systemFontOfSize:XFIponeIpadFontSize10],UITextAttributeFont, nil] forState:UIControlStateSelected];
    
    [self setBackgroundColor:[UIColor clearColor]]; 
    [self setTintColor:[UIColor colorWithRed:186.0f/255.0f green:186.0f/255.0f blue:186.0f/255.0f alpha:1.0f]];
}

- (void)initWithSegmentItems:(NSArray *)items normalImageName:(NSString *)normalImageName selectImageName:(NSString *)selectImageName {
    for (int i = 0; i < items.count; i++) {
        [self insertSegmentWithTitle:[items objectAtIndex:i] atIndex:i animated:NO];
    }
    
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,[UIFont systemFontOfSize:XFIponeIpadFontSize12],UITextAttributeFont, nil] forState:UIControlStateNormal];
    
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0xff/255.0f green:0x8a/255.0f blue:0x00/255.0f alpha:1.0f],UITextAttributeTextColor,[UIFont systemFontOfSize:XFIponeIpadFontSize12],UITextAttributeFont, nil] forState:UIControlStateSelected];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setTintColor:[UIColor whiteColor]];
    
    [self setBackgroundImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[[UIImage imageNamed:selectImageName] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[[UIImage imageNamed:selectImageName] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[[UIImage imageNamed:selectImageName] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[[UIImage imageNamed:selectImageName] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateApplication barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[[UIImage imageNamed:selectImageName] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateReserved barMetrics:UIBarMetricsDefault];
}

- (void)setSegmentTitleColor:(UIColor *)color forState:(UIControlState)state {
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:color,UITextAttributeTextColor,[UIFont systemFontOfSize:XFIponeIpadFontSize12],UITextAttributeFont, nil] forState:state];
}

@end
