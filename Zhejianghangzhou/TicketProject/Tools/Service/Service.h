//
//  Service.h
//  TicketProject
//
//  Created by sls002 on 13-8-16.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HomeViewController;
@class BaseBetViewController;
@class SSQViewController;
@class DLTViewController;
@class SDViewController;
@class PLSViewController;
@class PLWViewController;
@class QLCViewController;
@class QXCViewController;

@interface Service : NSObject

@property(assign)NSInteger lotteryTypes;
@property(assign)NSInteger information;
@property(assign)NSInteger getNumber;
@property(assign)NSInteger ballBei;
@property(assign)NSInteger ballQi;

@property(assign)HomeViewController *commonHomeViewControl;
@property(assign)SSQViewController *commonSSQViewController;
@property(assign)DLTViewController *commonDLTViewController;
@property(assign)SDViewController *commonSDViewController;
@property(assign)PLSViewController *commonPLSViewController;
@property(assign)PLWViewController *commonPLWViewController;
@property(assign)QLCViewController *commonQLCViewController;
@property(assign)QXCViewController *commonQXCViewController;


@property(assign)BaseBetViewController *baseBetViewController;
@property(assign)BOOL off;

+ (Service *)getDefaultService;

@end
