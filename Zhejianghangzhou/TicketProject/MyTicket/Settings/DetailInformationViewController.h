//
//  DetailInformationViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-25.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateIsReadedStatusDelegate.h"



@interface DetailInformationViewController : UIViewController<ASIHTTPRequestDelegate> {
    NSDictionary       *_detailDic; /**< 消息详情 */
    
    id<UpdateIsReadedStatusDelegate> _delegate;
    ASIFormDataRequest *_httpRequest;
    
    NSInteger           _type;
    BOOL                _originalTabBarState;
}

@property (nonatomic, assign) id<UpdateIsReadedStatusDelegate> delegate;

- (id)initWithDetailDictionary:(NSDictionary *)dic withType:(NSInteger)type;

@end
