//
//  ImageDownloader.h
//  CarPooling
//
//  Created by KAI on 15-1-31.
//  Copyright (c) 2015年 KAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageDownloaderDelegate.h"

@class Globals;

@interface ImageDownloader : NSObject{
    NSObject					*_imageKey;
    id<ImageDownloaderDelegate>	 _delegate;
    BOOL						 _monitorEnabled;
    
    NSURLConnection				*_connection;
    NSMutableData				*_downloadData;
    UIImage						*_downloadImage;
    NSUInteger					 _viewTag;
    NSMutableString				*_imageFilePath;
    BOOL						 _isMessageImage;
    NSInteger					 _totalBytes;
    
    Globals						*_globals;
}

@property (nonatomic, retain) NSObject *imageKey;
@property (nonatomic, assign) id<ImageDownloaderDelegate>	delegate;
@property (nonatomic) BOOL monitorEnabled;

@property (nonatomic, assign) NSURLConnection *connection;
@property (nonatomic, assign) NSMutableData *downloadData;
@property (nonatomic, retain) UIImage *downloadImage;

@property (nonatomic,assign) NSUInteger viewTag;

@property (nonatomic,retain) NSMutableString *imageFilePath;
@property (nonatomic) BOOL isMessageImage;
@property (nonatomic, readonly) NSInteger totalBytes;

-(void)startDownload:(NSString *)urlMain;
-(void)cancelDownload;

@end

