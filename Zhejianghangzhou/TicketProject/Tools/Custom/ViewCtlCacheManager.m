//
//  ViewCtlCacheManager.m
//  TicketProject
//
//  Created by KAI on 15/4/30.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "ViewCtlCacheManager.h"

@implementation ViewCtlCacheManager

//- (id<NSObject, NSCoding, NSCopying>)viewCtlCacheForUserId:(NSInteger)_userId cacheType:(ViewCtlCacheManagerCacheType)_cacheType {
//    //先从内存中取
//    id cache = [_cachesDictionary objectForKey:[NSIndexPath indexPathForRow:_userId inSection:_cacheType]];
//    if (cache == nil) { //如果没有，就从文件系统中取，如果有，就顺便增加到内存中
//        NSString *cacheFilePath = [PathService pathForViewCtlCacheFileOfUser:_userId vCacheType:_cacheType];
//        NSMutableData *mutableData = [[NSMutableData alloc] initWithContentsOfFile:cacheFilePath];
//        if (mutableData.length > 0) {
//            NSKeyedUnarchiver *unArchiever = [[NSKeyedUnarchiver alloc] initForReadingWithData:mutableData];
//            @try {
//                cache = [unArchiever decodeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
//            }
//            @catch (NSException *exception) {
//                [[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:nil];
//            }
//            @finally {
//            }
//            if (cache) {
//                [_cachesDictionary setObject:cache forKey:[NSIndexPath indexPathForRow:_userId inSection:_cacheType]];
//            }
//            [unArchiever release];
//        }
//        [mutableData release];
//    }
//    return cache;
//}

//- (void)setViewCtlCache:(id<NSObject, NSCoding, NSCopying>)_cache forUserId:(NSInteger)_userId {
//    if (_cache == nil) {
//        return;
//    }
//    id mutableCache = nil;
//    if ([_cache isKindOfClass:[NSDictionary class]] && ![_cache isKindOfClass:[NSMutableDictionary class]]) {
//        mutableCache = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)_cache];
//    } else if ([_cache isKindOfClass:[NSMutableDictionary class]]) {
//        mutableCache = [(NSMutableDictionary *)_cache mutableCopy];
//    } else if ([_cache isKindOfClass:[NSArray class]] && ![_cache isKindOfClass:[NSMutableArray class]]) {
//        mutableCache = [[NSMutableArray alloc] initWithArray:(NSArray *)_cache];
//    } else if ([_cache isKindOfClass:[NSMutableArray class]]) {
//        mutableCache = [(NSMutableArray *)_cache mutableCopy];
//    } else {    //其他都是不支持的类型
//        return;
//    }
//    [_cachesDictionary setObject:mutableCache forKey:[NSIndexPath indexPathForRow:_userId inSection:_cacheType]];
//    [mutableCache release];
//}

@end
