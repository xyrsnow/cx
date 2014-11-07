//
//  QYUserSingleton.m
//  Hallyu
//
//  Created by XJW on 14-9-29.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYUserSingleton.h"

@implementation QYUserSingleton
static QYUserSingleton *userIn;
+ (id) allocWithZone:(struct _NSZone *)zone
{
    
    static QYUserSingleton *userIn;//静态指针，
    static dispatch_once_t once ;
    
    //NSLog(@"%ld",once);
    dispatch_once(&once, ^{
       // userIn = [[QYUserSingleton alloc] init];
        userIn = [super allocWithZone:zone];
    });
    
    return userIn;
}
+ (QYUserSingleton *)sharedUserSingleton
{
    if (!userIn) {
        userIn = [[QYUserSingleton alloc]init];
    }
    return userIn;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initWithAccount:@"" andPhone:@"" andTestNum:@""  andPasscode:@"" andUserId:@"" andNickName:@"" andfavouriyesCount:@"" andFollowersCount:@"" andIsLogin:NO andIcon_url:@"" ];
    }
    return self;
}

- (void)initWithAccount:(NSString *)account
               andPhone:(NSString *)phone
             andTestNum:(NSString *)testNum
            andPasscode:(NSString *)passcode
              andUserId:(NSString *)userId
            andNickName:(NSString *)nickName
     andfavouriyesCount:(NSString *)favCount
      andFollowersCount:(NSString *)followersCount
             andIsLogin:(BOOL)isLogin
            andIcon_url:(NSString *)iconUrl

{
    _phoneNum = [[NSString alloc]initWithString:phone];
    _testNum = [[NSString alloc]initWithString:testNum];
    _account = [[NSString alloc]initWithString:account];
    _passcode = [[NSString alloc]initWithString:passcode];
    _user_id = [[NSString alloc]initWithString:userId];
    _nickName = [[NSString alloc]initWithString:nickName];
    _favourites_count = [[NSString alloc]initWithString:favCount];
    _follwers_count = [[NSString alloc]initWithString:followersCount];
   
    
}

- (id)copy
{
    return self;
}

@end
