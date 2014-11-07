//
//  QYRegisterViewCSecond.m
//  Hallyu
//
//  Created by qingyun on 14-9-3.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYRegisterViewCSecond.h"
#import "QYRegisterViewCThird.h"
#import "UIViewExt.h"
#import "RegexKitLite.h"
#import "AFNetworking.h"


#define SAVE_NUM_LENGHT 6

@interface QYRegisterViewCSecond () <UITextFieldDelegate>

@end

@implementation QYRegisterViewCSecond

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self creatUICtrl];
    
}

- (void)creatUICtrl
{
    self.topLabel.text = @"收到验证码了吗？";
    self.textField.placeholder = @"请输入您的验证码";
    self.textField.delegate = self;
    [self.makeSureBtn setTitle:@"确认验证码" forState:UIControlStateNormal];
    
    UIButton *getCode = [[UIButton alloc]initWithFrame:CGRectMake(0, AutoScreenHeight - 90, 110, 35)];
    getCode.left = self.view.width - getCode.width - 15;
    [getCode setTitle:@"点击重新发送" forState:UIControlStateNormal];
    [getCode addTarget:self action:@selector(getCodeAgain) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getCode];
}

- (void)getCodeAgain
{

}

- (void)doMakerSuerAction:(UIButton *)sender
{
   // if (1)
   if ([self checkInputText])
   {
#warning TODO 提交三方接口，获得的验证码判断
//         NSString *str = self.textField.text;
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        NSDictionary *parameters = @{@"phone": str, @"passcode":@"111111"};
//        [manager POST:@"http://192.168.1.103:9000/hlq_api/register/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"JSON: %@", responseObject);
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];

        
        QYRegisterViewCThird *viewC = [[QYRegisterViewCThird alloc]init];
        [self.navigationController pushViewController:viewC animated:YES];
    }
}

//验证输入框中的信息
- (BOOL)checkInputText
{
    NSString *tempNumberString = self.textField.text;
    if (tempNumberString.length == SAVE_NUM_LENGHT) {
        NSCharacterSet *chSet = [NSCharacterSet decimalDigitCharacterSet];
        for (NSInteger i = 0; i < tempNumberString.length; i++) {
            if (![chSet characterIsMember:[tempNumberString characterAtIndex:i]]) {
                [self AlertViewShow:@"验证码必须是数字"];
                return NO;
            }
        }
    }
    else {
        [self AlertViewShow:@"验证码长度必须是6位"];
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

- (void)AlertViewShow:(NSString *)title
{
    UIAlertView *alertView =  [[UIAlertView alloc] initWithTitle:@"错误" message:title delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
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
