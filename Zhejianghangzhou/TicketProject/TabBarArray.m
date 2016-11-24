//
//  TabBarArray.m
//  TicketProject
//
//  Created by kiu on 15/9/1.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "TabBarArray.h"

#import "HomeViewController.h"
#import "LaunchChippedListViewController.h"
#import "NotificationViewController.h"
#import "TicketInformationViewController.h"
#import "MyTicketsViewController.h"
#import "XFNavigationViewController.h"
#import "XFTabBarItem.h"

#import "Globals.h"

@implementation TabBarArray

- (NSArray *)getTabBarArray {
    
    //首页
    HomeViewController *home;
    XFNavigationViewController *homeNav;
    if (!_isHiddenTabBar) {
        home = [[[HomeViewController alloc]init] autorelease];
        homeNav = [[[XFNavigationViewController alloc]initWithRootViewController:home]autorelease];
        homeNav.barItem = [[[XFTabBarItem alloc]initWithTitle:@"购彩" NormalImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"home.png"]] SelectImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"home_select.png"]]]autorelease];
    }
    
    //名人名单
    LaunchChippedListViewController *launchChipped = [[[LaunchChippedListViewController alloc]init] autorelease];
    XFNavigationViewController *chippedNav = [[[XFNavigationViewController alloc]initWithRootViewController:launchChipped]autorelease];
    chippedNav.barItem = [[[XFTabBarItem alloc]initWithTitle:@"名人名单" NormalImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"chipped.png"]] SelectImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"chipped_select.png"]]]autorelease];
    
    
    //开奖公告
    NotificationViewController *notification = [[[NotificationViewController alloc]init]autorelease];
    XFNavigationViewController *notificationNav = [[[XFNavigationViewController alloc]initWithRootViewController:notification]autorelease];
    notificationNav.barItem = [[[XFTabBarItem alloc]initWithTitle:@"开奖" NormalImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"notification.png"]] SelectImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"notification_select.png"]]]autorelease];
    
    //彩票资讯
    TicketInformationViewController *ticketInfomation = [[[TicketInformationViewController alloc]init]autorelease];
    XFNavigationViewController *infoNav = [[[XFNavigationViewController alloc]initWithRootViewController:ticketInfomation]autorelease];
    infoNav.barItem = [[[XFTabBarItem alloc]initWithTitle:@"资讯" NormalImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"info.png"]] SelectImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"info_select.png"]]]autorelease];
    
    //个人中心
    MyTicketsViewController *myTickets;
    XFNavigationViewController *myNav;
    if (!_isHiddenTabBar) {
        myTickets = [[[MyTicketsViewController alloc]init]autorelease];
        myNav = [[[XFNavigationViewController alloc]initWithRootViewController:myTickets]autorelease];
        myNav.barItem = [[[XFTabBarItem alloc]initWithTitle:@"账户" NormalImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"my.png"]] SelectImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"my_select.png"]]]autorelease];
    }
    
    if (_isHiddenTabBar) {
        tabBarArr = [NSArray arrayWithObjects:chippedNav,notificationNav,infoNav, nil];
    } else {
        tabBarArr = [NSArray arrayWithObjects:homeNav,chippedNav,notificationNav,infoNav,myNav, nil];
    }
    
    return tabBarArr;
}

@end
