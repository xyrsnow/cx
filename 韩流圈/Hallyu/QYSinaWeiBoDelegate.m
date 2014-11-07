//
//  QYSinaWeiBoDelegate.m
//  NewAppStruct
//
//  Created by qingyun on 14-9-23.
//  Copyright (c) 2014年 河南青云信息技术有限公司. All rights reserved.
//

#import "QYSinaWeiBoDelegate.h"
#import "QYPersonInformationViewController.h"

@implementation QYSinaWeiBoDelegate : NSObject 


- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    [QYNSDC postNotificationName:kQYNotificationNameLogin object:sinaweibo];
    [self storeAuthData:sinaweibo];
#warning message //新浪用户登录
    
    

}


- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}
//将登录成功后，从新浪服务器上获取到的数据持久化到消盒里，以便后续使用客户端来访问服务器上的数据
- (void)storeAuthData:(SinaWeibo*)sinweibo
{
    NSDictionary *authData = @{kAuthAccessTokenKey: sinweibo.accessToken,
                               kAuthUserIDKey:sinweibo.userID,
                               kAuthExpirationDateKey:sinweibo.expirationDate};
    [NSUD setObject:authData forKey:kAuthSinaWeiboAuthData];
    [NSUD synchronize];
    
    
    
}

//删除从新浪服务器上获取到的鉴权数据
- (void)removeAuthData
{
    [NSUD removeObjectForKey:kAuthSinaWeiboAuthData];
    [NSUD synchronize];
}
- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"取消登录");
    [sinaweibo.authorizeView hide];
    
}
@end
