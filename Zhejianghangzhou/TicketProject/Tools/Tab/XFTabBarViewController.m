//
//  XFTabBarViewController.m 选项卡
//  TicketProject
//
//  Created by sls002 on 13-6-22.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "XFTabBarViewController.h"
#import "CustomTabBarView.h"
#import "UserLoginViewController.h"
#import "XFNavigationViewController.h"
#import "XFTabBarItem.h"


#import "UserInfo.h"

static XFTabBarViewController *tabBarController;
@implementation UIViewController (XFViewController)
- (XFTabBarViewController *)xfTabBarController {
    return tabBarController;
}
@end

@interface XFTabBarViewController ()

@end

@implementation XFTabBarViewController

- (id)initWithViewControllers:(NSArray *)controllers {
    self = [super init];
    if(self) {
        self.viewControllers = controllers;
        
        tabBarController = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTabBar];
    [self itemDidSelectedAtIndex:1];
    [_tabBar setSelectItemIndex:1];
}

//初始化tabbar
- (void)initTabBar {
    _tabBar = [[CustomTabBarView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - kTabBarHeight, self.view.bounds.size.width, kTabBarHeight)];
    _tabBar.items = [self getItems];
    _tabBar.delegate = self;
    [self.view addSubview:_tabBar];
    [_tabBar release];
}

- (NSArray *)getItems {
    NSMutableArray *array = [NSMutableArray array];
    for (XFNavigationViewController *nav in _viewControllers) {
        [array addObject:nav.barItem];
    }
    return array;
}

- (void)setTabBarHidden:(BOOL)hidden {
    CGRect rect = _currentController.view.bounds;
    
    if(hidden) {
        [_tabBar setHidden:YES];
        
        [_currentController.view setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height + 49)];
    } else {
        [_tabBar setHidden:NO];
    }
}

- (BOOL)tabBarHidden {
    return _tabBar.hidden;
}

#pragma mark -XFTabBarDelegate
- (void)itemDidSelectedAtIndex:(NSInteger)index {
    if(index == 5) {//个人中心
        if(![UserInfo shareUserInfo].userID) {
            UserLoginViewController *login = [[UserLoginViewController alloc]init];
            login.delegate = self;
            login.isNeedDelegate = YES;
            XFNavigationViewController *loginNav = [[XFNavigationViewController alloc]initWithRootViewController:login];
            [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = loginNav;
            [self.view.window.rootViewController presentViewController:loginNav animated:YES completion:nil];
            [loginNav release];
            [login release];
            for (UIView *view in _tabBar.subviews) {
                if([view isKindOfClass:[UIButton class]]) {
                    UIButton *subBtn = (UIButton *)view;
                    if ([subBtn isSelected]) {
                        [_tabBar setLabelColorWithButtonTag:subBtn.tag];
                    }
                }
            }
            return;
        }
    }
    
    for (UIView *view in _tabBar.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *subBtn = (UIButton *)view;
            [subBtn setSelected:NO];
        }
    }
    
    UIButton *btn = (UIButton *)[_tabBar viewWithTag:index];
    [btn setSelected:YES];
    [_tabBar setLabelColorWithButtonTag:btn.tag];
    /********************** adjustment 控件调整 ***************************/
    CGFloat itemSelectWidth = IS_PHONE ? 50.0f : 100.0f;//选项卡被选中的背景宽度   与CustomTabBarView中的设置必须一样
    CGFloat itemSelectHeight = IS_PHONE ? 44.0f : 64.0f;
    /********************** adjustment end ***************************/
    CGRect btnRect = btn.frame;
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.2];
    [_tabBar.selectRectImage setFrame:CGRectMake(CGRectGetMinX(btnRect) - (itemSelectWidth - CGRectGetWidth(btnRect)) / 2.0f, 1, itemSelectWidth, itemSelectHeight)];
    [UIView commitAnimations];

    [_currentController.view removeFromSuperview];
    self.currentController = [_viewControllers objectAtIndex:index - 1];
    [_currentController.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    [self.view insertSubview:_currentController.view belowSubview:_tabBar];
    
    [(UINavigationController *)_currentController popToRootViewControllerAnimated:YES];
}

- (void)setSelectControllerIndex:(NSInteger)selectControllerIndex {
    _selectControllerIndex = selectControllerIndex;
    [self itemDidSelectedAtIndex:_selectControllerIndex];
}

//登陆成功的回调函数
- (void)userDidLoginSuccess {
    [self itemDidSelectedAtIndex:5];
}

- (void)dealloc {
    [_viewControllers release];
    [_currentController release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
