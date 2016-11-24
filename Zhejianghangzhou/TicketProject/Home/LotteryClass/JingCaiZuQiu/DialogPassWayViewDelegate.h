//
//  DialogPassWayViewDelegate.h
//  TicketProject
//
//  Created by KAI on 15-1-8.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

//过关方式的类型
typedef enum {
    FreePassWay, //自由过关
    MixPassWay  //多串过关
}SelectPassWayType;

@protocol DialogPassWayViewDelegate <NSObject>

-(void)viewDidSelectedPassWay:(NSDictionary *)passWay;

@end
