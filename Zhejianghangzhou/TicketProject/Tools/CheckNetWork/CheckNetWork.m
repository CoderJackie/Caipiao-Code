//
//  CheckNetWork.m
//  TicketProject
//
//  Created by sls002 on 13-7-31.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "CheckNetWork.h"
#import "Reachability.h"

@implementation CheckNetWork

+(BOOL)isNetWorkEnable {
    if(([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable)
       && ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable)) {
        return NO;
    } else {
        return YES;
    }
}

@end
