//
//  _solutionDetailViewController.m 合买 方案详情
//  TicketProject
//
//  Created by sls002 on 13-6-6.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20140724 14:27（洪晓彬）：修改代码规范，改进生命周期，处理内存
//  20140806 15:59（洪晓彬）：进行ipad适配
//  20150820 10:59（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#define Mywidth ([UIScreen mainScreen].bounds.size.width)
#define Myheight ([UIScreen mainScreen].bounds.size.height)
#define LaunchChippedListViewTabelCellHeight (IS_PHONE ? 85.0f : 130.0f)

#import "SolutionDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "CustomLabel.h"
#import "FCViewController.h"
#import "LaunchChippedListViewController.h"
#import "JCSolutionDetailViewController.h"
#import "MDRadialProgressView.h"
#import "MSKeyboardScrollView.h"
#import "UserLoginViewController.h"
#import "SolutionDetailBottomView.h"
#import "XFNavigationViewController.h"
#import "XFTabBarViewController.h"
#import "Model.h"

#import "NSString+CustomString.h"
#import "Globals.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"
#import "TitleOrDetailCell.h"
#import "SVProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#define kInputViewHeight 40
#define BottomViewHeight (IS_PHONE ? 100.0f : 150.0f) //底部高度

@interface SolutionDetailViewController ()<UITableViewDataSource,UITableViewDelegate,CustomAlertViewDelegate,UITextFieldDelegate>
@property(nonatomic,strong)NSArray *DetailArray;
@property(nonatomic,strong)UITextField *winBrokerageTextField;
@property(nonatomic,strong)UILabel *moneyLabel;
@end
#pragma mark -
#pragma mark @implementation HomeViewController
@implementation SolutionDetailViewController
#pragma mark Lifecircle

//点击合买主页的方案详情  参数为点击的方案字典
- (id)initWithSolutionDic:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
        self.title = @"方案详情";
        _solutionDetail = dictionary;
        NSLog(@"方案详情%@",_solutionDetail);
        
        [self.xfTabBarController setTabBarHidden:YES];
        _globals = [[Globals alloc] init];
        _globals.tabBarHidden = NO;
    }
    return self;
}


