//
//  CustomTabBarView.h
//  TicketProject
//
//  Created by sls002 on 13-7-8.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XFTabBarDelegate.h"

@interface CustomTabBarView : UIView {
    UIImage     *_backImage;
    UIImageView *_selectRectImage;
    
    NSArray     *_items;
    
    NSInteger    _touchIndex;
    
    id<XFTabBarDelegate> _delegate;
}

@property (nonatomic,retain) NSArray *items;
@property (nonatomic,assign) NSInteger selectItemIndex;
@property (nonatomic,assign) id<XFTabBarDelegate> delegate;
@property (nonatomic,strong) UIImageView *selectRectImage;

- (void)setLabelColorWithButtonTag:(NSInteger)buttonTag;

@end