//
//  QYAppDelegate.h
//  Hallyu
//
//  Created by jiwei on 14-8-9.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYSinaWeiBoDelegate;
@class SinaWeibo;
@protocol WeiboSDKDelegate;

@interface QYAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,WeiboSDKDelegate>
@property (strong,nonatomic) QYSinaWeiBoDelegate *sinaDelegate_;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SinaWeibo *sinaWeibo;
@property (nonatomic, strong) UINavigationController *nav;

@end
