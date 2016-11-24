//
//  PushManageViewController.h
//  TicketProject
//
//  Created by KAI on 15-1-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushManageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableListView; /**< 中间表格视图 */
    
    AppDelegate   *_appDelegate;
    Globals       *_globals;
    ASIFormDataRequest *_httpRequest;
    
    NSArray     *_titleArray;
    BOOL         _operationing;
}

@end
