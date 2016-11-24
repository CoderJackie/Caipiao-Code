//
//  MyAppDelegate.m
//  TicketProject
//
//  Created by md004 on 13-10-31.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "MyAppDelegate.h"

@implementation MyAppDelegate

+ (AppDelegate *)shareAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

@end
