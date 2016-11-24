//
//  Model.h
//  TicketProject
//
//  Created by 杨宁 on 16/7/22.
//  Copyright © 2016年 sl002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject
@property(nonatomic,copy)NSString *ID;
@property(nonatomic,copy)NSString *lotteryId;
@property(nonatomic,copy)NSString *lotteryName;
@property(nonatomic,copy)NSString *initiateName;
@property(nonatomic,copy)NSString *fuzhiCount;
@property(nonatomic,copy)NSString *passType;
@property(nonatomic,copy)NSString *schemeBonusScale;
@property(nonatomic,copy)NSString *multiple;
@property(nonatomic,copy)NSString *money;
@property(nonatomic,copy)NSString *sumMoney;
@property(nonatomic,copy)NSString *schemeCount;
@property(nonatomic,copy)NSString *schemeWin;
@property(nonatomic,copy)NSString *winMoney;
@property(nonatomic,assign)BOOL isRedName;//红人
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
@end
