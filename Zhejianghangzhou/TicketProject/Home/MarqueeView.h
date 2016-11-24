//
//  LED_View.h   中奖框
//  AllFrameWorkTest
//
//  Created by james on 11-9-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MarqueeView : UIView {
    UILabel  *_lable;
    
	NSString *_string;
	UIFont   *_font;
	UIColor  *_color;
}

- (id)initWithFrame:(CGRect)frame withContent:(NSString *)str withFont:(UIFont*)font withColor:(UIColor *)color;
- (void)startAnimation;
- (void)stopAnimation;
- (void)updateSelfText;
- (void)updateText:(NSString *)str;

@end
