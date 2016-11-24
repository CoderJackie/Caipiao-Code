//
//  CustomProgressView.h
//  CarPooling
//
//  Created by KAI on 15-1-31.
//  Copyright (c) 2015年 KAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomProgressView : UIProgressView {
    UIColor *_tintColor;
    UIColor *_bgColor;
}

- (void)setTintColor:(UIColor *)aColor;

- (void)setBgColor:(UIColor *)aColor;

@end