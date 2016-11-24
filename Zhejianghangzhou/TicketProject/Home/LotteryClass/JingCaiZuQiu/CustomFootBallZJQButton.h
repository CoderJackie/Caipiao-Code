//
//  CustomFootBallZJQButton.h
//  TicketProject
//
//  Created by sls002 on 13-6-27.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomFootBallZJQButton : UIButton {
    UIImageView *_pointLineImageView;
    
    BOOL         _lineHide;
}

@property (nonatomic, assign) UILabel *scoreLabel;
@property (nonatomic, assign) UILabel *oddsLabel;//赔率

@property (nonatomic, assign) BOOL lineHide;

@end
