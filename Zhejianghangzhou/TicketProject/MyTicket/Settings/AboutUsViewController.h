//
//  AboutUsViewController.h
//  TicketProject
//
//  Created by KAI on 15-4-24.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloaderDelegate.h"

@class ActivImageView;

@interface AboutUsViewController : UIViewController <ASIHTTPRequestDelegate, ImageDownloaderDelegate>{
    ActivImageView     *_activImageView;
    UILabel            *_aboutUsLabel;
    UILabel            *_customerServiceLabel;
    
    ASIFormDataRequest  *_customerServiceRequest;
    NSMutableDictionary *_imageDownloaders;
}

@end
