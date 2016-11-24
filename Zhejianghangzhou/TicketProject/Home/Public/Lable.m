//
//  Lable.m
//  TicketProject
//
//  Created by 刘坤 on 15/12/22.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "Lable.h"

@implementation Lable

- (id)initWithFrame:(CGRect)frame Title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        [self setText:title];
        [self setTextColor:[UIColor blackColor]];
        [self setTextAlignment:NSTextAlignmentCenter];
        
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end
