//
//  XFTabBarItem.h
//  TicketProject
//
//  Created by sls002 on 13-6-21.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFTabBarItem : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) UIImage *normalImage;
@property (nonatomic,copy) UIImage *selectImage;

-(id)initWithTitle:(NSString *)title NormalImage:(UIImage *)normalImage SelectImage:(UIImage *)selectImage;

@end
