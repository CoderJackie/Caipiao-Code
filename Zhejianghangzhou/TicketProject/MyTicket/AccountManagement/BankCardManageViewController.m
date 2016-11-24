//
//  BankCardManageViewController.m
//  TicketProject
//
//  Created by jsonLuo on 16/9/22.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import "BankCardManageViewController.h"
#import "BankCardTableViewCell.h"
#import "Globals.h"
#import "AddBankCardViewController.h"
#import "XFTabBarViewController.h"
#import "UserInfo.h"
#import "AccountInfoViewController.h"

@interface BankCardManageViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *cardInfoArray; //已绑定的银行卡信息
    BOOL _select;
    void(^_callBack)(NSDictionary *retDic);
}

@end

@implementation BankCardManageViewController

- (instancetype)initWithSelct:(BOOL)select callBack:(void(^)(NSDictionary *retDi))callBack{
    if (self = [super init]) {
        _select = select;
        _callBack = callBack;
    }
    return self;
}

-(void)dealloc{
    cardInfoArray = nil;
}

- (void)loadView{
    [super loadView];
    if (_select) {
        [self setTitle:@"选择银行卡"];
    }else{
        [self setTitle:@"银行卡管理"];
    }
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.xfTabBarController setTabBarHidden:YES];
    cardInfoArray = [[NSArray alloc] init];
    
    //添加银行卡
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBankCard)];
    [self.navigationItem setRightBarButtonItem:addItem];
    [addItem setTag:226];
    
    //银行卡列表
    UIView *footerView = [[UIView alloc] init];
    CGRect tableRect = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setTag:666];
    [tableView registerClass:[BankCardTableViewCell class] forCellReuseIdentifier:@"cardManage"];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setTableFooterView:footerView];
    [self.view addSubview:tableView];
    
    [self getBindedCards];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.xfTabBarController setTabBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return cardInfoArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [BankCardTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BankCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardManage"];
    if (cardInfoArray && cardInfoArray.count>indexPath.row) {
        NSDictionary *indexDic = [cardInfoArray objectAtIndex:indexPath.row];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.cardNumberLabel setText:[NSString stringWithFormat:@"%@",[indexDic objectForKey:@"BankCardNumberOFF"]]];
        [cell.bankInfomationLabel setText:[NSString stringWithFormat:@"%@ \t\t 持卡人:%@",[indexDic objectForKey:@"BankTypeName"], [indexDic objectForKey:@"BankUserName"]]];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_select) {
        if (_callBack) {
            if (cardInfoArray && cardInfoArray.count>indexPath.row)
            {
                _callBack([cardInfoArray objectAtIndex:indexPath.row]);
            }
        }
    }else{
        if (cardInfoArray && cardInfoArray.count>indexPath.row){
            BankCardManageViewController *weakSelf = self;
            AddBankCardViewController *addVC = [[AddBankCardViewController alloc] initWithisDetail:YES info:[cardInfoArray objectAtIndex:indexPath.row] succeed:^{
                [weakSelf getBindedCards];
            }];
            [self.navigationController pushViewController:addVC animated:YES];
        }
    }
}

#pragma mark -
#pragma mark 已绑定银行卡查询
- (void)getBindedCards {
    UserInfo *userInfo = [UserInfo shareUserInfo];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetBankCardList userId:userInfo.userID infoDict:nil]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(getCardsFinish:)];
    [request setDidFailSelector:@selector(getCardsFaild:)];
    [request startAsynchronous];
    [SVProgressHUD showWithStatus:@"加载中"];
}

- (void)getCardsFinish:(ASIHTTPRequest *)request {
    NSLog(@"-----opt:82------%@",[request responseString]);
    NSLog(@"-----opt:82URL----%@",[request url]);
    
    NSDictionary *dic = [[request responseString] objectFromJSONString];
    if (dic && [[dic objectForKey:@"error"] integerValue] == 0) {
        [SVProgressHUD showSuccessWithStatus:@"加载完成"];
        cardInfoArray = nil;
        cardInfoArray = [[dic objectForKey:@"bankCardList"] isKindOfClass:[NSArray class]] ? [dic objectForKey:@"bankCardList"] : @[];
        UIView *addBut = [self.navigationController.navigationBar viewWithTag:226];
        if (addBut) {
            [addBut setHidden:cardInfoArray.count>=5];//已有五张时不能再添加
        }
        
        UITableView *tableView = [self.view viewWithTag:666];
        if (tableView) {
            [tableView reloadData];
        }
        
    }else if (dic){
        [SVProgressHUD showErrorWithStatus:[dic objectForKey:@"msg"]];
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
    }
    
}

- (void)getCardsFaild:(ASIHTTPRequest *)requset {
    [SVProgressHUD showErrorWithStatus:@"加载失败"];
}

#pragma makr barControl
#pragma mark 添加银行卡
- (void)addBankCard{
    UserInfo *userInfo = [UserInfo shareUserInfo];
    if (!userInfo.realName) {
        [self.navigationController pushViewController:[AccountInfoViewController new] animated:YES];
        return;
    }
    AddBankCardViewController *addVC = [[AddBankCardViewController alloc] initWithisDetail:NO info:nil succeed:^{
        [self getBindedCards];
    }];
    [self.navigationController pushViewController:addVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
