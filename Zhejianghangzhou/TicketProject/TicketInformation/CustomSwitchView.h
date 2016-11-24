//
//  CustomSwitchView.h
//  TicketProject
//
//  Created by sls002 on 13-6-21.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSwitchViewDelegate.h"

@interface CustomSwitchView : UIView {
    UIImageView *_switchImageView; /**< 背景图 */
    
    id<CustomSwitchViewDelegate> _delegate;
    NSArray     *_switchItems;     /**< 选择 */
}

@property (nonatomic,assign) id<CustomSwitchViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)items;

- (void)selectBtnIndex:(NSInteger)index;//index从1开始

@end
