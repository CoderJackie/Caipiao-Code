//
//  NameModel.h
//  TicketProject
//
//  Created by 杨宁 on 16/7/26.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NameModel : NSObject
//"userID":3,
//"userName":"abcvip",
//"lotteryID":5,
//"order":1
@property(nonatomic,strong)NSNumber *userID;
@property(nonatomic,copy)NSString *userName;
@property(nonatomic,strong)NSNumber *lotteryID;
@property(nonatomic,strong)NSNumber *order;
@end