- (void)loadView{
    [super loadView];
    //内容详情设置
    
    /*
     stopTime//认购截止时间
     isuseName//认购期次
     description//宣言
     schemeNumber//方案编号
     initiateTime//发起时间
     sumMoney;//方案总金额
     money//单倍金额
     multiple//倍数
     lotteryId//彩种ID
     lotteryName //彩种名称
     passType// 获取玩法名称
     委托状况：成功；
     方案类型：预约订购；
     委托状况：成功
     中奖状况：未开奖
     */
    _DetailArray = @[[NSString stringWithFormat:@"第%@期",[_solutionDetail valueForKey:@"isuseName"] ? [_solutionDetail valueForKey:@"isuseName"] : @""],
                     [_solutionDetail valueForKey:@"description"] ? [_solutionDetail valueForKey:@"description"] : @"",
                     [_solutionDetail valueForKey:@"schemeNumber"] ? [_solutionDetail valueForKey:@"schemeNumber"] : @"",
                     [_solutionDetail valueForKey:@"initiateName"] ? [_solutionDetail valueForKey:@"initiateName"] : @"",
                     [_solutionDetail valueForKey:@"initiateTime"] ? [_solutionDetail valueForKey:@"initiateTime"] : @"",
                     @"预约订购",
                     [NSString stringWithFormat:@"%.1f元%@倍",[[_solutionDetail valueForKey:@"sumMoney"] floatValue],[_solutionDetail valueForKey:@"multiple"]],
                     [_solutionDetail valueForKey:@"passType"] ? [_solutionDetail valueForKey:@"passType"] : @"",
                     @"成功",
                     @"未开奖",
                     [(NSArray *)[_solutionDetail valueForKey:@"buyContent"] count]>0 ? @"公开" : [_solutionDetail valueForKey:@"secretMsg"] ? [_solutionDetail valueForKey:@"secretMsg"] : @""];
    
    
    //返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(getBackTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect newFrame = self.view.frame;
    newFrame.size.height-=164;
    UITableView *tableViiew = [[UITableView alloc] initWithFrame:newFrame style:UITableViewStylePlain];
    tableViiew.delegate = self;
    tableViiew.dataSource = self;
    [tableViiew registerClass:[TitleOrDetailCell class] forCellReuseIdentifier:@"solutionDetail"];
    [self.view addSubview:tableViiew];
    
    [self loadBottomView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textinputStart:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textinputEnd:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _DetailArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TDCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 40)];
    label.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    label.font = [UIFont systemFontOfSize:IS_PHONE?11:13];
    label.textColor = [UIColor grayColor];
    label.text = [NSString stringWithFormat:@"  %@  %@  认购截止时间：%@",
                  [_solutionDetail valueForKey:@"lotteryName"],
                  [_solutionDetail valueForKey:@"passType"],
                  [_solutionDetail valueForKey:@"stopTime"]];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TitleOrDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"solutionDetail" forIndexPath:indexPath];
    cell.titleLabel.text = [@[@"购买期次",@"方案宣言",@"方案编号",@"发起人",@"发起时间",@"方案类型",@"方案金额",@"投注方式",@"委托状况",@"中奖状况",@"选号详情",@"",@""][indexPath.row] stringByAppendingString:@":"];
    cell.detailLabel.text = _DetailArray[indexPath.row];
    
    if ([cell.titleLabel.text isEqualToString:@"发起人:"]) {
        
        NSString *nameStirng = [NSString stringWithFormat:@"%@",_DetailArray[indexPath.row]];
        
        if (nameStirng.length>2) {
            //发起人隐藏
            cell.detailLabel.text = [[nameStirng substringToIndex:nameStirng.length-2] stringByAppendingString:@"**"];
        }
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 10) {
        //examineBtn 中部 查看
        CGRect examineBtnRect = CGRectMake(kScreenSize.width-100, 4, 60, 28);
        _examineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_examineBtn setFrame:examineBtnRect];
        [_examineBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [_examineBtn setTitle:@"查看" forState:UIControlStateNormal];
        [_examineBtn setTitleColor:[UIColor colorWithRed:0xfd/256.0f green:0xae/256.0f blue:0x24/256.0f alpha:1] forState:UIControlStateNormal];
        [_examineBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"shadeButton.png" ]]forState:UIControlStateNormal];
        [_examineBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"shadeButton.png" ]] forState:UIControlStateHighlighted];
        [_examineBtn addTarget:self action:@selector(checkSelectDetail:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:_examineBtn];
        
        if([(NSArray *)[_solutionDetail valueForKey:@"buyContent"] count] == 0){
            [_examineBtn setHidden:YES];
        }
    }
    return cell;
}

