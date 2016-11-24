//
//  InformationDetailViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-22.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocialControllerService.h"

@class TicketInformationActivity;
//@class InformationDetailModel;

@interface InformationDetailViewController : UIViewController<ASIHTTPRequestDelegate, UMSocialUIDelegate> {
    
    UILabel   *_titleLabel;       /**< 顶部 － 新闻标题 */
    UILabel   *_publishTimeLabel; /**< 顶部 － 新闻发表时间 */
    UILabel   *_tapCountLabel;    /**< 顶部 － 新闻点击次数 */
    UIWebView *_contentWebView;   /**< 中部 － 新闻点击次数 */
    
    UILabel *_pageLabel;            /**< 底部 － 新闻页数标识 */
    UIButton *_upButton;            /**< 底部 － 上一页按钮 */
    UIButton *_downButton;          /**< 底部 － 下一页按钮 */
    
    ASIFormDataRequest *_httpRequest;
    ASIFormDataRequest *_informationRequest;
    TicketInformationActivity  *_activity;
    
    NSMutableArray  *_ticketInformationArray;
    NSInteger       _totalPage;                 /**< 新闻总条数 */
    NSInteger       _curPage;                   /**< 当前条数 */
    NSInteger       _infoType;                  /**< 资讯类型 */
    NSInteger       _informationId;             /**< 资讯id */
    NSString        *_informationTitle;         /**< 资讯标题 */
    NSString        *_shareUrl;                 /**< 分享链接 */
}


- (id)initWithInfoType:(NSInteger)type ticketInfoActivity:(NSMutableArray *)ticketInformationArray page:(NSInteger)page curPage:(NSInteger)curPage;


@end
