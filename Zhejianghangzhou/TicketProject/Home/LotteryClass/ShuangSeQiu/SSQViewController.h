//
//  SSQViewController.h
//  TicketProject
//
//  Created by sls002 on 13-5-20.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSelectViewController.h"
#import "BetTypeDropDownListView.h"

@class SSQPlayMethodView;

@interface SSQViewController : BaseSelectViewController<DropDownListViewDelegate> {
    
    UIView             *_redballAutoView;
    UIView             *_blueballAutoView;
    SSQPlayMethodView  *_playMethodView;
   
}

@end