#pragma mark -
//底部视图
- (void)loadBottomView{
    /*****位置调整*****/
    CGFloat firstInterval = IS_PHONE ? 10.0f : 20.0f;   //前间隔
    CGFloat topInset = IS_PHONE ? 10.0f : 15.0f;        //上间隔
    CGFloat firstwidth = IS_PHONE ? 30.0f : 40.0f;      //第一个字符占位
    CGFloat textWidth = IS_PHONE ? 60.0f : 90.0f;       //投注长度
    CGFloat singleWidth = IS_PHONE ? 150.0f : 200.0f;   //单注视图长度
    CGFloat secondTextY = IS_PHONE ? 60.0f : 80.0f;     //总金额视图Y值
    CGFloat secondTextW = IS_PHONE ? 120.0f : 150.0f;   //总金额视图长度
    CGFloat copButtonW = IS_PHONE ? 80.0f : 100.0f;     //复制按钮长度
    /****************/
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height-164, kScreenSize.width, 100)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [bottomView setTag:666];
    [self.view addSubview:bottomView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBottomView)];
    [bottomView addGestureRecognizer:tap];
    
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(firstInterval, topInset, firstwidth, firstwidth)];
    firstLabel.text = @"投";
    firstLabel.font = [UIFont systemFontOfSize:AllFontSize];
    [bottomView addSubview:firstLabel];
    
    UIButton *cutButton_1 = [[UIButton alloc] initWithFrame:CGRectMake(firstInterval+firstwidth-5, topInset, firstwidth, firstwidth)];
    [cutButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateNormal];
    [cutButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateHighlighted];
    [cutButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateSelected];
    [cutButton_1 setTag:0];
    [cutButton_1 addTarget:self action:@selector(addCutTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cutButton_1];
    
    CGRect winBrokerageTextFieldRect = CGRectMake(CGRectGetMaxX(cutButton_1.frame),topInset,textWidth,firstwidth);
    _winBrokerageTextField = [[UITextField alloc]initWithFrame:winBrokerageTextFieldRect];
    [_winBrokerageTextField setFont:[UIFont systemFontOfSize:AllFontSize]];
    [_winBrokerageTextField setReturnKeyType:UIReturnKeyDone];
    [_winBrokerageTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_winBrokerageTextField setText:@"1"];
    [_winBrokerageTextField setTextAlignment:NSTextAlignmentCenter];
    [_winBrokerageTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_winBrokerageTextField setBackground:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blackLineAngleButton.png"]] stretchableImageWithLeftCapWidth:4.0f topCapHeight:4.0f]];
    [_winBrokerageTextField setDelegate:self];
    _winBrokerageTextField.userInteractionEnabled = YES;
    [bottomView addSubview:_winBrokerageTextField];
    
    CGRect addButton_1Rect = CGRectMake(CGRectGetMaxX(winBrokerageTextFieldRect),topInset,firstwidth,firstwidth);
    UIButton *addButton_1 = [[UIButton alloc] initWithFrame:addButton_1Rect];
    [addButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateNormal];
    [addButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateHighlighted];
    [addButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateSelected];
    [addButton_1 setTag:1];
    [addButton_1 addTarget:self action:@selector(addTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:addButton_1];
    
    UILabel *singleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addButton_1Rect)+5, topInset, singleWidth, firstwidth)];
    NSInteger moenyLength = [NSString stringWithFormat:@"%ld",(long)[_moeny intValue]].length;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"倍   单倍金额%ld元",(long)[_moeny intValue]]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(attributedString.length-moenyLength-1, moenyLength)];
    [singleLabel setAttributedText:attributedString];
    [singleLabel setFont:[UIFont systemFontOfSize:AllFontSize]];
    [bottomView addSubview:singleLabel];
    
    _moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(firstInterval, secondTextY, secondTextW, firstwidth)];
    attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"需支付%ld元",(long)[_moeny intValue]]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(attributedString.length-moenyLength-1, moenyLength)];
    [_moneyLabel setAttributedText:attributedString];
    [_moneyLabel setFont:[UIFont systemFontOfSize:AllFontSize]];
    [bottomView addSubview:_moneyLabel];
    
    UIButton *copyButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenSize.width-copButtonW-20, secondTextY-5, copButtonW, firstwidth+5)];
    [copyButton setTitle:@"复制跟单" forState:0];
    copyButton.backgroundColor = [UIColor orangeColor];
    [copyButton.titleLabel setFont:[UIFont systemFontOfSize:AllFontSize]];
    [copyButton.layer setCornerRadius:3.0];
    [copyButton addTarget:self action:@selector(queding:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:copyButton];
    
    [self.view addSubview:bottomView];
    
    [bottomView.layer setShadowColor:[UIColor grayColor].CGColor];
    [bottomView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [bottomView.layer setShadowOpacity:1.0];
}

//减注
-(void)addCutTouchUpInside:(UIButton *)sender{
    NSInteger count = [_winBrokerageTextField.text integerValue];
    if (count>1) {
        _winBrokerageTextField.text = [NSString stringWithFormat:@"%ld",(long)count-1];
    }
    [self moneyChange];
}
//加注
- (void)addTouchUpInside:(UIButton *)sender{
    NSInteger count = [_winBrokerageTextField.text integerValue];
    _winBrokerageTextField.text = [NSString stringWithFormat:@"%ld",(long)count+1];
    [self moneyChange];
}

-(void)moneyChange{
    NSInteger all = [_moeny intValue]*[_winBrokerageTextField.text intValue];
    NSInteger allLength = [NSString stringWithFormat:@"%ld",(long)all].length;
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"需支付%ld元",(long)all]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(attributedString.length-allLength-1, allLength)];
    [_moneyLabel setAttributedText:attributedString];
}

