//
//  SSQPlayMethodView.h
//  TicketProject
//
//  Created by eims on 14-7-3.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownListViewDelegate.h"

@interface SSQPlayMethodView : UIView {
    UIView *_overlayView;
    
    UIView *_contentView;
    id <DropDownListViewDelegate> _delegate;
}

@property (nonatomic,assign) id <DropDownListViewDelegate> delegate;

- (id)initWithPlayMethodNames:(NSArray *)playNames lottery:(NSString *)lotteryName withIndex:(NSInteger)index;


@end
