//
//  NSDictionary+custom.m   NSDictionary的扩展，在取值的时候同时进行类型解析，只返回确定的类型
//  TicketProject
//
//  Created by KAI on 14-7-8.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "NSDictionary+custom.h"

@implementation NSDictionary (custom)

/**
 * 取出aKey对应的，且可以执行aSelector的值
 */
- (id)objectForKey:(id)aKey respondingToSelector:(SEL)aSelector {
    if (aKey == nil || aSelector == NULL) {
        return nil;
    }
    id anObject = [self objectForKey:aKey];
    return ([anObject respondsToSelector:aSelector]? anObject: nil);
}

/**
 * 取出aKey对应的，且符合类型aClass的值
 */
- (id)objectForKey:(id)aKey isKindOfClass:(Class)aClass {
    if (aKey == nil || aClass == NULL) {
        return nil;
    }
    id anObject = [self objectForKey:aKey];
    return ([anObject isKindOfClass:aClass]? anObject: nil);
}

/**
 * 取出aKey对应的值，并且强制转换成字符串
 */
- (NSString *)stringForKey:(id)aKey {
    return [[self objectForKey:aKey respondingToSelector:@selector(description)] description];
}

/**
 * 取出aKey对应的值，并且强制转换成单精度浮点
 */
- (CGFloat)floatValueForKey:(id)aKey {
    return [[self objectForKey:aKey respondingToSelector:@selector(floatValue)] floatValue];
}

/**
 * 取出aKey对应的值，并且强制转换成双精度浮点
 * @param aKey 键值
 */
- (double)doubleValueForKey:(id)aKey {
    return [[self objectForKey:aKey respondingToSelector:@selector(doubleValue)] doubleValue];
}

/**
 * 取出aKey对应的值，并且强制转换成整数
 */
- (NSInteger)intValueForKey:(id)aKey {
    return [[self objectForKey:aKey respondingToSelector:@selector(intValue)] intValue];
}

/**
 * 取出aKey对应的值，并且强制转换成整数
 */
- (BOOL)boolValueForKey:(id)aKey {
    return [[self objectForKey:aKey respondingToSelector:@selector(boolValue)] boolValue];
}

@end
