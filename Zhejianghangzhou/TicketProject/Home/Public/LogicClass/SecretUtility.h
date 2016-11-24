//
//  SecretUtility.h
//  TicketProject
//
//  Created by sls002 on 13-6-26.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecretUtility : NSObject

+(NSInteger)addUserName:(NSString *)userName Password:(NSString *)password;

+(id)selectAll;

+(id)selectWithUserName:(NSString *)userName;

+(NSInteger)updateWithUserName:(NSString *)userName Password:(NSString *)password;

+(NSInteger)deleteWithUserName:(NSString *)userName;

@end
