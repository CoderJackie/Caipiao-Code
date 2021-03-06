//
//  customLabel.m
//  CoreTextMagazine
//
//  Created by zyq on 13-4-27.
//  Copyright (c) 2013年 zyq. All rights reserved.
//

#import "CustomLabel.h"

@implementation CustomLabel
@synthesize attString = _attString;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    if (_attString != nil) {
        [_attString release];
        _attString = nil;
    }
    [super dealloc];
}

- (void)setAttString:(NSAttributedString *)attString {
    if (![_attString isEqual:attString] && attString.length != 0) {
         [_attString release];
        _attString = [attString copy];
      
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();//注，像许多低级别的API，核心文本使用的Y翻转坐标系 更杯具的是，内容是也渲染的翻转向下！
    //手动翻转,注，每次使用可将下面三句话复制粘贴过去。必用
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();//1,外边框。mac支持矩形和圆，ios仅支持矩形。本例中使用self.bounds作为path的reference
    CGPathAddRect(path, NULL, self.bounds);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attString);//3CTFramesetter是最重要的类时使用的绘图核心文本。管理您的字体引用和绘制文本框。就目前而言，你需要知道什么是CTFramesetterCreateWithAttributedString为您将创建一个CTFramesetter的，保留它，并使用附带的属性字符串初始化。在本节中，你有framesetter后你创建一个框架，你给CTFramesetterCreateFrame，呈现了一系列的字符串（我们选择这里的整个字符串）和矩形绘制文本时会出现。
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_attString length]), path, NULL);
    CTFrameDraw(frame, context);//4绘制
    
    CGPathRelease(path);

}


@end
