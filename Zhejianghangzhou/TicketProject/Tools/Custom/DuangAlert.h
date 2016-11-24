//
//  DuangAlert.h
//  TicketProject
//
//  Created by sls002 on 16/9/8.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DuangAlert : UIView

//复制弹窗
- (instancetype)initWithTitle:(NSString *)title settings:(NSArray *)settings selected:(void(^)(NSInteger index,NSDictionary *backDic))selected;

- (void)show;

@end
