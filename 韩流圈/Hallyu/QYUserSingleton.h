//
//  QYUserSingleton.h
//  Hallyu
//
//  Created by XJW on 14-9-29.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//cannot init a class object.

#import <Foundation/Foundation.h>

@interface QYUserSingleton : NSObject


@property (nonatomic, strong)NSString *phoneNum;
@property (nonatomic, strong)NSString *testNum;//验证码
@property (nonatomic, strong)NSString *nickName;//昵称
@property (nonatomic, strong)NSString *account;//用户注册的账号目前只支持手机号
@property (nonatomic, strong)NSString *passcode;//用户密码
@property (nonatomic, strong)NSString *user_id;
@property (nonatomic, strong)NSString *favourites_count;
@property (nonatomic, strong)NSString *follwers_count;
@property (nonatomic) BOOL isLogin;
@property (nonatomic, strong)NSString *icon_url;



+ (QYUserSingleton *)sharedUserSingleton;
@end
