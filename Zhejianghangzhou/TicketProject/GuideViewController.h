//
//  GuideViewController.h
//  TicketProject
//
//  Created by kiu on 15/8/29.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XFTabBarViewController.h"

@interface GuideViewController : UIViewController {
    
    XFTabBarViewController *_tabBarController;
    
}

@property (nonatomic, assign) NSString *isHiddenTabBar;

@end
