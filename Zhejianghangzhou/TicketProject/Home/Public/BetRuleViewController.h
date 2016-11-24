//
//  BetRuleViewController.h
//  TicketProject
//
//  Created by Michael on 8/31/13.
//  Copyright (c) 2013 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BetRuleViewController : UIViewController<ASIHTTPRequestDelegate> {
    
    UIWebView *_contentView;
    
    ASIFormDataRequest *_httpRequest;
    
}

@end
