//
//  NSDictionary+custom.h   NSDictionary的扩展，在取值的时候同时进行类型解析，只返回确定的类型
//  TicketProject
//
//  Created by KAI on 14-7-8.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (custom)

/**
 * 取出aKey对应的，且可以执行aSelector的值
 */
- (id)objectForKey:(id)aKey respondingToSelector:(SEL)aSelector;
/**
 * 取出aKey对应的，且符合类型aClass的值
 */
- (id)objectForKey:(id)aKey isKindOfClass:(Class)aClass;
/**
 * 取出aKey对应的值，并且强制转换成字符串
 */
- (NSString *)stringForKey:(id)aKey;
/**
 * 取出aKey对应的值，并且强制转换成单精度浮点
 */
- (CGFloat)floatValueForKey:(id)aKey;
/**
 * 取出aKey对应的值，并且强制转换成双精度浮点
 */
- (double)doubleValueForKey:(id)aKey;
/**
 * 取出aKey对应的值，并且强制转换成整数
 */
- (NSInteger)intValueForKey:(id)aKey;
/**
 * 取出aKey对应的值，并且强制转换成布尔值
 */
- (BOOL)boolValueForKey:(id)aKey;

@end
