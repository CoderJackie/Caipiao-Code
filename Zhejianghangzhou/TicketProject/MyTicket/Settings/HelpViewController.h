//
//  HelpViewController.h
//  TicketProject
//
//  Created by sls002 on 13-8-16.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController {
    UITextView *_textView; /**< 帮助说明框 */
    BOOL        _originalNavHidden;
    NSInteger   _lotteryId;
}

- (id)initWithLotteryId:(NSInteger)lotteryId;

@end
