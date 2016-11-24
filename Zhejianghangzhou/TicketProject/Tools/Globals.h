//
//  Globals.h
//  TicketProject
//
//  Created by KAI on 14-7-1.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

//日志开关
//网络通信日志开关
#define LOG_SWITCH_HTTP FALSE
#define LOG_SWITCH_HTTP_DETAIL FALSE
#define LOG_SWITCH_HTTP_REQUEST FALSE
#define LOG_SWITCH_VIEWFUNCTION FALSE
#define Log_SWITCH_HTTP_FORM    FALSE
//为了方便iphone和ipad适配使用的字体大小，方便整体修改
#define XFIponeIpadFontSize2 (IS_PHONE ? 2.0f : 5.0f)
#define XFIponeIpadFontSize7 (IS_PHONE ? 7.0f : 12.0f)
#define XFIponeIpadFontSize8 (IS_PHONE ? 8.0f : 13.0f)
#define XFIponeIpadFontSize9 (IS_PHONE ? 9.0f : 14.0f)
#define XFIponeIpadFontSize10 (IS_PHONE ? 10.0f : 15.0f)
#define XFIponeIpadFontSize11 (IS_PHONE ? 11.0f : 16.0f)
#define XFIponeIpadFontSize12 (IS_PHONE ? 12.0f : 17.0f)
#define XFIponeIpadFontSize13 (IS_PHONE ? 13.0f : 18.0f)
#define XFIponeIpadFontSize14 (IS_PHONE ? 14.0f : 19.0f)
#define XFIponeIpadFontSize15 (IS_PHONE ? 15.0f : 20.0f)
#define XFIponeIpadFontSize16 (IS_PHONE ? 16.0f : 21.0f)
#define XFIponeIpadFontSize17 (IS_PHONE ? 17.0f : 22.0f)
#define XFIponeIpadFontSize18 (IS_PHONE ? 18.0f : 23.0f)

#define XFIponeIpadFontSize21 (IS_PHONE ? 21.0f : 26.0f)

#define XFIponeIpadFontSize24 (IS_PHONE ? 24.0f : 29.0f)
//适配用的导航栏button的大小
#define XFIponeIpadNavigationLuckButtonRect (IS_PHONE ? CGRectMake(0, 0, 35, 35) : CGRectMake(0, 0, 45, 45)) //幸运选好按钮

#define XFIponeIpadNavigationSettingPromptButtonRect (IS_PHONE ? CGRectMake(0, 0, 23, 23) : CGRectMake(0, 0, 36, 36))//设置功能按钮专用Rect

#define XFIponeIpadNavigationplayingMethodButtonRect (IS_PHONE ? CGRectMake(0, 0, 22, 22) : CGRectMake(0, 0, 35, 35))//玩法功能按钮专用Rect
#define XFIponeIpadNavigationComeBackButtonRect (IS_PHONE ? CGRectMake(0, 0, 22, 22) : CGRectMake(0, 0, 35, 35))
#define XFIponeIpadNavigationCalendarFiltrateButtonRect (IS_PHONE ? CGRectMake(0, 0, 24, 24) : CGRectMake(0, 0, 35, 35))//日历筛选功能按钮专用Rect
#define XFIponeIpadNavigationChangeButtonRect (IS_PHONE ? CGRectMake(0, 0, 80, 22) : CGRectMake(0, 0, 120, 35))

#define LaunchChippedBottomFirstHeight (IS_PHONE ? 45 : 80) //合买的方案详情底部框上部的高
#define LaunchChippedBottomSecondHeight (IS_PHONE ? 0 : 0) //合买的方案详情底部框下部的高


#define AllLineWidthOrHeight (IS_PHONE ? 0.5 : 1.0)

/**0
 identify：设备类型 默认IOS
 appversion：版本号
 certificatetype：证书类型
 */
#define HTTP_REQUEST_UpdateAndHide                         @"0"    /**< 更新审核隐藏 */

