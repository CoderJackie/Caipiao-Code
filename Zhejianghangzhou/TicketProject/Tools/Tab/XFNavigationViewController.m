//
//  XFNavigationViewController.m
//  TicketProject
//
//  Created by sls002 on 13-7-8.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "XFNavigationViewController.h"
#import "XFTabBarItem.h"

#import "Globals.h"

@interface XFNavigationViewController ()

@end

@implementation XFNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *navBar = self.navigationBar;
    
    if([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [navBar setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"nav.png"]] stretchableImageWithLeftCapWidth:3.0f topCapHeight:3.0f] forBarMetrics:UIBarMetricsDefault];
    } else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor colorWithPatternImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"nav.png"]] stretchableImageWithLeftCapWidth:3.0f topCapHeight:3.0f]].CGColor);
        CGContextFillRect(context, navBar.bounds);
    }
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    shadow.shadowOffset = CGSizeMake(0, 0);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, shadow, NSShadowAttributeName, [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:XFIponeIpadFontSize18], NSFontAttributeName, nil]];
    [shadow release];
}

- (void)dealloc {
    [_barItem release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end