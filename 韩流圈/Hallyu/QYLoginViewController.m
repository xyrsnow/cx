//
//  QYLoginViewController.m
//  Hallyu
//
//  Created by 宁晓明 on 14-8-9.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYLoginViewController.h"
#import "RegexKitLite.h"
#import "UIViewExt.h"
#import "QYRegisterViewCFirst.h"
#import "QYRootViewController.h"
#import "QYMessageHomeViewController.h"
#import "QYPersonInformationViewController.h"
#import "WeiboSDK.h"
#import "QYMyDBManager.h"

#import "AFNetworking.h"

@interface QYLoginViewController () <UITextFieldDelegate,WBHttpRequestDelegate>

@property (weak, nonatomic) IBOutlet UIView *inputBGV;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *accountNumField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *microblogBtn;
@property (nonatomic,strong) NSString *str;
@property (nonatomic,strong) NSString *passcode;

@end

@implementation QYLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //取消系统对图片颜色的修改
        UIImage *toolImage = [UIImage imageNamed:@"主导航-个人页-press"];
        UITabBarItem *msgItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"主导航-个人页"] selectedImage:[toolImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        //设置tabBar
        self.tabBarItem = msgItem;
        [self.tabBarItem setImageInsets:UIEdgeInsetsMake(10, 0, -10, 0)];
        

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    _inputBGV.layer.cornerRadius = 2.5;
    _loginBtn.layer.cornerRadius = 2.5;
    
    [_microblogBtn addTarget:self action:@selector(otherLoginMode:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    _backBtn.top = 30;

    if (self.tabBarController.selectedIndex == 2) {
        self.backBtn.hidden = YES;
    }
    [QYNSDC addObserver:self selector:@selector(onLoginSuc:) name:kQYNotificationNameLogin object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.tabBarController.selectedIndex == 2) {
        self.backBtn.hidden = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [QYNSDC removeObserver:self name:kQYNotificationNameLogin object:nil];
    self.backBtn.hidden = NO;
    
}
//返回之前的界面
- (IBAction)backToPreviousV:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 第三方登录
- (void)otherLoginMode:(UIButton *)sender
{

    WBAuthorizeRequest *ruquest = [[WBAuthorizeRequest alloc] init];
    ruquest.redirectURI = kAppRedirectURI;
    ruquest.scope = @"all";
    ruquest.userInfo = @{@"sso_from": @"loginViewController"};
    
    [WeiboSDK sendRequest:ruquest];
}


- (void)onLoginSuc:(NSNotification *)notification
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *uid = notification.object;
    
    NSDictionary *parameters = @{@"sina_id":uid};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:WEIBO_LOGIN parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        QYUserSingleton *user = [QYUserSingleton sharedUserSingleton];
        user.isLogin = YES;
        NSString *userID = responseObject[@"data"][@"user_id"];
        user.user_id = userID;
        //保存数据到数据库
        NSDictionary *sinaUserInfor = [[NSDictionary alloc]initWithObjectsAndKeys:@1,@"isSina",user.user_id,@"user_id",@1,@"isLogin", nil];
        QYMyDBManager *myDB = [QYMyDBManager shareInstance];
        [myDB saveUserInfoToDB:@"User_List" withColumns:sinaUserInfor];
        QYPersonInformationViewController *next = [[QYPersonInformationViewController alloc]init];
        [self.navigationController pushViewController:next animated:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *reUser = [[UIAlertView alloc]initWithTitle:@"登录错误" message:@"哇呜呜～登录失败，请稍后再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [reUser show];
        NSLog(@"sina----------%@",error);
    }] ;
    //处理登录成功的逻辑
    
}



#pragma mark -
#pragma mark 键盘
- (void)tapViewAction:(UITapGestureRecognizer *)gesture
{
    [self resignTextFieldFristRes];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resignTextFieldFristRes];
}

- (void)resignTextFieldFristRes
{
    [_accountNumField resignFirstResponder];
    [_passwordField resignFirstResponder];
    if (self.view.top != 0) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.view.top = 0;
        _backBtn.top = 30;
        [UIView commitAnimations];
    }
}
//账号密码开始输入的时候
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //将视图上移
    [UIView beginAnimations:nil context:nil];
    if (self.view.top == 0) {
        [UIView setAnimationDuration:0.3];
        self.view.top -= AutoScreenHeight/4;
        _backBtn.top += AutoScreenHeight/4;
        
    }
    [UIView commitAnimations];
    
    return YES;
}

//输入完毕
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignTextFieldFristRes];
    return YES;
}
#pragma mark -
#pragma mark 登录
//点击登陆按钮
- (IBAction)loginAction:(UIButton *)sender
{
    [self doLoginAction];
}



