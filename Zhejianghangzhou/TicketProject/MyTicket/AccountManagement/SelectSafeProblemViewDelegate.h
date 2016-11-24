//
//  SelectSafeProblemViewDelegate.h
//  TicketProject
//
//  Created by KAI on 15-1-8.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SelectSafeProblemViewDelegate <NSObject>

- (void)listViewDidSelectedText:(NSString *)selectText AtRowIndex:(NSInteger)index;

@end
