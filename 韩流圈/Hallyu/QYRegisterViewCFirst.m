//
//  QYRegisterViewCFirst.m
//  Hallyu
//
//  Created by qingyun on 14-9-3.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYRegisterViewCFirst.h"
#import "QYRegisterViewCSecond.h"
#import "RegexKitLite.h"
#import "AFNetworking.h"
#import "QYUserSingleton.h"

typedef  void(^blc)();
@interface QYRegisterViewCFirst () <UITextFieldDelegate>

@end

@implementation QYRegisterViewCFirst

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
    self.topLabel.text = @"您的手机号？";
    self.textField.placeholder = @"请输入您的手机号";
    self.textField.delegate = self;
    [self.makeSureBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
}

- (void)doMakerSuerAction:(UIButton *)sender
{


    if (![self checkInputText]) {
        return;
    }
    _user = [QYUserSingleton sharedUserSingleton];
    _user.phoneNum = self.textField.text;

#warning TODO 提交三方接口，获取验证码，

#warning 获取验证码赋值给user.
    
    
    QYRegisterViewCSecond *viewC = [[QYRegisterViewCSecond alloc]init];
    [self.navigationController pushViewController:viewC animated:YES];
    
}

//验证输入框中的信息
- (BOOL)checkInputText
{
    NSString *tempNumberString = self.textField.text;

    //验证手机号码
    NSString *mobile = @"^1(3[0-9]|4[57]|5[0-35-9]|7[6-8]|8[0-9])\\d{8}$";
    NSPredicate *regexMobile = [NSPredicate predicateWithFormat:@"self MATCHES %@", mobile];
    
    if ([regexMobile evaluateWithObject:tempNumberString]) {
        return YES;
    } else {
        UIAlertView *alertView =  [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的手机号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //将视图上移
    [UIView beginAnimations:nil context:nil];
    if (self.view.frame.origin.y == 0) {
        [UIView setAnimationDuration:0.3];
        CGRect frame = self.view.frame;
        frame.origin.y -= AutoScreenHeight/4;
        self.view.frame = frame;
        
    }
    [UIView commitAnimations];
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignTextFieldFristRes];
    return YES;
}

- (void)resignTextFieldFristRes
{
    if (self.view.frame.origin.y != 0) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
        [UIView commitAnimations];
    }
}
#pragma mark -
#pragma mark 重写父类
- (void)hideKeyBoard
{
    [super hideKeyBoard];
    [self resignTextFieldFristRes];
}

@end
