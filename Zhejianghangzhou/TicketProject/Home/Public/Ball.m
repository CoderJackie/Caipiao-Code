//
//  BallInitalize.m 选号球
//  TicketProject
//
//  Created by sls002 on 13-5-20.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140912 10:03（洪晓彬）：修改代码规范

#import "Ball.h"

#import "Globals.h"

@implementation Ball

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(id)initWithType:(BallsType)types Title:(NSString *)title {
    self = [super init];
    if(self) {
        _type = types;
        
        switch (_type) {
            case Red:
                [self initRedBalls];
                
                [self setTitleColor:[UIColor colorWithRed:0xe5/255.0f green:0x2c/255.0f blue:0x27/255.0 alpha:1.0] forState:UIControlStateNormal];
                [self setTitleColor:[UIColor colorWithRed:187.0/255.0 green:48.0/255.0 blue:65.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
                [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                break;
            case Blue:
                [self initBlueBalls];
                
                [self setTitleColor:[UIColor colorWithRed:0x00/255.0f green:0x74/255.0f blue:0xf0/255.0f alpha:1.0] forState:UIControlStateNormal];
                [self setTitleColor:[UIColor colorWithRed:14.0/255.0 green:86.0/255.0 blue:176.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
                [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

            default:
                break;
        }
        
        [self setBackgroundImage:_normalImage forState:UIControlStateNormal];
        [self setBackgroundImage:_selectedImage forState:UIControlStateSelected];
        [self setBackgroundImage:_highlightedImage forState:UIControlStateHighlighted];
        [self setBackgroundImage:_highlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
        
        [self.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize16]];//设置字体大小
                
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitle:title forState:UIControlStateHighlighted];
        [self setTitle:title forState:UIControlStateSelected];
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)initRedBalls {
    _normalImage = [UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redBall_Normal.png"]];
    _highlightedImage = [UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redBall_Select.png"]];
    _selectedImage = [UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redBall_Select.png"]];
}

- (void)initBlueBalls {
    _normalImage = [UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blueBall_Normal.png"]];
    _highlightedImage = [UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blueBall_Select.png"]];
    _selectedImage = [UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blueBall_Select.png"]];
}

- (void)drawRect:(CGRect)rect {
    if(_normalImage) {
        [_normalImage drawInRect:rect];
    }
}

- (void)dealloc {
    [super dealloc];
}

@end
