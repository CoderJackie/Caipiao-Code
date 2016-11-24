//
//  BasketBallBetViewController.h
//  TicketProject
//
//  Created by sls002 on 13-7-8.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasketBallViewController.h"
#import "CustomBottomView.h"
#import "DialogPassWayView.h"

@class AppDelegate;
@class Globals;

@interface BasketBallBetViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,DialogPassWayViewDelegate,ASIHTTPRequestDelegate,UIAlertViewDelegate,CustomAlertViewDelegate,DialogSelectButtonViewDetegate> {
    UITableView      *_betTableView;
    UIView           *_inputView;
    UITextField      *_inputField;
    UIButton         *_passWayBtn;
    UIView           *_overlayView;
    CustomBottomView *_bottomView;
    
    AppDelegate         *_appDelegate;
    Globals             *_globals;
    ASIFormDataRequest  *_httpRequest;
    ASIFormDataRequest  *_launchChippedProportionRequest;
    
    NSMutableDictionary *_orderDetailDict;   /**< 购买成功后该订单的详情 */
    NSInteger selectedDanBtnCount;
    BOOL      isSeceltPaly;
    
    NSMutableArray *maxArray;        //最大赔率数组
    NSMutableArray *minArray;        //最小赔率数组
    NSMutableArray *maxNumberArray;  //最大奖金数组
    NSMutableArray *minNumberArray;  //最小奖金数组
    
    DialogPassWayView *passWayView;
    
    NSString        *_secrecyLevel;     /**< 保密数值 */
    NSString        *_description;      /**< 宣言内容 */
}

@property (nonatomic,retain) NSMutableArray *selectMatchArray;
@property (nonatomic,retain) NSArray *selectArray; //选择比赛的胜平负  用于计算注数
@property (nonatomic,retain) NSArray *selectNormalArray; //没有设胆的数组
@property (nonatomic,retain) NSArray *selectDanArray; //选择的比赛胜平负 设胆的数组  用于计算注数
@property (nonatomic,retain) NSArray *selectDanInfoArray; //设胆的比赛信息
@property (nonatomic,retain) NSMutableArray *passWayArray;//选择的过关方式
@property (nonatomic,retain) NSMutableArray *passWayTagArray;
@property (nonatomic,assign) SelectPassWayType selectPassWayType; //过关方式类型  0自由过关  1多串过关
@property (nonatomic,retain) NSDictionary *matchDic;///比赛字典，返回选比赛页面时用
@property (nonatomic,assign) NSInteger selectType;//玩法类型
@property (nonatomic,assign) BasketBallPlayType basketBallPlayType;
@property (nonatomic, assign) BasketBallPassBarrierType basketBallPassBarrierType;  /**< 竞技彩足球过关方式 */
@property (nonatomic,strong) UIBarButtonItem *bonusItem;            // 导航右边竞彩优化按钮
@property (nonatomic,strong) UIButton *bonusbtn;                    // 优化按钮

-(id)initWithMatchArray:(NSMutableArray *)matchArray;

-(void)updateSelectMatchArray:(NSMutableArray*)matchArray;

@end
