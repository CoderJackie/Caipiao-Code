//
//  BankCardManageViewController.h
//  TicketProject
//
//  Created by jsonLuo on 16/9/22.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BankCardManageViewController : UIViewController

/**select：是否是选择银行卡  callBack：回调返回银行卡号码*/
- (instancetype)initWithSelct:(BOOL)select callBack:(void(^)(NSDictionary *retDi))callBack;

@end
