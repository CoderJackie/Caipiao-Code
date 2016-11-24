//
//  SDViewController.h
//  TicketProject
//
//  Created by Michael on 13-5-30.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSelectViewController.h"
#import "DropDownListViewDelegate.h"


@class SSQPlayMethodView;

@interface SDViewController : BaseSelectViewController<DropDownListViewDelegate> {
    
    SSQPlayMethodView *_playMethodView;
    CustomLabel       *_betTypeLabel;
    UIButton          *_secondShakeBtn;
}

@end
