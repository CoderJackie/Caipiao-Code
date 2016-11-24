//
//  SortButton.h
//  TicketProject
//
//  Created by KAI on 14-12-3.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SortButton : UIButton {
    UILabel        *_titleLabel;
    UIImageView    *_sortImageImageView;
    
    NSString       *_title;
    BOOL            _isAscendingOrder;  //是否为升序
    BOOL            _sortButtonIsSelect;  //是否被选中
}

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, assign) BOOL isAscendingOrder;

@end
