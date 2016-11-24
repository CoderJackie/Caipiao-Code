//
//  UserInfo.m
//  TicketProject
//
//  Created by sls002 on 13-6-14.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "UserInfo.h"

static UserInfo *userInfo = nil;

@implementation UserInfo

+(UserInfo *)shareUserInfo
{
	@synchronized(self){
		if (userInfo==nil) {
            userInfo = [[self alloc] init];
            NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"];
            if (userinfo) {
                userInfo.userID = [userinfo objectForKey:@"uid"];
                userInfo.userName = [userinfo objectForKey:@"name"];
                userInfo.realName = [userinfo objectForKey:@"realityName"];
                userInfo.cardNumber = [userinfo objectForKey:@"idcardnumber"];
                userInfo.balance = [userinfo objectForKey:@"balance"];
                userInfo.freeze = [userinfo objectForKey:@"freeze"];
                
                userInfo.rechargeMoney = [[userinfo objectForKey:@"rechargeMoney"] floatValue];
                
                userInfo.isOn = [userinfo objectForKey:kIsShakeToSelect];
                userInfo.isShaking = [userinfo objectForKey:kIsShake];
            }
		}
	}
	return userInfo;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;
}

- (oneway void)release {
}

- (id)autorelease {
    return self;
}

@end
