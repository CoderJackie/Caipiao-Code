//
//  LuckyPickViewController.h
//  TicketProject
//
//  Created by sls002 on 13-7-11.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogPickerViewDelegate.h"


@class DialogLuckyNumberView;
@class DropDownView;

@interface LuckyPickViewController : UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, DialogPickerViewDelegate> {
    
    UIButton     *_comeBackBtn;
    
    UIButton     *_lotteryDropBtn;
    UIButton     *_luckyTypeDropBtn;
    UIView       *_luckyBtnBackView;
    UIButton     *_selectLuckyNumberBtn;
    UIImageView  *_luckyLineImageView;
    UITableView  *_luckyTableView;
    UIButton     *_betBtn;
    
    UIButton     *_yearBtn;      /**< 年 */
    UIButton     *_monthBtn;     /**< 月 */
    UIButton     *_dayBtn;       /**< 日 */
    
    UITextField  *_userNameTextField;
    
    UITextField  *_boyNameTextField;
    UITextField  *_girlNameTextField;
    
    CGFloat       _luckyLineImageViewStartMinX;
    CGFloat       _luckyLineImageViewStartMinY;
    CGFloat       _luckyLineImageViewEndMinX;
    CGFloat       _luckyLineImageViewEndMinY;
    
    NSArray      *_lotteryArray;
    NSArray      *_luckyTypeArray;
    NSMutableDictionary *_selectLotteryIndexDict;
    NSMutableDictionary *_selectLuckyTypeIndexDict;
    NSMutableDictionary *_selectDateIndexDict;
    
    NSDictionary   *_lotteryDic;     /**< 彩种名字典 */
    NSDictionary   *_infoDic;        /**<  */
    NSMutableArray *_luckyNumberArray;    /**<  */
}

@property(nonatomic, assign)Service * oneS;

- (id)initWithLotteryDictionary:(NSDictionary *)dic;

@end
