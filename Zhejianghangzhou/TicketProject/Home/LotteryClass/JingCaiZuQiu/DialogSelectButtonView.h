//
//  DialogSelectButtonView.h
//  TicketProject
//
//  Created by KAI on 14-11-13.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogSelectButtonViewDetegate.h"

@interface DialogSelectButtonView : UIView {
    UIView       *_overlayView;
    
    UILabel      *_mainTeamLabel;
    UILabel      *_guestTeamLabel;
    UIView       *_redLineView;
    
    UIScrollView *_selectButtonScrollView;
    
    UILabel      *_letSecondPromptLabel;
    UILabel      *_scoreSecondPromptLabel;
    
    UIButton     *_confirmBtn;
    UIButton     *_cancelBtn;
    
    id<DialogSelectButtonViewDetegate> _delegate;
    DialogType _dialogType;
    BOOL       _selectButton;
    BOOL       _buildedSelectView;
    
    NSDictionary   *_matchDict;
    NSMutableArray *_selectMatchNumberArray;
    NSMutableArray *_selectMatchTextArray;
    
    NSIndexPath    *_selectMatchIndexPath;
    NSInteger      *_palyID;
}

@property (nonatomic, assign) id<DialogSelectButtonViewDetegate> delegate;
@property (nonatomic, assign) DialogType dialogType;
@property (nonatomic, retain) NSIndexPath *selectMatchIndexPath;
@property (nonatomic, retain) NSMutableArray *selectMatchNumberArray;

- (id)initWithFrame:(CGRect)frame matchDict:(NSDictionary *)matchDict;

- (id)initWithFrame:(CGRect)frame matchDict:(NSDictionary *)matchDict playID:(NSInteger)playID;

- (id)initWithMatchDict:(NSDictionary *)matchDict selectNumberArray:(NSMutableArray *)selectNumberArray;

- (void)setSelectMatchTextWithTextArray:(NSMutableArray *)textArray;

- (void)show;

@end
