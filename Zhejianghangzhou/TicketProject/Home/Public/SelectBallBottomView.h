//
//  BottomView.h
//  TicketProject
//
//  Created by sls002 on 13-5-21.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectBallBottomViewDelegate.h"

@interface SelectBallBottomView : UIView {
    UIImage     *_backImage;
    CustomLabel *_betCountLabel;
    
    id<SelectBallBottomViewDelegate> _delegate;
}

@property (nonatomic,assign) id<SelectBallBottomViewDelegate> delegate;

- (id)initWithBackImage:(UIImage *)image ;

- (void)setbetCountLabelText:(NSString *)text;

- (void)setbetCountLabelCenterAddX:(CGFloat)x AddY:(CGFloat)y;

- (void)setTextWithCount:(NSInteger)matchCount money:(NSInteger)money;

@end