/**1
 name：用户名
 password：md5加密的密码
 email：邮箱
 idcardnumber：身份证号码
 realityname：真实姓名
 mobile：手机号码
 type：类型    1为普通用户
 */
#define HTTP_REQUEST_UserRegiste                           @"1"    /**< 注册 */

/**2
 name：用户名
 password：md5加密的密码
 */
#define HTTP_REQUEST_Login                                 @"2"    /**< 登录 */

/**10
 lotteryId：请求的彩种id集合，用“，”分开
 playType：竞彩需要用到，一般为－1
 */
#define HTTP_RRQUEDT_GetLotteryInformation                 @"10"   /**< 获取彩种信息 */

/**11
 lotteryId：
 isuseId：
 multiple：
 share：
 buyShare：
 assureShare：
 schemeBonusScale：
 title：
 secrecyLevel：
 schemeSumMoney：
 schemeSumNum：
 chase：
 buyContent：
 consumeMoney：
 */
#define HTTP_REQUEST_BuyLotteryTicket                      @"11"   /**< 购买彩票 */

/**12
 schemeId： 
 buyShare：
 shareMoney：
 */
#define HTTP_RRQUEST_GetTogetherBuyProgramDetail           @"12"   /**< 获取合买方案详细信息 */

/**13
 lotteryId： 需要请求的所有彩种id
 */
#define HTTP_REQUEST_GetDrawTheWinningNumbersOfALottery    @"13"   /**< 获取各彩种获奖信息 */

/**14
 sort： 0 升序 1，降序
 sortType：0 进度 1 金额 2 每份金额 3 置顶 4，会员等级 5 时间
 */
#define HTTP_REQUEST_GetTogetherBuyProgram                 @"14"   /**< 获取合买方案列表 */

/**15
 id： 方案id
 */
#define HTTP_REQUEST_GetProgramIDDetail                    @"15"   /**< 根据某个方案id申请该方案的数据 */

/**16
 typeId： 
 pageIndex：
 pageSize：
 isRead：
 sortType：
 */
#define HTTP_REQUEST_GetMessageCenterAndReadState          @"16"   /**< 获取消息中心信息或更新某条信息的状态为已读或者其他状态 */

/**18
 lotteryId：需要查询的所有彩种id
 pageIndex：查询页数
 pageSize：每页记录数
 sort：0、进度  1、金额  2、每份金额  3、置顶  4、等级  5、时间
 sortType：升降序    0降序
 */
#define HTTP_REQUEST_GetAllOrderTicket                     @"18"   /**< 获取全部彩票订单 */

/**24
 id： 追号方案id
 */
#define HTTP_REQUEST_GetChaseProgramIDDetail               @"24"   /**< 根据某个追号方案id申请 */

/**25
 lotteryId：彩种id
 searchType：查找类型，默认－1
 searchTotal： 默认10
 startTime：某个时间段的开始时间
 endTime：牧歌时间段的结束时间
 pageIndex：申请页数，从1开始
 pageSize：每页记录数
 sort：      1
 sortType：升降序    0降序
 */
#define HTTP_REQUEST_GetWinningNumbersOfALotteryIssue      @"25"   /**< 获取普通彩种的所有中奖期号 */

/**26
 score： 要兑换的积分
 */
#define HTTP_REQUEST_ExchangeIntegral                      @"26"   /**< 兑换积分 */

/**28
 ID： 消息编号
 operateType：默认为0
 */
#define HTTP_REQUEST_GetMessageCenterDetail                @"28"   /**< 获取消息中心某条消息的详细 */

/**36
 name： 用户名
 mobile：手机号码
 realityName：真实姓名
 idCardnumber：身份证号码
 bankTypeID：银行编号
 bankTypeName：银行名
 bankId：开户支行名   不能用id，后台已经是直接存id，所以这个直接用名
 branchBankName：开户支行名
 bankCardNumber：银行卡号
 bankInProvinceId：银行所在的省编号
 provinceName：银行所在的省名
 bankInCityId：银行所在的市编号
 cityName：银行所在的市名
 bankUserName：银行用户名
 securityQuestionId：安全问题编号
 securityQuestionAnswer：安全问题答案
 */
