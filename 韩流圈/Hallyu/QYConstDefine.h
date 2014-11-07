//
//  QYConstDefine.h
//  NewAppStruct
//
//  Created by qingyun on 14-9-23.
//  Copyright (c) 2014年 河南青云信息技术有限公司. All rights reserved.
//

#ifndef NewAppStruct_QYConstDefine_h
#define NewAppStruct_QYConstDefine_h

#define kAppKey @"1494620169"//"863310581"
#define kAppSecret @"3ff69f7236a8a1ee31ac9bcb5c6c5ad4"//"82f88f8130fc9729a5ea32c5940184c4"
#define kAppRedirectURI @"https://api.weibo.com/oauth2/default.html"

#define kAuthSinaWeiboAuthData  @"SinaWeiboAuthData"
#define kAuthAccessTokenKey     @"AcessTokenKey"
#define kAuthUserIDKey          @"UserIDKey"
#define kAuthExpirationDateKey  @"ExpirationDateKey"
#define kAuthRefreshToken       @"refreshToken"


#define NSUD           [NSUserDefaults standardUserDefaults]
#define QYNSDC  [NSNotificationCenter defaultCenter]

#define kQYNotificationNameLogin @"notificationLogin"
#define kQYNotificationNameLogoff @"notificationLogoff"

#define appDelegate ((QYAppDelegate*)[UIApplication sharedApplication].delegate)
#endif
