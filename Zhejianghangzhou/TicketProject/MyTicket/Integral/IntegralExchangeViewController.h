//
//  IntegralExchangeViewController.h
//  TicketProject
//
//  Created by KAI on 15-4-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleBtn;

@interface IntegralExchangeViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    CircleBtn        *_circleBtn;
    UILabel          *_accumulatePromptLabel;
    UITextField      *_exchangeTextField;
    UICollectionView *_collectionView;
    
    UIView        *_overlayView;
    
    ASIFormDataRequest *_httpRequest;
    
    NSArray *_itemMoneyArray;
    NSInteger _exchangeIntegral;
}

@end