#define HTTP_REQUEST_BindBankInformation                   @"36"   /**< 绑定用户的银行信息和安全问题 */

/**37  默认用户id
 money：提款金额
 moneyType：提款类型
 securityQuestionId：安全问题id
 securityQuestionAnswer：安全问题答案
 */
#define HTTP_REQUEST_DrawMoney                             @"37"   /**< 提款 */


#define HTTP_REQUEST_GETBankName                           @"40"   /**< 获取银行名 */

/**41  默认用户id
 */
#define HTTP_REQUEST_BindInformation                       @"41"   /**< 获取绑定身份信息和银行卡信息 */


#define HTTP_REQUEST_BindUserNameAndIdentityCard           @"43"   /**< 绑定用户姓名和身份证信息 */

/**44
 searchCondition：全部－1  投注1  中奖2  充值3  提款4
 pageIndex：请求第几页  从1开始
 pageSize：每页记录数
 sortType：0为时间降序
 startTime：需要查询的开始时间
 endTime：需要查询的结束时间
 */
#define HTTP_REQUEST_GetFundDetail                         @"44"   /**< 获取账户明细信息 */

/**45
 requestType：默认为2，其他不知道
 infoType：信息类型   1站点公告 2彩票咨询 3专家推荐
 informationId：信息id
 */
#define HTTP_REQUEST_GetAnnouncementDetail                 @"45"   /**< 获取咨询公告列表或详细信息 */

/**46
 schemeId：竞彩方案Id
 */
#define HTTP_REQUEST_GetJCOrderDetailMessage               @"46"   /**< 获取竞技足球竞技篮球的订单或方案对阵信息 */

/**46
 lotteryId：竞彩彩种id
 lastDay：现在的时间
 */
#define HTTP_REQUEST_GetJCWinningNumbersOfALotteryIssue    @"47"   /**< 获取竞技足球或竞技篮球的所有中奖期号 */

/**48
 title：反馈标题
 content：反馈正文
 tel：电话
 email：邮箱
 */
#define HTTP_REQUEST_FeedBack                              @"48"   /**< 反馈 */

/**49
 uid：用户id
 id：追号订单id
 */
#define HTTP_REQUEST_GetChaseOrderDetailMessage            @"49"   /**< 获取追号订单的详细信息 */

/**50
 lotteryId：需要查询的所有彩种id
 pageIndex：查询页数
 pageSize：每页记录数
 sort：
 isPurchasing：是否为合买方案  -1：所有 ；  0：合买 ；  1：代购 ；
 status：-1：全部； 1：中奖；2：未开奖；3：追号；4：合买
 sortType：
 */
#define HTTP_REQUEST_GetAllChaseOrderTicket                @"50"   /**< 获取全部追号订单期号信息 */

/**51
 lotteryIds：彩种id
 */
#define HTTP_REQUEST_GetAllUserWinPrizeInLottery           @"51"   /**< 获取全部用户的中奖信息 */

/**52
 不需要参数直接调用
 */
#define HTTP_REQUEST_GetEntrustBuyRule                     @"52"   /**< 委托投注规则 */

/**53
 不需要参数直接调用
 */
#define HTTP_REQUEST_GetTogetherBuyMinScale                @"53"   /**< 获取合买的认购比例 */

/**54
 mobile：手机号码
 */
#define HTTP_REQUEST_GetPhoneNumberCaptcha                 @"54"   /**< 获取短信验证码 */

/**55   
 mobile：手机号码
 code：验证码
 */
#define HTTP_REQUEST_VerificationPhoneNumberCaptcha        @"55"   /**< 验证手机短信验证码 */

/**57
 mobile：手机号码
 password：密码
 */
#define HTTP_REQUEST_ToResetPassword                       @"57"   /**< 重置密码 */

