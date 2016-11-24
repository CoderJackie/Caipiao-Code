//
//  SelectRechargeTypeViewController.h
//  TicketProject
//
//  Created by KAI on 15-1-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectRechargeTypeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableListView;
    
    NSMutableArray     *_rechargeTypePictureNameArray;
    NSMutableArray     *_rechargeTypeArray;
    NSMutableArray     *_rechargeTypePromptArray;
    
    NSInteger    _recommendIndex;
    
    ASIFormDataRequest *_loadBankInfoRequest;
}

@end
