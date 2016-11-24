//
//  DialogFilterMatchView.h
//  TicketProject
//
//  Created by sls002 on 13-6-28.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogFilterMatchViewDelegate.h"

@class CustomSelectMatchView;

@interface DialogFilterMatchView : UIView {
    
    UIView                *_overlayView;
    CustomSelectMatchView *_selectMatchView;
    
    id<DialogFilterMatchViewDelegate> _delegate;
    
    NSArray *_matchItems;
}

@property (nonatomic,assign) id<DialogFilterMatchViewDelegate> delegate;
@property (nonatomic,retain) NSDictionary *filterMatchDic; //筛选过滤的比赛
@property (nonatomic,assign) NSInteger selectLetBallType; //筛选 的让球方式

- (id)initWithFrame:(CGRect)frame MatchItems:(NSArray *)items;

- (void)show;

@end