/**58
 UserId：用户id
 ClientUserId：客户端ID
 ChannelId：频道ID
 DeviceType：设备类型  安卓为3 IOS为4
 IsOpen：开奖推送0 关闭 1打开
 IsWin：中奖推送0 关闭 1打开
 Status： 0 离线 1在线
 */
#define HTTP_REQUEST_ServerRecordPushParameter             @"58"   /**< 将推送令牌等参数传到服务器存储 */

/**59
 mobile：手机号码
 */
#define HTTP_REQUEST_VerifyPhoneNumber                     @"59"   /**< 验证手机号码是否已经注册 */

/**60
 uid  用户ID
 password  原密码
 theNewPassword  新密码
 */
#define HTTP_REQUEST_UpdatePassword                        @"60"   /**< 根据旧密码修改新密码 */

/**61
 uid  用户ID
 */
#define HTTP_REQUEST_CheckUnReadWinMessage                 @"61"   /**< 查询用户是否有未读取的中奖 */

/**62
 UserId  用户ID
 */
#define HTTP_REQUEST_GetPushMessage                        @"62"   /**< 查询用户历史推送消息 */

/**63
 */
#define HTTP_REQUEST_GetCustomerServiceMessage             @"63"   /**< 查询客户信息 */

/**65
 */
#define HTTP_REQUEST_GetIntegral                           @"65"   /**< 查询积分信息 */

/**66
 pageIndex 页码号 从0开始
 */
#define HTTP_REQUEST_GetIntegralDetail                     @"66"   /**< 获取积分明细 */

/**67
 urlid 分享id
 infoType 分享类型
 */
#define HTTP_REQUEST_GetInformationUrl                     @"67"   /**< 获取资讯分享地址 */
/**71
 * 不需要参数直接调用
 */
#define HTTP_REQUEST_GetHandsel                            @"71"   /**< 根据用户获取活动信息 */
/**72
 LotteryID:72  彩种ID
 SchemeCodes:7207;[536(1)|537(2)];[AA1];-7207;[536(1)|538(1)];[AA1];-7207;[537(2)|538(1)];[AA1];                  方案代码
 GGWay:2串1-2串1-2串1    串数
 InvestNum:2-2-1   注数
 PlayTeam:536(1);1.52|537(2);3.05|-536(1);1.52|538(1);2.6|-537(2);3.05|538(1);2.6|         对阵信息，  赛事ID(胜)赔率;|赛事ID(胜)赔率;|赛事ID(胜)赔率;|赛事ID(胜)赔率;|赛事ID(胜)赔率;|赛事ID(胜)赔率;|
 Multiple:2    倍数
 CastMoney:18.54-15.80-15.86  预测金额
 PlayTypeID:7207  玩法ID
 MatchID:536,537,538   赛事ID
 CodeFormat:7207;[536(1)|537(2)|538(1)];[AA1]  ID;[赛事ID(1)|赛事ID(2)|赛事ID(1)];[AA1]
 PreBetType:1   是否为优化方案 0：否 1：是
 SchemeTitle:    方案标题
 SchemeContent:  方案描述
 AssureMoney: 保底
 Share:1     份数
 BuyShare:1     购买份数
 SecrecyLevel:0      保密等级
 SchemeBonusScale: 0.05
 */
#define HTTP_REQUEST_BuyBonusLotteryTicket                            @"72"   /**< 竞彩足球奖金优化付款接口 */
/**73
 不需要参数直接调用
 */
#define HTTP_REQUEST_PictureAddress                                   @"73"    /**< 获取轮播图片的地址借口 */

#define HTTP_REQUEST_MissingValues                                    @"74"    /**< 遗漏值请求接口 */

#define HTTP_REQUEST_WinningNumbers                                   @"75"    /**< 江苏块三10期开奖信息 */
#define HTTP_REQUEST_ColoseNumbers                                    @"76"    /**< 充值开关 */
#define HTTP_REQUEST_FormNumbers                                      @"77"    /**< 获取可以复制的方案列表 */
#define HTTP_REQUEST_CopyNumbers                                      @"78"    /**< 复制按钮 */
#define HTTP_REQUEST_NameNumbers                                      @"79"    /**< 红人名字 */
#define HTTP_REQUEST_AddBankCard                                      @"80"    /**< 添加绑定银行卡 */
#define HTTP_REQUEST_RemoveBankCard                                   @"81"    /**< 移除绑定银行卡 */
#define HTTP_REQUEST_GetBankCardList                                  @"82"    /**< 查询已绑定的银行卡 */

