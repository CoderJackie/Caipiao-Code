//
//  FCViewController.h
//  TicketProject
//
//  Created by sls002 on 14-7-2.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface FCViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    
    NSDictionary *_schemeDic;  /**< 合买的方案字典 */
    NSArray      *_ballsArray; /**< 合买方案详细数组 */
    
    NSInteger     _lotteryID;
}

-(id)initWithSchemeDictionary:(NSDictionary *)dic;

@end
