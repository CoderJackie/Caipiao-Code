//
//  DropDownListView.h
//  TicketProject
//
//  Created by sls002 on 13-5-20.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownListViewDelegate.h"

@interface BetTypeDropDownListView : UIView {
    NSArray *betTypes;
}

@property (nonatomic,assign) BOOL isSeleced;

@property (nonatomic,assign) id<DropDownListViewDelegate> delegate;

-(id)initWithBetTypes:(NSArray *)types;

@end
