//
//  SelectViewController.h
//  TicketProject
//
//  Created by KAI on 14-12-1.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectViewControllerDelegate.h"

@interface SelectViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    id<SelectViewControllerDelegate> _delegate;
    
    NSDictionary *_selectDict;
    NSString     *_selectKeyName;
    
    SelectType    _selectType;
}

@property (nonatomic, assign) id<SelectViewControllerDelegate> delegate;

- (id)initWithSelectDict:(NSDictionary *)selectDict selectKeyName:(NSString *)selectKeyName selectType:(SelectType)selectType ;

@end
