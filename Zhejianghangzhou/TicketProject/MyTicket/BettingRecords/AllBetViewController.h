//
//  AllBetViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-17.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BetRecordViewDelegate.h"
#import "CustomSwitchViewDelegate.h"
#import "MyTool.h"


@class BetRecordView;
@class CustomSwitchView;

@interface AllBetViewController : UIViewController<ASIHTTPRequestDelegate, BetRecordViewDelegate, UIScrollViewDelegate, CustomSwitchViewDelegate>{
    UIScrollView   *_scroll;
    NSMutableArray *_arrBetRecordView;  /**< 各个订单视图 */
    NSArray        *_lableTitleArray;   /**< 各个订单标题 */
    CustomSwitchView *_switchView;
    
    NSInteger   _indexPage;   /**< 查看页数 */
    OrderStatus _orderStatus; /**< 彩票订单状态 */
}

- (id)initWithStatus:(OrderStatus)status withIndexPage:(NSInteger)index ;

@end
