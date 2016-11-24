//
//  AppDefaultUtil.m
//  TicketProject
//
//  Created by kiu on 15/9/1.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "AppDefaultUtil.h"

#define KEY_FIRST_LANCHER @"FirstLancher" // 记录用户是否第一次登陆，YES为是，NO为否

@implementation AppDefaultUtil

+ (instancetype)sharedInstance {
    
    static AppDefaultUtil *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[AppDefaultUtil alloc] init];
        
    });
    
    return _sharedClient;
}

// 用户是否第一次登陆
-(void) setFirstLancher:(BOOL)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:KEY_FIRST_LANCHER];
    [defaults synchronize];
}

-(BOOL) isFirstLancher
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:KEY_FIRST_LANCHER];
}

@end