//验证账号密码并执行登陆事件
- (void)doLoginAction
{
    [self resignTextFieldFristRes];
    

    if ([self checkInputText]) {
        _str = _accountNumField.text;
        _passcode = _passwordField.text;
        
        // *服务器请求
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"phone": _str, @"passcode":_passcode};
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager POST:LOGIN parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            if (responseObject != nil) {
                NSString *reSuccess = [NSString stringWithFormat:@"%@",responseObject[@"success"]];
                if ([reSuccess integerValue] == 1) {
                    
                    NSString *userID = responseObject[@"data"][@"user_id"];
                    QYUserSingleton *user = [QYUserSingleton sharedUserSingleton];
                    user.isLogin = YES;
                    user.user_id = userID;
                    user.phoneNum = _str;
                    user.passcode = _passcode;
                    if (responseObject[@"data"][@"nickname"] != nil) {
                        NSString *userNickName = responseObject[@"data"][@"nickname"];
                         user.nickName = userNickName;
                    }
                    if (responseObject[@"data"][@"icon_url"] != nil) {
                        NSString *userIconUrl = responseObject[@"data"][@"icon_url"];
                        user.icon_url = userIconUrl;
                    }
                    //保存信息到数据库
                    NSDictionary *userInfor = [[NSDictionary alloc]initWithObjectsAndKeys:@1,@"isLogin",user.user_id,@"user_id",user.phoneNum,@"phoneNum",user.passcode,@"passcode",user.nickName,@"nickname",nil];
                    QYMyDBManager *MyDBM = [QYMyDBManager shareInstance];
                    [MyDBM saveUserInfoToDB:@"User_List" withColumns:userInfor];
                    
                    
                    
                    
                    if (self.tabBarController.selectedIndex == 2) {
                        QYPersonInformationViewController *perInfoView = [[QYPersonInformationViewController alloc]init];
                        [self.navigationController pushViewController:perInfoView animated:YES];
                    }else{
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    self.passwordField.text = @"";
                }else{
                    UIAlertView *reUser = [[UIAlertView alloc]initWithTitle:@"登录失败" message:@"用户名或密码错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [reUser show];
                }
            }
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            UIAlertView *reUser =[[UIAlertView alloc]initWithTitle:@"登录失败" message:@"网络不给力" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [reUser show];
        }];
        
        

    }
    
}

#pragma mark -
#pragma mark 输入验证
//验证输入框中的信息
- (BOOL)checkInputText
{
    // 输入的信息
    NSString *tempNumberString = _accountNumField.text;
    NSString *tempKeyString  = _passwordField.text;
    
    //验证手机号码
    NSString *regexNumberString = @"^[1][3-8]+\\d{9}";
    NSArray *matchStringArray = [tempNumberString componentsMatchedByRegex:regexNumberString];
    if (matchStringArray.count != 1 || tempNumberString.length != 11) {
        UIAlertView *alertView =  [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的手机号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    //验证不能有空白输入
    if (tempNumberString.length == 0||tempKeyString.length == 0) {
        [self AlertViewShow:@"不能有空！"];
        return NO;
    }
    if (tempKeyString.length < 8) {
        [self AlertViewShow:@"密码不能小于8位！"];
        return NO;
    }
    //正则验证空格
    NSString *regexEmptyString = @"\\s+";
    //验证输入的信息中不能包含空格
    if ([tempNumberString componentsMatchedByRegex:regexEmptyString].count != 0 ||[tempKeyString componentsMatchedByRegex:regexEmptyString].count != 0 ) {
        [self AlertViewShow:@"信息中不能包含空格！"];
        return NO;
    }
    NSString *regexString = @"[`~!@#$^&*()=|{}':;',\\[\\].<>/?~！@#￥……&*（）——|{}【】‘；：”“'。，、？]";
    if ([tempNumberString componentsMatchedByRegex:regexString].count != 0 ||[tempKeyString componentsMatchedByRegex:regexString].count != 0) {
        [self AlertViewShow:@"信息中不能包含特殊字符！"];
        return NO;
    }
    return YES;
}

- (void)AlertViewShow:(NSString *)title
{
    UIAlertView *alertView =  [[UIAlertView alloc] initWithTitle:@"错误" message:title delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
#pragma mark -
#pragma mark 注册事件
- (IBAction)skipToRegisterView:(UIButton *)sender
{
    QYRegisterViewCFirst *viewC = [[QYRegisterViewCFirst alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -
#pragma mark WeiBo delegate
/**
 收到一个来自微博Http请求的响应
 
 @param response 具体的响应对象
 */

- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    
}

/**
 收到一个来自微博Http请求失败的响应
 
 @param error 错误信息
 */

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    
}

/**
 收到一个来自微博Http请求的网络返回
 
 @param result 请求返回结果
 */

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    
}

/**
 收到一个来自微博Http请求的网络返回
 
 @param data 请求返回结果
 */
- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data
{
    
}



@end