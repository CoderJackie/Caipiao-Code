//
//  CustomAlertViewDelegate.h
//  TicketProject
//
//  Created by KAI on 15-1-8.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CustomAlertView;
@protocol CustomAlertViewDelegate <NSObject>

- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
