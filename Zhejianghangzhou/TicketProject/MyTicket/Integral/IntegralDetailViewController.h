//
//  IntegralDetailViewController.h
//  TicketProject
//
//  Created by KAI on 15-4-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleBtn;

@interface IntegralDetailViewController : UIViewController <PullingRefreshTableViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    CircleBtn    *_circleBtn;
    UILabel *_accumulatePromptLabel;
    
    PullingRefreshTableView *_infoTableView;
    ASIFormDataRequest  *_httpRequest;
    
    NSMutableArray *_integralDetailArray;
    
    NSInteger    _pageIndex;    /**< 请求页码 */
    NSInteger    _lastCalculateNumber; /**< 最后计算的积分 */
    BOOL         _hasMoreMessage;
}

@end
