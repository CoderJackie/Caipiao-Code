//
//  NSObject+addFunctions.m
//  TicketProject
//
//  Created by jsonLuo on 16/10/18.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import "NSObject+addFunctions.h"
#import <objc/runtime.h>

@implementation NSObject (addFunctions)

- (void)swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}



-(id)objectAtIndex:(NSUInteger)index{
    if ([self isKindOfClass:[NSArray class]] && [(NSArray *)self count]>index) {
        return [(NSArray *)self objectAtIndex:index];
    }
    return nil;
}

-(id)objectForKey:(id)aKey{
    if ([self isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)self objectForKey:aKey];
    }
    return nil;
}

-(BOOL)isEqualToString:(NSString *)aString{
    return [[NSString stringWithFormat:@"%@",self] isEqualToString:aString];
}

-(BOOL)containsString:(NSString *)str{
    if ([self isKindOfClass:[NSString class]]) {
        return [(NSString *)self rangeOfString:str].length>0;
    }
    return NO;
}

-(void)setObject:(id)anObject forKey:(id)aKey{
    if ([self isKindOfClass:[NSMutableDictionary class]]) {
        [(NSMutableDictionary *)self setObject:anObject forKey:aKey];
    }
}

-(void)addObject:(id)object{
    if ([self isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray *)self addObject:object];
    }
    
    if ([self isKindOfClass:[NSMutableSet class]]) {
        [(NSMutableSet *)self addObject:object];
    }
}

- (NSInteger)count{
    if ([self isKindOfClass:[NSArray class]]) {
        [(NSArray *)self count];
    }
    return 0;
}

- (NSInteger)length{
    if ([self isKindOfClass:[NSString class]]) {
        [(NSString *)self length];
    }
    return 0;
}

@end
