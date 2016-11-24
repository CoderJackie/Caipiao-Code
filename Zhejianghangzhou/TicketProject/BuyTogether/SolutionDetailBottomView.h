//
//  SolutionDetailBottomView.h
//  TicketProject
//
//  Created by sls002 on 13-6-6.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SolutionDetailBottomViewDelegate.h"

@interface SolutionDetailBottomView : UIView<UITextFieldDelegate,UIGestureRecognizerDelegate> {
    UIView      *_baseView;         /**< 基视图 */
    UITextField *_maxField;
    
    id<SolutionDetailBottomViewDelegate> _delegate;
    
    NSInteger     _maxBuyNumber;       /**< 最多购买份数 */
    NSInteger     _shareMoney;         /**< 每份金额 */
    NSDictionary *_solutionDetailDict;
}

@property (nonatomic,assign) id<SolutionDetailBottomViewDelegate> delegate;

-(id)initWithBaseView:(UIView *)baseview solutionDetailDict:(NSDictionary *)solutionDetailDict;

@end
