//
//  SingleBetViewController.h
//  TicketProject
//
//  Created by sls002 on 13-7-1.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "DialogSelectButtonViewDetegate.h"
#import "DialogPassWayViewDelegate.h"
#import "DialogPassWayView.h"


#import "SingleViewController.h"

@class AppDelegate;
@class ASIFormDataRequest;
@class CustomBottomView;
@class Globals;

@interface SingleBetViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DialogPassWayViewDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate, CustomAlertViewDelegate, DialogSelectButtonViewDetegate> {
    
    UITableView      *_betTableView;
    UIView           *_inputView;
    UIView           *_chaseViewHeight;
    UIButton         *_passWayBtn;
    UITextField      *_inputField;
    CustomBottomView *_bottomView;
    
    AppDelegate         *_appDelegate;
    Globals             *_globals;
    ASIFormDataRequest  *_httpRequest;
    ASIFormDataRequest  *_launchChippedProportionRequest;
    
    UIView           *_overlayView;
    NSTimeInterval    _startTime;
    
    NSMutableDictionary *_orderDetailDict;   /**< 购买成功后该订单的详情 */
    NSInteger _selectedDanBtnCount;
    
    UITextField *_winningsField;
    NSInteger _winningscount;
    BOOL      isSeceltPaly;
    
    NSMutableArray *maxArray;        //最大赔率数组
    NSMutableArray *minArray;        //最小赔率数组
    NSMutableArray *maxNumberArray;  //最大奖金数组
    NSMutableArray *minNumberArray;  //最小奖金数组
    
    DialogPassWayView *passWayView;
    
    NSString        *_secrecyLevel;     /**< 保密数值 */
    NSString        *_description;      /**< 宣言内容 */
}

@property (nonatomic,assign) BOOL isWinnings;       // 是使用彩金
@property (nonatomic,retain) NSMutableArray *selectMatchArray;
@property (nonatomic,retain) NSArray *selectArray;          //选择比赛的胜平负  用于计算注数
@property (nonatomic,retain) NSArray *selectNormalArray;    //没有设胆的数组
@property (nonatomic,retain) NSArray *selectDanArray;       //选择的比赛胜平负 设胆的数组  用于计算注数
@property (nonatomic,retain) NSArray *selectDanInfoArray;   //设胆的比赛信息
@property (nonatomic,retain) NSMutableArray *passWayArray;         //选择的过关方式
@property (nonatomic,retain) NSMutableArray *passWayTagArray;      //几串几的下标
@property (nonatomic,assign) SelectPassWayType selectPassWayType;   //过关方式类型  0自由过关  1多串过关
@property (nonatomic,retain) NSDictionary *matchDic;///比赛字典，返回选比赛页面时用
@property (nonatomic, retain) NSMutableDictionary *selectedScoreDic;   //比分玩法下使用
@property (nonatomic, retain) NSMutableDictionary *selectHalfDict;    //半全场选择
@property (nonatomic,assign) SinglePassBarrierType SinglePassBarrierType;
@property (nonatomic,assign) SinglePlayType SinglePlayType;

- (id)initWithMatchArray:(NSMutableArray *)matchArray andScoreDic:(NSMutableDictionary *)scoreDic;

- (void)updateSelectMatchArray:(NSMutableArray*)matchArray andScoreDic:(NSMutableDictionary *)scoreDic;

@end
