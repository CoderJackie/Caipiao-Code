//
//  DialogPassWayView.m 购彩大厅－竞彩投注－过关方式
//  TicketProject
//
//  Created by sls002 on 13-7-2.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//
//20141014 15:23（洪晓彬）：修改代码规范，改进生命周期，内存整理
//20141014 15:32（洪晓彬）：进行ipad适配

#import "DialogPassWayView.h"
#import "CustomSegmentedControl.h"
#import "SelectFreePassView.h"
#import "SelectMixPassView.h"
#import "PassWayUtility.h"
#import "MatchTypeButton.h"

#import "Globals.h"

#pragma mark -
#pragma mark @implementation DialogPassWayView
@implementation DialogPassWayView
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame MatchCount:(NSInteger)count {
    self = [super initWithFrame:frame];
    if (self) {
        _matchCount = count;
        
        [self createSubViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame MatchCount:(NSInteger)count danCount:(NSInteger)danCount playID:(NSInteger)playID playType:(NSInteger)playType {
    self = [super initWithFrame:frame];
    if (self) {
        _matchCount = count;
        _danCount = danCount;
        _playID = playID;
        _playType = playType;
        [self createSubViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame MatchCount:(NSInteger)count danCount:(NSInteger)danCount {
    self = [super initWithFrame:frame];
    if (self) {
        _matchCount = count;
        _danCount = danCount;
        [self createSubViews];
    }
    return self;
}

- (void)dealloc {
    [_overlayView release];
    _overlayView = nil;
    _freePassView = nil;
    _mixPassView = nil;
    
    [_selectPassWayTagArray release];
    
    [super dealloc];
}

- (void)createSubViews {
    _overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, [UIScreen mainScreen].bounds.size.height - self.frame.size.height)];
    [_overlayView setBackgroundColor:[UIColor blackColor]];
    [_overlayView setAlpha:0.5];
    
    _passTypeScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    [self addSubview:_passTypeScrollView];
    [_passTypeScrollView release];

    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setClipsToBounds:YES];
    
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat segmentedHeight = IS_PHONE ? 35.0f : 52.5f;
    
    CGFloat lineWidth = IS_PHONE ? 10.0f : 20.0f;
    
//    CGFloat okCancelBtnHeight = IS_PHONE ? 35.0f : 60.0f;
    CGFloat selectBtnHeight = IS_PHONE ? 31.0f : 46.5f;
    CGFloat passViewMaginTopBottom = IS_PHONE ? 10.0f : 14.0f; //整个选择视图与父视图的上下间距
    /********************** adjustment end ***************************/
    
    CGRect lableRect = CGRectMake(lineWidth, 8, CGRectGetWidth(self.frame) - 100, segmentedHeight);
    UILabel *lable = [[UILabel alloc] initWithFrame:lableRect];
    [lable setBackgroundColor:[UIColor clearColor]];
    [lable setText:@"标准过关"];
    [lable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [_passTypeScrollView addSubview:lable];
    [lable release];
    
//    //okBtn
//    CGRect okBtnRect = CGRectMake(CGRectGetMaxX(lableRect), CGRectGetMinY(lableRect), 80, okCancelBtnHeight);
//    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [okBtn setFrame:okBtnRect];
//    [okBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
//    [okBtn setTitle:@"收起" forState:UIControlStateNormal];
//    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//    [okBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f]] forState:UIControlStateNormal];
//    [okBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f]] forState:UIControlStateHighlighted];
//    [okBtn addTarget:self action:@selector(okBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [_passTypeScrollView addSubview:okBtn];
    
    NSArray *freePassArray = [NSArray array];
    
    if (_playID == 45) {
        freePassArray = [PassWayUtility getFreePassItemsWithMatchCount:_matchCount danCount:_danCount playID:_playID playType:_playType];
        
    } else {
        freePassArray = [PassWayUtility getFreePassItemsWithMatchCount:_matchCount danCount:_danCount];
    }
    
    //freePassView
    CGRect freePassViewRect = CGRectMake(0, CGRectGetMaxY(lableRect), CGRectGetWidth(self.frame), (freePassArray.count > 4 ? (freePassArray.count == 8 ? freePassArray.count / 4 : (freePassArray.count == 12 ? freePassArray.count / 4 : freePassArray.count / 4 + 1)) * (passViewMaginTopBottom + selectBtnHeight) : (passViewMaginTopBottom + selectBtnHeight)));
    _freePassView = [[SelectFreePassView alloc]initWithFrame:freePassViewRect Items:freePassArray];
    _freePassView.delegate = self;
    [_passTypeScrollView addSubview:_freePassView];
    [_freePassView release];
    
    NSArray *mixPassArray = [NSArray array];
    
    if (_playID == 45) {
        if (_playType == 4501 || _playType == 4502 || _playType == 4503 || _playType == 4505) {
            if (_matchCount > 6) {
                _matchCount = 6;
            }
        } else if (_playType == 4504) {
            if (_matchCount > 3) {
                _matchCount = 3;
            }
        } else {
            _matchCount = 0;
        }
        mixPassArray = [PassWayUtility getMixPassItemsWithMatchCount:_matchCount danCount:_danCount playType:_playType];
    } else {
        mixPassArray = [PassWayUtility getMixPassItemsWithMatchCount:_matchCount danCount:_danCount];
    }
    
    
    if (mixPassArray.count > 0) {
        CGRect lableRect2 = CGRectMake(lineWidth, CGRectGetMaxY(freePassViewRect) + 18, CGRectGetWidth(self.frame), segmentedHeight / 2.0f - 8);
        UILabel *lable2 = [[UILabel alloc] initWithFrame:lableRect2];
        [lable2 setBackgroundColor:[UIColor clearColor]];
        [lable2 setText:@"组合过关"];
        [lable2 setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [_passTypeScrollView addSubview:lable2];
        [lable2 release];
        
        //mixPassView
        CGRect mixPassViewRect = CGRectMake(0, CGRectGetMaxY(lableRect2), CGRectGetWidth(self.frame),(mixPassArray.count > 4 ? (mixPassArray.count > 5 ? 5 : (mixPassArray.count / 4 + 1)) * (passViewMaginTopBottom +  selectBtnHeight) : (passViewMaginTopBottom * 2 +  selectBtnHeight)) + 20);
        _mixPassView = [[SelectMixPassView alloc]initWithFrame:mixPassViewRect Items:mixPassArray];
        [_mixPassView setDelegate:self];
        [_passTypeScrollView addSubview:_mixPassView];
        [_mixPassView release];
        
    } else {
        //mixPassView
        CGRect mixPassViewRect = CGRectMake(0, 0, CGRectGetWidth(self.frame),0);
        _mixPassView = [[SelectMixPassView alloc]initWithFrame:mixPassViewRect Items:mixPassArray];
        [_mixPassView setDelegate:self];
        [_passTypeScrollView addSubview:_mixPassView];
        [_mixPassView release];
    }
    
}


#pragma mark -
#pragma mark -Delegate
#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == 1010) {
        NSInteger page = scrollView.contentOffset.x/CGRectGetWidth(self.frame);
        [_matchTypeCustomSegmentedControl setSelectedSegmentIndex:page];
        
    }
    
}
#pragma mark -SelectFreePassViewDelegate
//反选多串过关
- (void)freePassButtonDidSelected {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    for (UIView *view in _mixPassView.subviews) {
        if([view isKindOfClass:[UIScrollView class]]) {
            for (UIView *subView in view.subviews) {
                if([subView isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)subView;
                    [btn setSelected:NO];
                }
            }
        }
    }
    
    [dic setObject:_freePassView.selectItems forKey:@"selectPassWay"];
    [dic setObject:_freePassView.selectItemTags forKey:@"selectPassTag"];
    [dic setObject:[NSString stringWithFormat:@"%d",FreePassWay] forKey:@"selectPassWayType"];
    
    if(_delegate && [_delegate respondsToSelector:@selector(viewDidSelectedPassWay:)]) {
        [_delegate viewDidSelectedPassWay:dic];
    }
}

#pragma mark -SelectMixPassViewDelegate
//反选自由过关
- (void)mixPassButtonDidSelected {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    for (UIView *view in _freePassView.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            [btn setSelected:NO];
        }
    }
    
    [dic setObject:_mixPassView.selectItems forKey:@"selectPassWay"];
    [dic setObject:_mixPassView.selectItemTags forKey:@"selectPassTag"];
    [dic setObject:[NSString stringWithFormat:@"%d",MixPassWay] forKey:@"selectPassWayType"];
    
    if(_delegate && [_delegate respondsToSelector:@selector(viewDidSelectedPassWay:)]) {
        [_delegate viewDidSelectedPassWay:dic];
    }
}

#pragma mark -
#pragma mark -Customized(Action)
//确认
- (void)okBtnClick:(id)sender {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    //获得选择的过关方式
    NSArray *selectPassWay = _freePassView.selectItems;
    if(selectPassWay.count == 0) {
        self.selectPassWayType = MixPassWay;
        
        selectPassWay = _mixPassView.selectItems;
    } else {
        self.selectPassWayType = FreePassWay;
    }
    
    NSArray *selectPassTag = _freePassView.selectItemTags;
    if(selectPassTag.count == 0) {
        selectPassTag = _mixPassView.selectItemTags;
    }
    
    [dic setObject:selectPassWay forKey:@"selectPassWay"];
    [dic setObject:selectPassTag forKey:@"selectPassTag"];
    [dic setObject:[NSString stringWithFormat:@"%d",_selectPassWayType] forKey:@"selectPassWayType"];
    
    if(_delegate && [_delegate respondsToSelector:@selector(viewDidSelectedPassWay:)]) {
        [_delegate viewDidSelectedPassWay:dic];
    }
    
    [self fadeOut];
}

- (void)cancelBtnClick:(id)sender {
    [self fadeOut];
}

- (void)matchTypeChanged:(id)sender {
    CustomSegmentedControl *customSegmentedControl = sender;
    
    switch (customSegmentedControl.selectedSegmentIndex) {
        case 0:
            [_passTypeScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            break;
        case 1:
            [_passTypeScrollView setContentOffset:CGPointMake(kWinSize.width, 0) animated:YES];
            break;
            
        default:
            break;
    }
}

#pragma mark -Customized: Private (General)
//过关方式的反选
- (void)setSelectPassWayTagArray:(NSArray *)selectPassWayTagArray {
    if(![selectPassWayTagArray isEqualToArray:_selectPassWayTagArray] && selectPassWayTagArray) {
        [_selectPassWayTagArray release];
        _selectPassWayTagArray = [selectPassWayTagArray retain];
        
        for (NSString *str in _selectPassWayTagArray) {
            int tag = [str intValue];
            
            if(_selectPassWayType == FreePassWay) {
                UIButton *btn = (UIButton *)[_freePassView viewWithTag:tag];
                [btn setSelected:YES];
            } else {
                for (UIView *view in _mixPassView.subviews) {
                    if([view isKindOfClass:[UIScrollView class]]) {
                        UIButton *btn = (UIButton *)[view viewWithTag:tag];
                        [btn setSelected:YES];
                    }
                }
            }            
        }
    }
}

- (void)updateSelectPassWay:(NSArray*)arr {
    if (self.selectPassWayType == FreePassWay) {
        [_freePassView updateSelectPassWay:arr];
    } else {
        [_mixPassView updateSelectPassWay:arr];
    }
}

- (void)fadeIn {
    [self setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
    [self setAlpha:0];
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [self setAlpha:1.0];
    [self setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    [UIView commitAnimations];
}

- (void)fadeOut {
    [self setHidden:YES];
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self setAlpha:0];
    [self setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
    [UIView commitAnimations];
    
    [_overlayView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_overlayView];
    [keyWindow addSubview:self];
    
    [self fadeIn];
}

@end
