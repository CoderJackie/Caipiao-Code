//
//  CustomTabBarView.m
//  TicketProject
//
//  Created by sls002 on 13-7-8.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140904 08:40（洪晓彬）：进行ipad适配

#import "CustomTabBarView.h"
#import "XFTabBarItem.h"

#import "Globals.h"

#define kTabBarLabelSelectColor [UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]
#define kTabBarLabelNormalColor [UIColor colorWithRed:0x57/255.0f green:0x51/255.0f blue:0x5d/255.0f alpha:1.0f]

@implementation CustomTabBarView
@synthesize selectRectImage = _selectRectImage;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backImage = [[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"tab.png"]] retain];
    }
    return self;
}

- (void)setItems:(NSArray *)items {
    [_items release];
    _items = [items copy];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat shadeHeight = IS_PHONE ? 3.0f : 6.0f;
    
    CGFloat btnItemMinX = IS_PHONE ? 22.5f : 45.0f;
    CGFloat btnItemMinY = IS_PHONE ? 3.5f : 0.0f;
    CGFloat btnItemSize = IS_PHONE ? 27.0f : 40.0f;//选项卡图片按钮宽度
    CGFloat itemMagin = (CGRectGetWidth(self.frame) - items.count * btnItemSize - btnItemMinX * 2) / (items.count - 1) ;//间隔距离
    
    CGFloat titleLabelWidth = (btnItemSize + itemMagin) / 2.0f+10;
    /********************** adjustment end ***************************/
    //shadeImageView
    CGRect shadeImageViewRect = CGRectMake(0, -shadeHeight, kWinSize.width, shadeHeight);
    UIImageView *shadeImageView = [[UIImageView alloc] initWithFrame:shadeImageViewRect];
    [shadeImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"shade.png"]]];
    [self addSubview:shadeImageView];
    [shadeImageView release];
    
    for (int i = 0; i < items.count; i++) {
        XFTabBarItem *item = [items objectAtIndex:i];
        //btn 背景按钮
        CGRect btnRect = CGRectMake(btnItemMinX + (btnItemSize + itemMagin) * i, btnItemMinY, btnItemSize, btnItemSize);
        UIButton *btn = [[UIButton alloc] init];
        [btn setFrame:btnRect];
        [btn setBackgroundImage:item.normalImage forState:UIControlStateNormal];
        [btn setBackgroundImage:item.selectImage forState:UIControlStateSelected];
        [btn setBackgroundImage:item.selectImage forState:UIControlStateSelected | UIControlStateHighlighted];
        [btn setAdjustsImageWhenHighlighted:NO];
        [btn setAdjustsImageWhenDisabled:NO];
        [btn setTag:i + 1];
        [btn addTarget:self action:@selector(viewControllerSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn release];
        
        //titleLabel 标题
        CGRect titleLabelRect = CGRectMake(CGRectGetMidX(btnRect) - titleLabelWidth / 2.0f, CGRectGetMaxY(btnRect), titleLabelWidth, CGRectGetHeight(self.frame) - CGRectGetMaxY(btnRect));
        if (item.title.length>2) {//大于两个字时的临时处理
            titleLabelRect.origin.x -= 15 ;
            titleLabelRect.size.width += 30;
        }
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleLabelRect];
        [titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [titleLabel setTextColor:[UIColor colorWithRed:0x57/255.0f green:0x51/255.0f blue:0x5d/255.0f alpha:1.0f]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTag:i + 11];
        [titleLabel setText:item.title];
        [self addSubview:titleLabel];
        [titleLabel release];
        
    }
    
}

- (void)setSelectItemIndex:(NSInteger)selectItemIndex {
    UIButton *btn = (UIButton *)[self viewWithTag:selectItemIndex];
    [self setLabelColorWithButtonTag:btn.tag];
    [btn setSelected:YES];
}

- (void)viewControllerSelected:(id)sender {
    UIButton *btn = sender;
    [self setLabelColorWithButtonTag:btn.tag];
    
    if (_delegate && [_delegate respondsToSelector:@selector(itemDidSelectedAtIndex:)]) {
        [_delegate itemDidSelectedAtIndex:btn.tag];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    NSInteger index = (NSInteger)(touchLocation.x / (kWinSize.width / _items.count)) % _items.count + 1;
    
    _touchIndex = index;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    NSInteger index = (NSInteger)(touchLocation.x / (kWinSize.width / _items.count)) % _items.count + 1;
    if (_touchIndex == index) {
        UIButton *btn = (UIButton *)[self viewWithTag:index];
        [self viewControllerSelected:btn];
    }
}

- (void)setLabelColorWithButtonTag:(NSInteger)buttonTag {
    for (NSInteger i = 0; i < [_items count]; i++) {
        UILabel *label = (UILabel *)[self viewWithTag:(i + 11)];
        [label setTextColor:kTabBarLabelNormalColor];
    }
    UILabel *label = (UILabel *)[self viewWithTag:buttonTag + 10];
    [label setTextColor:kTabBarLabelSelectColor];
}

- (void)drawRect:(CGRect)rect {
    if(_backImage) {
        [_backImage drawInRect:rect];
    } else {
        [super drawRect:rect];
    }
}

- (void)dealloc {
    [_backImage release];
    _backImage = nil;
    [_items release];
    _items = nil;
    [_selectRectImage release];
    _selectRectImage = nil;
    
    [super dealloc];
}

@end
