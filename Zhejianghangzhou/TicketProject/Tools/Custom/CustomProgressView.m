//
//  CustomProgressView.m  自定义颜色的进度条
//  CarPooling
//
//  Created by KAI on 15-1-31.
//  Copyright (c) 2015年 KAI. All rights reserved.
//

#import "CustomProgressView.h"

@implementation CustomProgressView

#pragma mark Lifecircle
- (id)initWithProgressViewStyle:(UIProgressViewStyle)style {
    if (self=[super initWithProgressViewStyle: style]) {
        [self setTintColor: [UIColor colorWithRed: 43.0/255.0 green: 134.0/255.0 blue: 225.0/255.0 alpha: 1]];
    }
    return self;
}

- (void)dealloc {
    [_tintColor release];
    [_bgColor release];
    [super dealloc];
}

#pragma mark customized: Public (general)
- (void) setTintColor: (UIColor *) aColor{
    if(![_tintColor isEqual:aColor]) {
        [_tintColor release];
        _tintColor = [aColor retain];
    }
}

- (void)setBgColor:(UIColor *)aColor {
    if (![_bgColor isEqual:aColor]) {
        [_bgColor release];
        _bgColor = [aColor retain];
    }
}

#pragma mark customized: Private (general)
- (void)drawRect:(CGRect)rect {
    if ([self progressViewStyle] == UIProgressViewStyleDefault) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        //给背景画上cap
        [self addRoundedRectToPath:ctx rect:rect ovalWidth:5 ovalHeight:5];
        CGContextClip(ctx);
        CGContextSetFillColorWithColor(ctx, (_bgColor? _bgColor.CGColor: [UIColor clearColor].CGColor));
        CGContextFillRect(ctx, rect);
        
        //设置进度条长度
        CGRect progressRect = rect;
        progressRect.size.width *= [self progress];
        
        //画进度条cap
        [self addRoundedRectToPath:ctx rect:progressRect ovalWidth:5 ovalHeight:5];
        CGContextClip(ctx);
        CGContextSetFillColorWithColor(ctx, _tintColor.CGColor);
        CGContextFillRect(ctx, progressRect);
        
        progressRect.size.width -= 1.25;
        progressRect.origin.x += 0.625;
        progressRect.size.height -= 1.25;
        progressRect.origin.y += 0.625;
        
        [self addRoundedRectToPath:ctx rect:progressRect ovalWidth:5 ovalHeight:5];
        CGContextClip(ctx);
        CGContextSetLineWidth(ctx, 1);
        CGContextSetRGBStrokeColor(ctx, 20.0/255.0, 20.0/255.0, 20.0/255.0, 0.6);
        CGContextStrokeRect(ctx, progressRect);
        
        //给进度条画上斜度
        CGRect upperhalf = rect;
        upperhalf.size.height /= 1.75;
        upperhalf.origin.y = 0;
        [self fillRectWithLinearGradient:ctx rect:upperhalf];
    } else {
        [super drawRect: rect];
    }
}

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect ovalWidth:(float)ovalWidth ovalHeight:(float)ovalHeight{
    float fw, fh;
    
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    
    CGContextClosePath(context);
    
    CGContextRestoreGState(context);
}

-(void)fillRectWithLinearGradient:(CGContextRef)context rect:(CGRect)rect{
    CGFloat colors[8] = {1, 1, 1, 0.45,1, 1, 1, 0.75};
    
    CGContextSaveGState(context);
    
    if(!CGContextIsPathEmpty(context))
        CGContextClip(context);
    
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPoint start = CGPointMake(0, 0);
    CGPoint end = CGPointMake(0, rect.size.height);
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, nil, 2);
    CGContextDrawLinearGradient(context, gradient, end, start, 0);
    CGContextRestoreGState(context);
    
    CGColorSpaceRelease(space);
    CGGradientRelease(gradient);
}

@end