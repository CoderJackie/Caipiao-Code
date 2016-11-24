//
//  SelectViewControllerDelegate.h
//  TicketProject
//
//  Created by KAI on 15-1-8.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SelectTypeOfBankName,
    SelectTypeOfBankPlace,
} SelectType;

@protocol SelectViewControllerDelegate <NSObject>

- (void)selectViewAtIndex:(NSInteger)index selectType:(SelectType)selectType;

@end
