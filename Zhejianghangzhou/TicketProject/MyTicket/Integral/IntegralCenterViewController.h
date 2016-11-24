//
//  IntegralCenterViewController.h
//  TicketProject
//
//  Created by KAI on 15-4-18.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleBtn;

@interface IntegralCenterViewController : UIViewController <ASIHTTPRequestDelegate>{
    CircleBtn    *_circleBtn;
    UILabel      *_accumulatePromptLabel;
    UIScrollView *_integralRuleScrollView;
    CustomLabel      *_integralRuleLabel;
    
    ASIFormDataRequest *_httpRequest;
    
    
    NSInteger  _optScoringOfSelfBuy; /**< 个人购买1元可获得积分 */
    CGFloat    _scoringExchangerate; /**< 积分兑换金额比例 */
}

@end
