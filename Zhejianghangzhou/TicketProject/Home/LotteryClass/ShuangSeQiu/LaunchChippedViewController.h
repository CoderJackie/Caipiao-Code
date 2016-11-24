//
//  LaunchChippedViewController.h
//  TicketProject
//
//  Created by sls002 on 13-5-28.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AppDelegate;
@class CustomSegmentedControl;
@class Globals;
@class MSKeyboardScrollView;

@interface LaunchChippedViewController : UIViewController<ASIHTTPRequestDelegate, UIAlertViewDelegate> {
    
    MSKeyboardScrollView *_scrollView;
    
    UILabel *_totalLabel;//方案金额
    UILabel *_copiesLabel;//份数
    UILabel *_copiesLabelPromptLabel;
    CustomSegmentedControl *_amountPerServingCustomSegmentedControl;//每份金额
    UITextField  *_winBrokerageTextField;
    UIView *_brokerageView; //佣金比例选择视图
    UIView      *_secondView;
    UITextField *_buyCopiesTextField;//购买份数
    UITextField *_guaranteedCopiesTextField;//保底份数
    UITextField *_titleTextField;//方案标题
    UITextField *_memoTextField; //方案描述
    UILabel *_bottomLabel;
    UILabel *_yuanPromptLabel;
    
    ASIFormDataRequest *_httpRequest;
    AppDelegate        *_appDelegate;
    Globals            *_globals;
    CustomSegmentedControl *_secretSettingCustomSegmentedControl;//保密设置
    
    NSMutableDictionary *_orderDetailDict;
    
    CGFloat _subscriptioncopies;//默认佣金比例
    CGFloat _minBuyScale;
    NSInteger projectTotal;   // 总金额
    NSInteger copies;         // 总份数
    float amount;
    NSInteger brokerage;      // 佣金比例
    NSInteger _oneOfTicketMonery;//该彩票中一注的价格
    NSInteger _playId;
    int buyCopy;        // 购买份数
    int guaranteed;     // 保底份数
    int secretIndex;
    int multiple;       // 倍数
}

@property (nonatomic,retain) NSDictionary *lotteryDic;
@property (nonatomic,copy) NSArray *buyContent;
@property (nonatomic,assign) int isBonusOptimization;    // 是否奖金优化数据    1:是     0:不是
@property (nonatomic,copy) NSString *schemeCodes;        // 方案代码
@property (nonatomic,copy) NSString *gGWay;              // 串数
@property (nonatomic,copy) NSString *investNum;          // 注数
@property (nonatomic,copy) NSString *playTeam;           // 对阵信息
@property (nonatomic,copy) NSString *castMoney;          // 预测奖金
@property (nonatomic,copy) NSString *playTypeID;         // 玩法ID
@property (nonatomic,copy) NSString *matchID;            // 赛事ID
@property (nonatomic,copy) NSString *codeFormat;         // 玩法ID
@property (nonatomic,copy) NSString *preBetType;         // 优化方案类型     1：平均优化 2：博热优化 3：博冷优化

-(id)initWithBetDictionary:(NSDictionary *)betDic;

@end
