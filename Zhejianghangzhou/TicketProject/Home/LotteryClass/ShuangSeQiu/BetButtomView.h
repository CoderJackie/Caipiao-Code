//
//  TogetherBuyButtomView.h
//  TicketProject
//
//  Created by sls002 on 13-5-23.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BetButtomViewDelegate.h"

@class CustomLabel;

@interface BetButtomView : UIView {
    UIImage *_backImage;
    CustomLabel *_betCountLabel;
    UIButton *_checkBtn;
    id<BetButtomViewDelegate> _delegate;
}

@property (nonatomic,assign) id<BetButtomViewDelegate> delegate;

- (void)setBetCountLabelText:(NSString *)text;

- (void)setBetAccountLabelText:(NSString *)text;

- (id)initWithBackImage:(UIImage *)image;

- (void)setCount:(NSInteger)count money:(NSInteger)money;

/**点击一次发起复制按钮*/
- (void)didSelcet_once;

@end
