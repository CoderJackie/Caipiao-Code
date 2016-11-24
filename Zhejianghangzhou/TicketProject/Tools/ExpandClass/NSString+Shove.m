//
//  NSString+Shove.m
//  Shove
//
//  Created by 英迈思实验室移动开发部 on 14-8-28.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import "NSString+Shove.h"

@implementation NSString (Shove)

/* 
 * 判断字符串是否为空白的
 */
- (BOOL)isBlank {
    if ((self == nil) || (self.length == 0)) {
        return YES;
    }
    
    NSString *trimedString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimedString length] == 0) {
        return YES;
    } else {
        return NO;
    }
    
    return YES;
}

/* 
 * 判断字符串是否为空
 */
- (BOOL)isEmpty {
    return ((self.length == 0) || (self == nil) || ([self isKindOfClass:[NSNull class]]) || (self.length == 0));
}

/* 
 * 给字符串md5加密
 */
- (NSString*)md5 {
    const char *ptr = [self UTF8String];

    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

- (int)intValueNONil{
    if (self) {
        return [self intValue];
    }
    return 0;
}

-(NSInteger)integerValueNONil{
    if (self) {
        return [self integerValue];
    }
    return 0;
}

@end
