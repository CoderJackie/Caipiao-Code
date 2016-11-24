//
//  SecretUtility.m
//  TicketProject
//
//  Created by sls002 on 13-6-26.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//钥匙串 对用户名 密码进行存储

#import "SecretUtility.h"

@implementation SecretUtility

+ (NSInteger)addUserName:(NSString *)userName Password:(NSString *)password {
    // 一个mutable字典结构存储item信息
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    // 确定所属的类class
    [dic setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    // 设置其他属性attributes
    [dic setObject:userName forKey:(id)kSecAttrAccount];
    // 添加密码 secValue  注意是object 是 NSData
    [dic setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
    // SecItemAdd
    OSStatus s = SecItemAdd((CFDictionaryRef)dic, NULL);
    return s;
}

+ (id)selectAll {
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:kSecClassGenericPassword,kSecClass,
                           kSecMatchLimitAll,kSecMatchLimit,
                           kCFBooleanTrue,kSecReturnAttributes,nil];
    CFTypeRef result = nil;
    SecItemCopyMatching((CFDictionaryRef)query, &result);
//    NSLog(@"select all : %ld",s);
//    NSLog(@"%@",result);
    
    return result;
}

+ (id)selectWithUserName:(NSString *)userName {
    CFTypeRef pwdResult = nil;
    if (userName.length >0) {
        // 查找条件：1.class 2.attributes 3.search option
        NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:kSecClassGenericPassword,kSecClass,
                               userName,kSecAttrAccount,
                               kCFBooleanTrue,kSecReturnAttributes,nil];
        CFTypeRef result = nil;
        // 先找到一个item
        OSStatus s = SecItemCopyMatching((CFDictionaryRef)query, &result);

        if (s == noErr) {
            // 继续查找item的secValue
            NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:result];
            // 存储格式
            [dic setObject:(id)kCFBooleanTrue forKey:kSecReturnData];
            // 确定class
            [dic setObject:[query objectForKey:kSecClass] forKey:kSecClass];

            // 查找secValue
            if (SecItemCopyMatching((CFDictionaryRef)dic, &pwdResult) == noErr) {
                if (pwdResult)
                    pwdResult = [[[NSString alloc] initWithData:pwdResult encoding:NSUTF8StringEncoding] autorelease];
            }
        }
    }
    return pwdResult;
}

+ (NSInteger)updateWithUserName:(NSString *)userName Password:(NSString *)password {
    OSStatus status;
    
    {
        // 先查找看看有没有
        NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:kSecClassGenericPassword,kSecClass,
                               userName,kSecAttrAccount,
                               kCFBooleanTrue,kSecReturnAttributes,nil];
        
        CFTypeRef result = nil;
        {
            // 更新后的数据，基础是搜到的result
            NSMutableDictionary* update = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)result];
            // 修改要跟新的项 注意先加后删的class项
            [update setObject:[query objectForKey:kSecClass] forKey:kSecClass];
            [update setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:kSecValueData];
            [update removeObjectForKey:kSecClass];
#if TARGET_IPHONE_SIMULATOR
            // 模拟器的都有个默认的组“test”，删了，不然会出错
            [update removeObjectForKey:(id)kSecAttrAccessGroup];
#endif
            // 得到要修改的item，根据result，但要添加class
            NSMutableDictionary* updateItem = [NSMutableDictionary dictionaryWithDictionary:result];
            [updateItem setObject:[query objectForKey:(id)kSecClass] forKey:(id)kSecClass];
            // SecItemUpdate
            status = SecItemUpdate((CFDictionaryRef)updateItem, (CFDictionaryRef)update);
//            NSLog(@"update:%ld",status);
        }
    }
    return status;
}

+ (NSInteger)deleteWithUserName:(NSString *)userName {
    OSStatus status;
    {
        // 删除的条件
        NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:kSecClassGenericPassword,kSecClass,
                               userName,kSecAttrAccount,nil];
        // SecItemDelete
        status = SecItemDelete((CFDictionaryRef)query);
    }
    return status;
}

@end
