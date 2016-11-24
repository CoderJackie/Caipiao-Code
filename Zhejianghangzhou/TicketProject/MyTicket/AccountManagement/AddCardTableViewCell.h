//
//  AddCardTableViewCell.h
//  TicketProject
//
//  Created by jsonLuo on 16/9/23.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCardTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;              /**< 标题 */
@property (nonatomic, strong) UITextField *contentTectFiedld;   /**< 对应的内容 */


/**cell的高度*/
+ (CGFloat)cellHeight;

@end
