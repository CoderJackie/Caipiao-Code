//
//  SelectFreePassView.h
//  TicketProject
//
//  Created by sls002 on 13-7-2.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectFreePassViewDelegate.h"

@interface SelectFreePassView : UIView  {
    id<SelectFreePassViewDelegate> _delegate;
}

@property (nonatomic,retain) NSArray *items;
@property (nonatomic,retain) NSArray *selectItems;
@property (nonatomic,retain) NSArray *selectItemTags;
@property (nonatomic,assign) id<SelectFreePassViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)array;
- (void)updateSelectPassWay:(NSArray*)arr;//更新过关方式的选择
@end
