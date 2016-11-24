//
//  NSDictionary+doSomeThings.m
//  TicketProject
//
//  Created by jsonLuo on 16/10/18.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import "NSDictionary+doSomeThings.h"
#import <objc/runtime.h>

@implementation NSDictionary (doSomeThings)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [objc_getClass("__NSDictionaryM") swizzleMethod:@selector(setObject:forKey:) swizzledSelector:@selector(mutableSetObject:forKey:)];
        }
    });
}

//字典键值为nil时取值处理
- (void)mutableSetObject:(id)obj forKey:(NSString *)key{
    if (obj && key) {
        [self mutableSetObject:obj forKey:key];
    }
}

@end