#pragma mark -
#pragma mark 复制
-(void)queding:(UIButton *)button
{
    if ([_winBrokerageTextField.text intValue] == 0) {
        _winBrokerageTextField.text = @"1";
    }
    CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:self content:[NSString stringWithFormat:@"本次支付将从您的账号中扣除%ld元",(long)([_moeny intValue]*[_winBrokerageTextField.text intValue])] leftText:@"取消" rightText:@"确定"];
    [customAlert setTag:76];
    [customAlert show];
}

-(void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if([UserInfo shareUserInfo].userID) {
            
            [SVProgressHUD showWithStatus:@"加载中"];
            
            ASIFormDataRequest *_copyRequest = [ASIFormDataRequest new];
            
            [_copyRequest clearDelegatesAndCancel];
            
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
            
            NSInteger all = [_moeny intValue]*[_winBrokerageTextField.text intValue];
            [infoDic setObject:_schemeId forKey:@"schemeId"];
            [infoDic setObject:_winBrokerageTextField.text forKey:@"multiple"];
            [infoDic setObject:[NSNumber numberWithInteger:all] forKey:@"money"];
            
            _copyRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_CopyNumbers userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
            NSLog(@"%@",infoDic);
            NSLog(@"%@",_copyRequest.url);
            
            [_copyRequest setDelegate:self];
            [_copyRequest setDidFinishSelector:@selector(copyFinished:)];
            [_copyRequest startAsynchronous];
            
            
        }else{
            [XYMPromptView defaultShowInfo:@"请先登录才能复制哦~" isCenter:NO];
        }
    }
}

- (void)copyFinished:(ASIHTTPRequest *)request
{
    [SVProgressHUD showSuccessWithStatus:@"复制成功"];
    [SVProgressHUD dismiss];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getBackTouchUpInside];
    });
}

//查看选号详情
-(void)checkSelectDetail:(id)sender {
    if([_solutionDetail intValueForKey:@"lotteryId"] == 72 || [_solutionDetail intValueForKey:@"lotteryId"] == 73 || [_solutionDetail intValueForKey:@"lotteryId"] == 45) {
        if(![UserInfo shareUserInfo].userID) {
            UserLoginViewController *login = [[UserLoginViewController alloc]init];
            XFNavigationViewController *loginNav = [[XFNavigationViewController alloc]initWithRootViewController:login];
            [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = loginNav;
            [self.view.window.rootViewController presentViewController:loginNav animated:YES completion:nil];
            return;
        } else {
            JCSolutionDetailViewController *jcDetail = [[JCSolutionDetailViewController alloc] initWithSchemeDictionary:_solutionDetail];
            XFNavigationViewController *detailNav = [[XFNavigationViewController alloc] initWithRootViewController:jcDetail];
            [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = detailNav;
            [self.view.window.rootViewController presentViewController:detailNav animated:YES completion:nil];
            return;
        }
    }
    
    FCViewController *jcDetail = [[FCViewController alloc]initWithSchemeDictionary:_solutionDetail];
    XFNavigationViewController *detailNav = [[XFNavigationViewController alloc]initWithRootViewController:jcDetail];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = detailNav;
    [self.view.window.rootViewController presentViewController:detailNav animated:YES completion:nil];
}

- (void)getBackTouchUpInside{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.text.length == 0) {
        textField.text = @"1";
    }
    [self moneyChange];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"textChange:%@",textField.text);
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSLog(@"text:%@",text);
    if ([text length] > 5)
        return NO;
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([[[touches anyObject] view] tag] != 666) {
        [self.view endEditing:YES];
    }
}

- (void)tapBottomView{
    [self.view endEditing:YES];
}

#pragma mark notifications

- (void)textinputStart:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    UIView *bottomView = [self.view viewWithTag:666];
    int height = keyboardRect.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect newFrame = bottomView.frame;
        newFrame.origin.y = kScreenSize.height-64-100-height;
        [bottomView setFrame:newFrame];
        [bottomView setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    }];
    
}

- (void)textinputEnd:(NSNotification *)notification {
    UIView *bottomView = [self.view viewWithTag:666];
    if (bottomView) {
        [UIView animateWithDuration:0.2 animations:^{
            [bottomView setFrame:CGRectMake(0, kScreenSize.height-64-100, kScreenSize.width, 100)];
        }];
    }
}

@end
