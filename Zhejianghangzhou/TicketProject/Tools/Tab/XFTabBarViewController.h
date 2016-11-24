//
//  XFTabBarViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-22.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserLoginViewControllerDelegate.h"
#import "XFTabBarDelegate.h"

@class CustomTabBarView;

@interface XFTabBarViewController : UIViewController<XFTabBarDelegate, UserLoginViewControllerDelegate> {
    CustomTabBarView *_tabBar;
}

@property (nonatomic,retain) NSArray *viewControllers;
@property (nonatomic,retain) UIViewController *currentController;
@property (nonatomic,assign) NSInteger selectControllerIndex;

- (id)initWithViewControllers:(NSArray *)controllers;

- (void)setTabBarHidden:(BOOL)hidden;

- (BOOL)tabBarHidden;

- (void)itemDidSelectedAtIndex:(NSInteger)index;

@end

@interface UIViewController (XFViewController)

@property (nonatomic,retain,readonly) XFTabBarViewController *xfTabBarController;

@end
