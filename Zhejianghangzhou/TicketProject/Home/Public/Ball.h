//
//  BallInitalize.h
//  TicketProject
//
//  Created by sls002 on 13-5-20.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Ball : UIButton {
    UIImage *_normalImage;
    UIImage *_highlightedImage;
    UIImage *_selectedImage;
}

@property (nonatomic, assign) BallsType type;

- (id)initWithType:(BallsType)types Title:(NSString *)title;

@end
