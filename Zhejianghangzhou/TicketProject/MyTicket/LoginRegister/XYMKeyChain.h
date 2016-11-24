//
//  XYMKeyChain.h
//  KeyChainTest
//
//  Created by Michael on 10/24/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#define KEY_KEYCHAINITEM    @"com.eims.ticket.keychainitem"
#define KEY_USERNAME        @"com.eims.ticket.username"
#define KEY_PASSWORD        @"com.eims.ticket.password"

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface XYMKeyChain : NSObject

+ (void)saveKeyChainItemWithKey:(NSString *)key item:(id)data;
+ (id)loadKeyChainItemWithKey:(NSString *)key;
+ (void)deleteKeyChainItemWithKey:(NSString *)key;


@end