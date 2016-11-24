//
//  XFTabBarItem.m
//  TicketProject
//
//  Created by sls002 on 13-6-21.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "XFTabBarItem.h"

@implementation XFTabBarItem

- (id)initWithTitle:(NSString *)title NormalImage:(UIImage *)normalImage SelectImage:(UIImage *)selectImage {
    self = [super init];
    if(self) {
        self.title = title;
        self.normalImage = normalImage;
        self.selectImage = selectImage;
    }
    return self;
}

- (void)dealloc {
    [_title release];
    [_normalImage release];
    [_selectImage release];
    
    [super dealloc];
}

@end
