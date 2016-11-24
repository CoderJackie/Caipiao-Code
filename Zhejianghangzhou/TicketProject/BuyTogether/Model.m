//
//  Model.m
//  TicketProject
//
//  Created by 杨宁 on 16/7/22.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import "Model.h"

@implementation Model
- (void)setValue:(id)value forUndefinedKey:(NSString *)key  {
    if([key isEqualToString:@"id"])
        self.ID = value;
    if ([key isEqualToString:@"copyCount"]) {
        self.fuzhiCount = value;
    }
}
@end
