//
//  SolutionDetailViewController.h
//  TicketProject
//
//  SolutionDetailViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-6.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SolutionDetailBottomViewDelegate.h"
#import "Model.h"


@class AppDelegate;
@class Globals;
@class MSKeyboardScrollView;
@class SolutionDetailBottomView;

@interface SolutionDetailViewController : UIViewController<ASIHTTPRequestDelegate> {
    MSKeyboardScrollView *_scrollView;
    UIButton *_examineBtn;            /**< 查看选号详情按钮 */
    
    AppDelegate         *_appDelegate;
    Globals             *_globals;
    
    SolutionDetailBottomView *_inputView;
    
    ASIFormDataRequest       *_httpRequest;
    
    NSDictionary *_solutionDetail;

}

@property (nonatomic,copy)NSString *schemeId;
@property (nonatomic,copy)NSString *moeny; //单倍


-(id)initWithSolutionDic:(NSDictionary *)dictionary;

@end
