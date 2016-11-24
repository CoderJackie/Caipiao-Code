//
//  SelectLotteryNameDialogView.h 合买大厅彩种筛选
//  TicketProject
//
//  Created by sls002 on 13-7-29.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownListViewDelegate.h"

@interface SelectLotteryNameDialogView : UIView {
    UIView   *_overlayView;
    UIWindow *_keyWindow;
    
    NSMutableArray *_nameArray; /**< 所有彩种的名称 */
    NSMutableArray *_idArray;   /**< 彩种id */
}

@property (nonatomic, assign, readonly) NSMutableArray *nameArray; //所有彩种的名称
@property (nonatomic, assign, readonly) NSMutableArray *idArray; //彩种id

@property (nonatomic,assign) id <DropDownListViewDelegate> delegate;

- (id)initWithPlayMethodNames:(NSArray *)playNames lottery:(NSString *)lotteryName withIndex:(NSInteger)index;
/** 显示筛选按钮 */
- (void)show;

@end
