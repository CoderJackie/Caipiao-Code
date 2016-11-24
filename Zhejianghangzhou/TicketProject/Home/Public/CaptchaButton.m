//
//  CaptchaButton.m   验证码按钮
//  TicketProject
//
//  Created by KAI on 15-1-22.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "CaptchaButton.h"
#import "Globals.h"

@implementation CaptchaButton
@synthesize captchaString = _captchaString;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self makeSubView];
        [self addTarget:self action:@selector(createCaptchaTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)dealloc {
    [_captchaString release];
    _captchaString = nil;
    _captchaLabel = nil;
    [super dealloc];
}

- (void)makeSubView {
    _captchaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [_captchaLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_captchaLabel];
    [_captchaLabel release];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self createCaptcha];
}


- (void)createCaptcha {
    for (UIView *view in _captchaLabel.subviews) {
        [view removeFromSuperview];
    }
    
    CGRect captchaLabelRect = _captchaLabel.frame;
  
    NSInteger count = 4;
    char data[count];
    for (int x = 0; x < count; x++) {
        int j = 'a' + (arc4random_uniform(26));
        data[x] = (char)j;
    }
    NSString *text = [[NSString alloc] initWithBytes:data length:count encoding:NSUTF8StringEncoding];
    [_captchaString release];
    _captchaString = [text copy];
    [text release];
    
    CGFloat pX, pY;
    for (NSInteger i = 0, count = _captchaString.length; i < count; i++) {
        
        //随机字体大小
        NSInteger randomfontSize = arc4random() % 5 + XFIponeIpadFontSize17;
        
        // 随机字体颜色
        CGFloat red = arc4random() % 100 / 100.0;
        CGFloat green = arc4random() % 100 / 100.0;
        CGFloat blue = arc4random() % 100 / 100.0;
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        
        //计算单字符可显示的随机位置的宽高度
        CGSize cSize = [@"S" sizeWithFont:[UIFont systemFontOfSize:randomfontSize]];
        NSInteger width = CGRectGetWidth(captchaLabelRect) / _captchaString.length - cSize.width;
        NSInteger height = CGRectGetHeight(captchaLabelRect) - cSize.height;
        
        //随机显示单字符label的位置
        pX = arc4random() % width + CGRectGetWidth(captchaLabelRect) / _captchaString.length * i - 1;
        pY = arc4random() % (height);
        
        //随机字体样式   0为正常  1为粗体  2为斜体   其他为其他字体
        NSInteger fontType = 0;
        fontType = arc4random() % 100;
        
        //获取字符
        unichar c = [_captchaString characterAtIndex:i];
        NSString *textC = [NSString stringWithFormat:@"%C", c];
        
        //添加
        //tempLabel
        CGRect tempLabelRect = CGRectMake(pX, pY, CGRectGetWidth(captchaLabelRect) / 4 + 4.0f, randomfontSize + 5.0f);
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:tempLabelRect];
        [tempLabel setBackgroundColor:[UIColor clearColor]];
        [tempLabel setTextColor:color];
        [tempLabel setText:textC];
        if (fontType == 0) {
            [tempLabel setFont:[UIFont systemFontOfSize:randomfontSize]];
            
        } else if (fontType == 1) {
            [tempLabel setFont:[UIFont boldSystemFontOfSize:randomfontSize]];
            
        } else if (fontType == 2) {
            [tempLabel setFont:[UIFont italicSystemFontOfSize:randomfontSize]];
            
        } else {
            //随机字体
            NSArray *familyNameArray = [UIFont familyNames];
            NSInteger familyNameRandomIndex = arc4random() % [familyNameArray count];
            NSArray *fontNameArray = [UIFont fontNamesForFamilyName:[familyNameArray objectAtIndex:familyNameRandomIndex]];
            NSInteger fontNameRandomIndex = arc4random() % [fontNameArray count];
            [tempLabel setFont:[UIFont fontWithName:[fontNameArray objectAtIndex:fontNameRandomIndex] size:randomfontSize]];
        }
        [_captchaLabel addSubview:tempLabel];
        [tempLabel release];
    }
}

- (void)createCaptchaTouchUpInside:(id)sender {
    [self createCaptcha];
}

- (BOOL)verificationCaptchaWithCaptcha:(NSString *)captcha {
    if ([captcha isEqualToString:_captchaString]) {
        return YES;
    }
    return NO;
}

@end
