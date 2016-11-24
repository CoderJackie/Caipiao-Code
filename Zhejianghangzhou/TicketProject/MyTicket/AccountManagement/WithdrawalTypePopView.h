//
//  WithdrawalTypePopView.h
//  TicketProject
//
//  Created by kiu on 15/7/10.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectWithdrawalTypeViewDelegate <NSObject>

- (void)withdrawalTypeSelectedText:(NSString *)selectText AtRowIndex:(NSInteger)index;

@end

@interface WithdrawalTypePopView : UIView<UITableViewDataSource,UITableViewDelegate> {
    
    UIView        *_overlayView;           /**< 底部 半透明的视图 */
    UITableView   *_withdrawalTypeTableView; /**<  */
    UIButton      *_previousSelectBtn;     /**< 上一个被选中的button */
    
    id<SelectWithdrawalTypeViewDelegate> _delegate;
    
    NSInteger      _selectIndex1;        /**< 原来选择的借款类型的下标 */
    NSMutableDictionary *_questionDic;  /**< 问题字典 */
}

@property (nonatomic,assign) id<SelectWithdrawalTypeViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame SelectIndex:(NSInteger)index;

-(void)show;

@end
