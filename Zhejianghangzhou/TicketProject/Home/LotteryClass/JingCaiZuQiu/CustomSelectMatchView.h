//
//  CustomSelectMatchView.h
//  TicketProject
//
//  Created by sls002 on 13-6-28.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSelectMatchView : UIView {
    UIScrollView   *_scrollView;
    NSMutableArray *_selectMatchText;
    NSMutableArray *_selectMatchTags;
    
    NSArray *_matchItems;
}

@property (nonatomic,retain) NSMutableDictionary *selectedMatchesDic; //选中的比赛

- (id)initWithFrame:(CGRect)frame MatchItems:(NSArray *)items;

- (void)selectAllMatch;

- (void)selectNon;

- (void)setSelectedMatches:(NSDictionary *)selectedMatchesDic;

- (void)selectedFan;

@end
