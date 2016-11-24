//
//  AppDefaultUtil.h
//  TicketProject
//
//  Created by kiu on 15/9/1.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDefaultUtil : NSObject

/**
 单例模式，实例化对象
*/
+ (instancetype)sharedInstance;

// 设置用户是否第一次登陆
-(void) setFirstLancher:(BOOL)value;

// 获取用户是第一次登录
-(BOOL) isFirstLancher;

@end
