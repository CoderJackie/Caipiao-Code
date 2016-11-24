//
//  NSString+CustomString.h
//  TicketProject
//
//  Created by KAI on 15-3-14.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CustomString)

+ (NSInteger)characterLength:(NSString *)string;

+ (BOOL)checkOnStandardString:(NSString *)string;

+ (BOOL)ruoCheckString:(NSString *)passwordString;

+ (BOOL)isContainSpecialString:(NSString *)string;

+ (BOOL)isContainString:(NSString *)string;

+ (BOOL)isContainCheckOnString:(NSString *)string;

+ (NSInteger)checkOmString:(NSString *)string;

+ (NSMutableString *)encryptionString:(NSString *)string contrastString:(NSString *)contrastString;

@end
