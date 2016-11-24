//
//  PhoneVerificationViewControllerDelegate.h
//  TicketProject
//
//  Created by KAI on 15-1-28.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PhoneVerificationViewControllerDelegate <NSObject>

- (void)phoneVerificationPassWithPhoneNumber:(NSString *)phoneNumber;

@end
