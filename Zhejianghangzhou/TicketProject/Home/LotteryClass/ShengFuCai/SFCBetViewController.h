//
//  SFCBetViewController.h
//  TicketProject
//
//  Created by 刘坤 on 16/3/1.
//  Copyright (c) 2016年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogSelectButtonViewDetegate.h"
#import "DialogPassWayViewDelegate.h"


#import "SFCViewController.h"

@class AppDelegate;
@class CustomBottomView;
@class Globals;

@interface SFCBetViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate, CustomAlertViewDelegate,SelectBallsDetailViewControllerDelegate> {
    
    UITableView      *_betTableView;
    UIView           *_inputView;
    UITextField      *_inputField;
    CustomBottomView *_bottomView;
    
    AppDelegate         *_appDelegate;
    Globals             *_globals;
    ASIFormDataRequest  *_httpRequest;
    ASIFormDataRequest  *_launchChippedProportionRequest;
    
    UIView           *_overlayView;
    
    NSMutableDictionary *_orderDetailDict;   /**< 购买成功后该订单的详情 */

    NSInteger _betCount;                     /**< 购买注数 */
    BOOL                 _requestData;
    BOOL                 _pushViewBegin;
    
    NSString        *_secrecyLevel;     /**< 保密数值 */
    NSString        *_description;      /**< 宣言内容 */
}

@property (nonatomic,retain) NSMutableArray *selectMatchArray;
@property (nonatomic, retain) NSMutableDictionary *selectedScoreDic;   //

@property (nonatomic,retain) NSMutableDictionary *selectMatchDic;
@property (nonatomic,retain) NSDictionary *lotteryDic;

- (id)initWithMatchArray:(NSMutableArray *)matchArray andScoreDic:(NSMutableDictionary *)scoreDic LotteryDic:(NSDictionary *)dic;


@end
