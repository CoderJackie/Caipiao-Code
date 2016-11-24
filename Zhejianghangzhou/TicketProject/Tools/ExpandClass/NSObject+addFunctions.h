//
//  NSObject+addFunctions.h
//  TicketProject
//
//  Created by jsonLuo on 16/10/18.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (addFunctions)

/**方法交换*/
- (void)swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

//以下为常见数据类型错误处理
- (id)objectAtIndex:(NSUInteger)index;

- (id)objectForKey:(id)aKey;

- (BOOL)isEqualToString:(NSString *)aString;

- (BOOL)containsString:(NSString *)str;

- (void)setObject:(id)anObject forKey:(id)aKey;

- (void)addObject:(id)object;

- (NSInteger)count;

- (NSInteger)length;

@end
