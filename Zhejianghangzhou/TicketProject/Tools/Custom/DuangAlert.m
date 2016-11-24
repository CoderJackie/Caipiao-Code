//
//  DuangAlert.m
//  TicketProject
//
//  Created by sls002 on 16/9/8.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import "DuangAlert.h"

@interface DuangAlert (){
    NSArray *_settings;
    UIView *_whiteView;
    NSString *_title;
    NSMutableArray *_setButs;
    NSDictionary *_returnDic;
    UITextField *_textField;
    NSInteger _setIndex;
    void(^_backCall)(NSInteger,NSDictionary*);
}
@end

@implementation DuangAlert

//复制弹窗
- (instancetype)initWithTitle:(NSString *)title settings:(NSArray *)settings selected:(void(^)(NSInteger index,NSDictionary *backDic))selected{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _title = title;
        _settings = settings;
        _backCall = selected;
        [self base];
        [self loadSetting];
    }
    return self;
}

//待完善的最初：改为自定义中部view及反馈
- (void)loadSetting{
    _setButs = [NSMutableArray array];
    for (int i = 0; i<_settings.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20+20*i+(_whiteView.bounds.size.width-60)/2*i, 45, (_whiteView.bounds.size.width-60)/2, 35)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor grayColor] forState:0];
        if (i == 1) {
            _setIndex = 1;
            [button setSelected:YES];
            button.backgroundColor = [UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f];
            button.layer.borderColor = [UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f].CGColor;
        }else{
            button.layer.borderColor = [UIColor grayColor].CGColor;
        }
        button.layer.borderWidth = 1.0;
        button.layer.cornerRadius = 3.0;
        button.tag = 100+i;
        [button setTitle:_settings[i] forState:0];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_whiteView addSubview:button];
        [_setButs addObject:button];
    }
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 110, _whiteView.bounds.size.width-40, 40)];
    _textField.layer.borderWidth = 1.0;
    _textField.layer.borderColor = kGrayColor.CGColor;
    _textField.placeholder = @"请输入方案宣言";
    _textField.textAlignment = NSTextAlignmentCenter;
    [_whiteView addSubview:_textField];
    
}

- (void)base{
    CGFloat Screen_width = [UIScreen mainScreen].bounds.size.width;
    //        CGFloat Screen_height = [UIScreen mainScreen].bounds.size.height;
    
    //背景
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tap];
    
    _whiteView = [UIView new];
    _whiteView.frame = CGRectMake(0, 0, Screen_width-70, 200);
    _whiteView.center = self.center;
    _whiteView.alpha = 0;
    _whiteView.backgroundColor = [UIColor whiteColor];
    _whiteView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    _whiteView.layer.shadowColor = [UIColor blackColor].CGColor;
    _whiteView.layer.shadowOpacity = 1.0;
    [self addSubview:_whiteView];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_whiteView.frame), 35)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = kRedColor;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.text = _title;
    [_whiteView addSubview:titleLabel];
    
    //线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 35, _whiteView.width, 1.0)];
    line.backgroundColor = kRedColor;
    [_whiteView addSubview:line];
    
    //取消
    UIButton *canBut = [[UIButton alloc] initWithFrame:CGRectMake(0, _whiteView.height-40, _whiteView.width/2, 40)];
    canBut.backgroundColor = kGrayColor;
    canBut.titleLabel.font = [UIFont systemFontOfSize:15];
    [canBut setTitle:@"取消" forState:0];
    [canBut setTitleColor:[UIColor whiteColor] forState:0];
    [canBut addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_whiteView addSubview:canBut];
    
    //确认
    UIButton *doneBut = [[UIButton alloc] initWithFrame:CGRectMake(_whiteView.width/2, _whiteView.height-40, _whiteView.width/2, 40)];
    doneBut.backgroundColor = [UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f];
    doneBut.titleLabel.font = [UIFont systemFontOfSize:15];
    [doneBut setTitle:@"确定" forState:0];
    [doneBut setTitleColor:[UIColor whiteColor] forState:0];
    [doneBut addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [_whiteView addSubview:doneBut];
}

//点击取消
- (void)cancelAction{
    _backCall(0,@{@"index":[NSNumber numberWithInteger:_setIndex],@"text":_textField.text});
    [self dismiss];
}

//点击确定
- (void)doneAction{
    _backCall(1,@{@"index":[NSNumber numberWithInteger:_setIndex],@"text":_textField.text});
    [self dismiss];
}

//动画出现
- (void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [_whiteView setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
    [UIView animateWithDuration:0.2 animations:^{
        [_whiteView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        _whiteView.alpha = 1;
    }];
}

//动画移除
- (void)dismiss{
    [_whiteView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    [UIView animateWithDuration:0.2 animations:^{
        [_whiteView setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
        _whiteView.alpha = 0;
    }completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

-(void)buttonAction:(UIButton *)sender{
    for (UIButton *button in _setButs) {
        [button setSelected:NO];
        button.backgroundColor = [UIColor whiteColor];
        button.layer.borderColor = [UIColor grayColor].CGColor;
    }
    [sender setSelected:YES];
    sender.backgroundColor = [UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f];
    sender.layer.borderColor = [UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f].CGColor;
    _setIndex = sender.tag - 100;
}

-(void)tap{
    [self endEditing:YES];
}

@end
