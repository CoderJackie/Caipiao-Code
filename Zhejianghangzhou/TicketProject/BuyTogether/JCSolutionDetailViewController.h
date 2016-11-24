//
//  JCSolutionDetailViewController.h
//  TicketProject
//
//  Created by sls002 on 13-7-23.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCSolutionDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate> {
    
    UITableView    *_detailTableView;
    
    ASIFormDataRequest *_httpRequest;
    
    NSDictionary   *_schemeDic;      /**< 合买的方案字典 */
    NSMutableArray *_schemeDetailArray;
    NSMutableArray *_matchDeitalArray;
    NSInteger       _lotteryID;
}

-(id)initWithSchemeDictionary:(NSDictionary *)dic;

@end
