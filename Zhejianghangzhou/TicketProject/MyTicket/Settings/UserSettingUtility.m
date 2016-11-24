//
//  UserSettingUtility.m
//  TicketProject
//
//  Created by sls002 on 13-8-1.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "UserSettingUtility.h"

@implementation UserSettingUtility

+ (NSMutableDictionary *)getUserSettingDictionary {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"UserSetting" ofType:@"plist"];
    
    return [NSMutableDictionary dictionaryWithContentsOfFile:path];
}

@end