@interface Globals : NSObject {
    BOOL _tabBarHidden;
    BOOL _isShake;
    NSMutableDictionary *_homeViewInfoDict  /**< 彩种信息 */;
}

@property (nonatomic) BOOL tabBarHidden;
@property (nonatomic) BOOL isShake;
@property (nonatomic ,assign) NSMutableDictionary *homeViewInfoDict;
@property (nonatomic, assign) CGFloat commission;
@property (nonatomic ,assign) CGFloat minBuyScale;

@property (nonatomic) BOOL isInHomeView;
@property (nonatomic) BOOL isNeedRefresh;
@property (nonatomic) NSTimeInterval sendNoteCanUserTime;
@property (nonatomic, copy) NSString *registeRequestPhoneNumber;
@property (nonatomic) BOOL isStorePassword;

@property (nonatomic, copy) NSString *pushBaiDuAppId;
@property (nonatomic, copy) NSString *pushBaiDuUserid;
@property (nonatomic, copy) NSString *pushBaiDuChannelid;
@property (nonatomic, assign) NSInteger *pushBaiDuReturnCode;
@property (nonatomic, copy) NSString *pushBaiDuRequestid;

@property (nonatomic) NSTimeInterval serverLocalTimeInterval;

/** 将yyyy-MM-dd日期转换成 yyyy年MM月dd日
 @param  date  需要转化的时间字符串
 @return yyyy年MM月dd日 的字符串  */
+ (NSString *)getConvertDateStringWithDate:(NSString *)date;

+ (NSString *)getConvertDateStringWithDate_2:(NSString *)date;

+ (NSString *)getWeekDay:(NSString *)date;

+ (NSString *)getNowDateString;
//判断时间是否过期
+ (BOOL)judgeIsOutOfDate:(NSString *)endtimeStr;

//将日期转为NSInteger 类型，并可以计算几个月前的大概int类型
+ (NSInteger)timeConvertToIndegerWithStringWithStringTime:(NSString *)stringTime beforeMonth:(NSInteger)beforeMonth;

+ (NSInteger)findDetailIndexWithLotteryId:(NSInteger)lotteryId lotteryIDArray:(NSArray *)lotteryIDArray;

//对一个数组内的数字进行升序排序     快速排序法（次级排序）
+ (void)sortWithNumberArray:(NSMutableArray *)numberArray;

//在最小数和最大数之间随机一个数字出来
+ (NSInteger)getRandomBetweenTheMaxNum:(NSInteger)maxNum minNum:(NSInteger)minNum;

+ (NSString *)autoAdaptiveIphoneIpadPhotoName:(NSString *)photoName;

+ (NSTimeInterval)calculateCurrentTimeIntervalWithTime:(NSString *)compareTime;

+ (NSTimeInterval)getTimeWithIntervalTime:(NSTimeInterval)IntervalTime;

+ (CGSize)defaultSizeWithString:(NSString *)str fontSize:(CGFloat)fontSize;

+ (void)createBlackWithImageViewWithFrame:(CGRect)frame inSuperView:(UIView *)superView;

+ (void)makeLineWithFrame:(CGRect)frame inSuperView:(UIView *)superView;

+ (NSAttributedString *)getAttriButedWithText:(NSString *)text fontSize:(CGFloat)fontSize;

+ (NSString *)getCaptcha;

+ (BOOL)isPhoneNumber:(NSString *)phoneNumber;

+ (void)alertWithMessage:(NSString *)message;

+ (void)alertWithMessage:(NSString *)message delegate:(id)delegate tag:(NSInteger)tag;

@end
