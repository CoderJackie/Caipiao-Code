//
//  SafeProblemPopView.h
//  TicketProject
//
//  Created by sls002 on 13-6-18.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectSafeProblemViewDelegate.h"

@interface SafeProblemPopView : UIView<UITableViewDataSource,UITableViewDelegate> {
    
    UIView        *_overlayView;           /**< 底部 半透明的视图 */
    UITableView   *_safeProblemsTableView; /**<  */
    UIButton      *_previousSelectBtn;     /**< 上一个被选中的button */
    
    id<SelectSafeProblemViewDelegate> _delegate;
    
    NSInteger      _selectIndex;       /**< 原来选择的安全问题的下标 */
    NSMutableDictionary *_questionDic;  /**< 问题字典 */
}

@property (nonatomic,assign) id<SelectSafeProblemViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame SelectIndex:(NSInteger)index;

-(void)show;

@end
