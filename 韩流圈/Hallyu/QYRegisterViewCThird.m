//
//  QYRegisterViewCThird.m
//  Hallyu
//
//  Created by qingyun on 14-9-3.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYRegisterViewCThird.h"
#import "RegexKitLite.h"
#import "QYRootViewController.h"
#import "QYSettingPersonInformationViewController.h"
#import "QYUserArgeementViewController.h"

typedef  NSString* (^phoneBlc)(NSString*);

@interface QYRegisterViewCThird () <UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic,assign) NSInteger agree ;
@property (nonatomic,strong) UITextField *nameField;
@property (nonatomic,copy) phoneBlc phBlc;
@end

@implementation QYRegisterViewCThird

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark viewWillAppear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self creatUICtrl];
}
- (void)creatUICtrl
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];
    self.topLabel.frame = CGRectMake(50, 95, 220, 45);
    _nameField = [[UITextField alloc]initWithFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y - 45 -20, self.textField.frame.size.width, self.textField.frame.size.height)];
    _nameField.borderStyle = UITextBorderStyleNone;
    _nameField.font = [UIFont systemFontOfSize:17.0];
    _nameField.layer.cornerRadius = 2.5;
    _nameField.backgroundColor = [UIColor whiteColor];
    _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameField.placeholder = @"请输入您的昵称";
    _nameField.delegate = self;
    [self.view addSubview:_nameField];
    
    UIButton *proBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    proBtn.frame = CGRectMake(self.makeSureBtn.frame.origin.x, CGRectGetMaxY(self.makeSureBtn.frame)+20, 20,20);
    UIImage *image = [UIImage imageNamed:@"new_feature_share_true"];
    [proBtn setBackgroundImage:image  forState:UIControlStateNormal];
    _agree = 1;
    [proBtn addTarget:self action:@selector(agreeBtn:) forControlEvents:UIControlEventTouchUpInside];
    proBtn.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:proBtn];
    
    UIButton *protocolLab = [UIButton buttonWithType:UIButtonTypeCustom];
    protocolLab.frame = CGRectMake(self.makeSureBtn.frame.origin.x + 10 + proBtn.frame.size.width, CGRectGetMaxY(self.makeSureBtn.frame)+20, self.makeSureBtn.frame.size.width - proBtn.frame.size.width , proBtn.frame.size.height);
    [protocolLab setTitle:@"我已经阅读并同意《韩流圈用户使用协议》" forState:UIControlStateNormal];
    protocolLab.titleLabel.font = [UIFont systemFontOfSize:13];
    [protocolLab setTintColor:[UIColor whiteColor]];
    [protocolLab addTarget:self action:@selector(protocolBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:protocolLab];
}
- (void)protocolBtn:(UIButton *)sender
{
#warning 跳转到协议界面；push
    QYUserArgeementViewController *userAgree = [[QYUserArgeementViewController alloc]init];
    [self.nameField resignFirstResponder];
    [self.textField resignFirstResponder];
    [self.navigationController pushViewController:userAgree animated:YES];
    
}
#pragma mark-
#pragma mark 用户协议按钮
- (void)agreeBtn:(UIButton *)sender
{
    if (1 == _agree) {
        [sender setBackgroundImage:[UIImage imageNamed:@"new_feature_share_false"] forState:UIControlStateNormal];
        _agree = 0;
        self.makeSureBtn.userInteractionEnabled = NO;
        [self.makeSureBtn setTintColor:[UIColor grayColor]];
    }else{
        [sender setBackgroundImage:[UIImage imageNamed:@"new_feature_share_true"] forState:UIControlStateNormal];
         _agree = 1;
        self.makeSureBtn.userInteractionEnabled = YES;
         
    }
}

#pragma mark-
#pragma mark viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.topLabel.text = @"请保护您的账户";
    NSLog(@"%@",NSStringFromCGRect(self.topLabel.frame));
    NSLog(@"%@",NSStringFromCGRect(self.textField.frame));

    self.textField.placeholder = @"请输入账户密码";
    self.textField.delegate = self;
    [self.makeSureBtn setTitle:@"创建账户" forState:UIControlStateNormal];
}

- (void)doMakerSuerAction:(UIButton *)sender
{
    if ([self checkInputText]) {
        
        
#warning test net
        NSString *nameStr = self.nameField.text;
        NSString *str = self.textField.text;
        QYUserSingleton *user = [QYUserSingleton sharedUserSingleton];
        //向服务器提交用户昵称、手机号、密码信息
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSDictionary *parameters = @{@"phone":user.phoneNum , @"passcode":str,@"nickname":nameStr};
         NSString *url = [[NSString alloc]initWithFormat:@"%@/hlq_api/register/",BASE_URL];
        
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
#warning 登录成功后存储返回的user_id
            QYUserSingleton *user = [QYUserSingleton sharedUserSingleton];
            user.user_id = responseObject[@"data"][@"user_id"];
            user.nickName = self.nameField.text;
            user.isLogin = YES;
            
            //将用户信息保存到数据库（注册后也要完成登录效果）
            NSDictionary *userInfor = [[NSDictionary alloc]initWithObjectsAndKeys:user.user_id,@"user_id",user.nickName,@"nickname",@1,@"isLogin", nil];
            QYMyDBManager *myDB = [QYMyDBManager shareInstance];
            [myDB saveUserInfoToDB:@"User_List" withColumns:userInfor];
            //登陆成功后弹出用户指引框
            UIAlertView *reSuc = [[UIAlertView alloc]initWithTitle:@"注册成功" message:@"赶紧完善信息让大家更了解你！" delegate:self cancelButtonTitle:@"以后再说" otherButtonTitles:@"完善信息", nil];
            [reSuc show];
            [self.view addSubview:reSuc];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            UIAlertView *reSuc = [[UIAlertView alloc]initWithTitle:@"注册失败" message:@"哇呜呜～网络不给力～稍后再注册吧"delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [reSuc show];
        }];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//#warning 更改登录状态；
    switch (buttonIndex) {
        case 0:{
            NSLog(@"0");
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 1:{
            NSLog(@"%ld",buttonIndex);
            QYSettingPersonInformationViewController *myInfo = [[QYSettingPersonInformationViewController alloc]init];
//#warning pull后添加bool值
            myInfo.isFromRegister = YES;
            [self.navigationController pushViewController:myInfo animated:YES];
            break;
        }
        default:
            break;
    }
}

//验证输入框中的信息
- (BOOL)checkInputText
{
    NSString *tempKeyString  = self.textField.text;
    
//正则匹配
    NSString *checkText = @"[A-z0-9]{6,12}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self MATCHES %@", checkText];
    if ([predicate evaluateWithObject:tempKeyString]) {
        return YES;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"密码格式有误" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
}
#pragma mark -
#pragma mark textFeildDelegate
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
#pragma mark -
#pragma mark  重写父类方法

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
    [self.nameField resignFirstResponder];
    [self resignTextFieldFristRes];
}


@end
