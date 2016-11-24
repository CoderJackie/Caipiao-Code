//
//  MDRadialProgressView.m 进度视图
//  MDRadialProgress
//
//  Created by Marco Dinacci on 25/03/2013.
//  Copyright (c) 2013 Marco Dinacci. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MDRadialProgressView.h"


@implementation MDRadialProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
    }
    return self;
}

- (void)dealloc {
    [self.completedColor release];
    [self.incompletedColor release];
    [self.sliceDividerColor release];
    [super dealloc];
}

- (void)awakeFromNib {
    [self internalInit];
}

- (void)internalInit {
    // Default values
    self.completedColor = [UIColor colorWithRed:251.0f/255.0f green:159.0f/255.0f blue:29.0f/255.0f alpha:1.0f];
    self.incompletedColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    self.sliceDividerColor = [UIColor colorWithRed:236/255.0 green:235/255.0 blue:232/255.0 alpha:1];
    self.thickness = 40;
    self.sliceDividerHidden = NO;
    self.sliceDividerThickness = 2;
}

- (void)drawSlices:(NSUInteger)slicesCount completed:(NSUInteger)slicesCompleted radius:(CGFloat)circleRadius center:(CGPoint)center inContext:(CGContextRef)context {
	// Completed slices
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, center.x, center.y);
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = self.completedRate * (M_PI/180) - M_PI_2;
    if (endAngle < 0) {
        endAngle = 0;
    }
    CGContextAddArc(context, center.x, center.y, circleRadius, startAngle, endAngle, 0);
    CGColorRef color = self.completedColor.CGColor;
    CGContextSetFillColorWithColor(context, color);
    CGContextFillPath(context);
    
    // Baodi slices
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, center.x, center.y);
    startAngle = endAngle;
    endAngle = self.baodiRate * (M_PI/180) + endAngle;
    CGContextAddArc(context, center.x, center.y, circleRadius, startAngle, endAngle, 0);
    color = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor;
    CGContextSetFillColorWithColor(context, color);
    CGContextFillPath(context);
    
    if (self.completedRate + self.baodiRate < 360) {
        // Uncompleted slices
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, center.x, center.y);
        startAngle = endAngle;
        endAngle = - M_PI_2;
        CGContextAddArc(context, center.x, center.y, circleRadius, startAngle, endAngle, 0);
        color = self.incompletedColor.CGColor;
        CGContextSetFillColorWithColor(context, color);
        CGContextFillPath(context);
    }
}

- (void)drawRect:(CGRect)rect {
    if (self.progressTotal <= 0) {
        return;
    }
    
    // Draw the slices.
    
	CGSize viewSize = self.bounds.size;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGPoint center = CGPointMake(viewSize.width / 2, viewSize.height / 2);
    CGFloat radius = viewSize.width / 2;
    [self drawSlices:self.progressTotal
		   completed:self.progressCurrent
			  radius:radius
			  center:center
		   inContext:contextRef];
    
	// Draw the slice separators.
	
    int outerDiameter = viewSize.width;
    float outerRadius = outerDiameter / 2;
    int innerDiameter = outerDiameter - self.thickness;
    float innerRadius = innerDiameter / 2;
    
    if (! self.sliceDividerHidden) {
        NSInteger sliceCount = self.progressTotal;
        float sliceAngle = (2 * M_PI) / sliceCount;
        CGContextSetLineWidth(contextRef, self.sliceDividerThickness);
        CGContextSetStrokeColorWithColor(contextRef, self.sliceDividerColor.CGColor);
        for (int i = 0; i < sliceCount; i++) {
            double startAngle = sliceAngle * i - M_PI_2;
			double endAngle = sliceAngle * (i + 1) - M_PI_2;

			CGContextBeginPath(contextRef);
			CGContextMoveToPoint(contextRef, center.x, center.y);
			
			// Draw the outer arc
			CGContextAddArc(contextRef, center.x, center.y, outerRadius, startAngle, endAngle, 0);
			// Draw the inner arc. The separator line is drawn automatically when moving from
			// the point where the outer arc ended to the point where the inner arc starts.
			CGContextAddArc(contextRef, center.x, center.y, innerRadius, endAngle, startAngle, 1);
			
			CGContextSetStrokeColorWithColor(contextRef, self.sliceDividerColor.CGColor);
			CGContextStrokePath(contextRef);
        }
    }
    
    // Draw the inner circle to fake a hole in the middle.
    
    CGContextSetLineWidth(contextRef, self.thickness);
    CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
    CGRect circlePoint = CGRectMake(center.x - innerRadius, center.y - innerRadius,
                                    innerDiameter, innerDiameter);
    CGContextFillEllipseInRect(contextRef, circlePoint);
}


@end
