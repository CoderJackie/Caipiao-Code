//
//  MatchTypeButton.h
//  TicketProject
//
//  Created by KAI on 14-12-6.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MatchButtonTypeOfGou,
    MatchButtonTypeOfYuan,
} MatchButtonType;

@interface MatchTypeButton : UIButton {
    UIImageView *_leftBtnImageView;
    UIImageView *_rightBtnImageView;
    UILabel     *_textLabel;
    
    MatchButtonType _matchButtonType;
    
    NSString *_title;
    BOOL _selfIsSelect;
    
}

@property (nonatomic , assign) BOOL selected;

- (id)initWithFrame:(CGRect)frame buttonType:(MatchButtonType)buttonType title:(NSString *)title;

@end
