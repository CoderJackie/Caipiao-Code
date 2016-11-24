//
//  TabBarArray.h
//  TicketProject
//
//  Created by kiu on 15/9/1.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TabBarArray : NSObject {
    
    NSArray *tabBarArr;
    
}

@property (nonatomic, assign) BOOL isHiddenTabBar;      //是否隐藏

- (NSArray *)getTabBarArray;

@end
