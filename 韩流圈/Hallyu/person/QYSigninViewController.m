//
//  QYSigninViewController.m
//  Hallyu
//
//  Created by 宁晓明 on 14-8-10.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYSigninViewController.h"
#import "QYSigniDetailViewController.h"
#import "RegexKitLite.h"

@interface QYSigninViewController ()

@end

@implementation QYSigninViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}



#if 0
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //取消注册按钮
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancheButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    //消除输入键盘的手势
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(becomeFirstResponderForView)];
    [self.view addGestureRecognizer:tap];
    
    
    //继续按钮不可交互
    self.contineButton.userInteractionEnabled = NO;
    self.contineButton.alpha = 0.3f;
    
    
}


#pragma mark - UIMethod
//消除输入键盘
- (void)becomeFirstResponderForView
{
    [self.textField resignFirstResponder];
    [self.keyCodeLabel resignFirstResponder];
    [self.view becomeFirstResponder];
}
//取消注册
- (IBAction)cancheSigin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



//刷新UI
- (void)refreshUIShow
{
    //显示倒计时的Label
    self.showLabel.hidden = NO;
    //发送请求按钮不可交互
    self.button.userInteractionEnabled = NO;
    self.button.alpha = 0.3f;
    //继续按钮可交互
    self.contineButton.userInteractionEnabled = YES;
    self.contineButton.alpha = 1;
    //验证码输入框可交互
    self.keyCodeLabel.enabled = YES;
    
    self.time = 45;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordTiming) userInfo:nil repeats:YES];
}

//计时方法
- (void)recordTiming
{
    self.time -= 1;
    self.showLabel.text = [NSString stringWithFormat:@"验证码已发送，%d秒后点击重新发送。",self.time];
    if (self.time == 0) {
        [self.timer invalidate];
        //更改接受验证码按钮可交互
        self.button.userInteractionEnabled = YES;
        self.button.alpha = 1.0f;
        self.showLabel.hidden = YES;
        //继续按钮不可交互
        //继续按钮可交互
        self.contineButton.userInteractionEnabled = NO;
        self.contineButton.alpha = 0.3;
    }
}

//push到下一页面
- (void)pushToNextViewController
{
    //push到下一页面
    QYSigniDetailViewController *siginCtrl = [[QYSigniDetailViewController alloc] init];
    siginCtrl.phoneNumber = self.textField.text;
    [self.navigationController pushViewController:siginCtrl animated:YES];
}

#pragma mark - AcitonMethod
//验证输入的手机号码
- (BOOL)checkInputText
{
    //^((\\+86)|(86))?[1][3-8]+\\d{9}附带国家编号的正则
    NSString *regexString = @"^[1][3-8]+\\d{9}";
    NSString *tempString = self.textField.text;
    NSArray *matchStringArray = [tempString componentsMatchedByRegex:regexString];
    if (matchStringArray.count != 1 || tempString.length != 11) {
        UIAlertView *alertView =  [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的手机号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}
//验证是否输入验证码
- (BOOL)checkOutKeyCode
{
    if (self.keyCodeLabel.text.length == 0) {
        UIAlertView *alertView =  [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入验证码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    return YES;
}

//接收验证码
- (IBAction)receiveCheckCode:(UIButton *)sender {
    
    //验证输入的手机号码是否正确
    if ([self checkInputText]) {
        //向服务器发送验证码请求
        [self sendHttpRequestForCheckCode];
        //刷新界面UI
        [self refreshUIShow];
    }
}
- (IBAction)checkOutKeyCode:(id)sender
{
    [self sendHtttRequestCheckTheCode];
}


#pragma mark - RequestHttpActionMethod
//获取验证码
- (void)sendHttpRequestForCheckCode
{
    //    NSString *phoneNumber =  self.textField.text;
    
}

//校验验证码
- (void)sendHtttRequestCheckTheCode
{
    //       NSString *checkCode = self.textField.text;
    if ([self checkOutKeyCode]) {
        [self pushToNextViewController];
    }
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
#endif
@end
