//
//  GuideViewController.m
//  TicketProject
//
//  Created by kiu on 15/8/29.
//  Copyright (c) 2015年 sls002. All rights reserved.
//
//  引导动画页面

#import "GuideViewController.h"

#import "TabBarArray.h"

#define count 4

@interface GuideViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIPageControl *control;    // 标签视图控件
@property (nonatomic,strong) UIScrollView *scrollView;  // 滚动视图控件

@end

@implementation GuideViewController

- (void)dealloc {
    
    [super dealloc];
    
    [_tabBarController release];
    _tabBarController = nil;
    [_scrollView release];
    [_control release];
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    CGFloat width = kWinSize.width;
    CGFloat height = kWinSize.height + 20;
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(0, 0, width, height);
    
    
    [self.view addSubview:_scrollView];
    
    for (int i = 0; i < count; i++) {
        NSString *imageName = [NSString  stringWithFormat:@"guide_page%d.jpg", i + 1];
        UIImage *image = [UIImage imageNamed: imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(i * width, 0, width, height);
        [_scrollView addSubview:imageView];
        
        // 在最后一张图片上添加按钮，点击进入主菜单
        if (i == count - 1) {
            // 创建点击按钮
            UIButton *enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            enterBtn.frame = CGRectMake(i * width + (width - 140) / 2, height - 140, 140, 50);
            enterBtn.backgroundColor = kRedColor;
            [enterBtn setTitle:@"进入主菜单" forState:UIControlStateNormal];
            [enterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            enterBtn.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];
            [enterBtn.layer setMasksToBounds:YES];
            [enterBtn.layer setCornerRadius:8.0]; //设置矩形四个圆角半径
            [enterBtn addTarget:self action:@selector(enterClick) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:enterBtn];
        }
    }
    
    // 隐藏水平滚动指示器
    _scrollView.showsHorizontalScrollIndicator = NO;
    // 设置滚动视图内容大小
    _scrollView.contentSize = CGSizeMake(count * width, height);
    // 启动分页
    _scrollView.pagingEnabled = YES;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;
    
    _control = [[UIPageControl alloc] init];
    _control.numberOfPages = count;
    _control.bounds = CGRectMake(0, 0, 200, 50);
    _control.center = CGPointMake(width * 0.5, height - 50);
    _control.currentPage = 0;
    _control.userInteractionEnabled = NO;
    [self.view addSubview:_control];
}

#pragma mark - 点击按钮，进入主页
- (void)enterClick
{
    // 第一次登陆应该直接进入主界面
    //主界面
    TabBarArray *tabBarArr = [[TabBarArray alloc] init];
    tabBarArr.isHiddenTabBar = _isHiddenTabBar;
    
    if (_tabBarController) {
        [_tabBarController removeFromParentViewController];
        [_tabBarController release];
        _tabBarController = nil;
    }
    
    _tabBarController = [[XFTabBarViewController alloc]initWithViewControllers:[tabBarArr getTabBarArray]];
    AppDelegateInstance.window.rootViewController = _tabBarController;
    
    // 动画效果去除引动动画视图
    [self enterHome:_scrollView];
    
}

#pragma mark - UIScrollView delegete
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (scrollView == _scrollView)
    {
        int pageNum = scrollView.contentOffset.x / scrollView.frame.size.width;
        _control.currentPage = pageNum;
        
        if (scrollView.contentOffset.x > count * scrollView.frame.size.width) {
            [self performSelector:@selector(enterHome:) withObject:scrollView afterDelay:1.0];
        }
    }
}

// 进入主页
- (void) enterHome:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:1.0 animations:^(void) {
        
        scrollView.alpha = 0;
        
    } completion:^(BOOL finished){
        
        if (finished)
        {
            
            _control.hidden = YES;
            [scrollView removeFromSuperview];
            
        }
    }];
}

@end
