//
//  DialogPassWayView.h
//  TicketProject
//
//  Created by sls002 on 13-7-2.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogPassWayViewDelegate.h"
#import "SelectFreePassViewDelegate.h"
#import "SelectMixPassViewDelegate.h"

@class CustomSegmentedControl;
@class SelectFreePassView;
@class SelectMixPassView;

@interface DialogPassWayView : UIView<SelectFreePassViewDelegate,SelectMixPassViewDelegate, UIScrollViewDelegate> {
    
    UIView                 *_overlayView;
    CustomSegmentedControl *_matchTypeCustomSegmentedControl;
    UIScrollView           *_passTypeScrollView;
    UIScrollView           *_freePassScrollView;
    UIScrollView           *_mixPassScrollView;
    
    
    SelectFreePassView *_freePassView;
    SelectMixPassView  *_mixPassView;
    
    id<DialogPassWayViewDelegate> _delegate;
    
    NSInteger _matchCount;
    NSInteger _danCount;
    NSInteger _playID;
    NSInteger _playType;
}

@property (nonatomic,assign) id<DialogPassWayViewDelegate> delegate;
@property (nonatomic,retain) NSArray *selectPassWayTagArray;
@property (nonatomic,assign) SelectPassWayType selectPassWayType;

- (id)initWithFrame:(CGRect)frame MatchCount:(NSInteger)count;
- (id)initWithFrame:(CGRect)frame MatchCount:(NSInteger)count danCount:(NSInteger)_danCount;
- (id)initWithFrame:(CGRect)frame MatchCount:(NSInteger)count danCount:(NSInteger)_danCount playID:(NSInteger)playID playType:(NSInteger)playType;
- (void)updateSelectPassWay:(NSArray*)arr;//更新过关方式的选择
- (void)show;
- (void)fadeOut;

@end
