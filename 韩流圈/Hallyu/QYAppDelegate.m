//
//  QYAppDelegate.m
//  Hallyu
//
//  Created by jiwei on 14-8-9.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYAppDelegate.h"
#import "QYSinaWeiBoDelegate.h"
#import "SinaWeibo.h"
#import "QYRootViewController.h"
#import "QYUserGuideViewController.h"
#import "WeiboSDK.h"

@implementation QYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kAppKey];

    
//    //    初始化SDK  对象      
//    self.sinaDelegate_ = [[QYSinaWeiBoDelegate alloc] init];
//    _sinaWeibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI andDelegate:self.sinaDelegate_];
//    
//    NSDictionary *sinaweiboInfo = [NSUD objectForKey:kAuthSinaWeiboAuthData];
//    if ([sinaweiboInfo objectForKey:kAuthAccessTokenKey] &&
//        [sinaweiboInfo objectForKey:kAuthUserIDKey] &&
//        [sinaweiboInfo objectForKey:kAuthExpirationDateKey]) {
//        _sinaWeibo.accessToken = sinaweiboInfo[kAuthAccessTokenKey];
//        _sinaWeibo.userID = sinaweiboInfo[kAuthUserIDKey];
//        _sinaWeibo.expirationDate = sinaweiboInfo[kAuthExpirationDateKey];
//    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    QYRootViewController *mainVC = [[QYRootViewController alloc] init];
    mainVC.delegate = self;
    self.nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    self.nav.navigationBarHidden = YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        QYUserGuideViewController *userGuideVC = [[QYUserGuideViewController alloc] init];
        [self.nav pushViewController:userGuideVC animated:YES];
    }
    
    self.window.rootViewController = self.nav;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
//        ProvideMessageForWeiboViewController *controller = [[[ProvideMessageForWeiboViewController alloc] init] autorelease];
//        [self.viewController presentModalViewController:controller animated:YES];
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {

        //QYUserSingleton *user = [QYUserSingleton sharedUserSingleton];
       // [QYNSDC postNotificationName:kQYNotificationNameLogin object:response.requestUserInfo];
        
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        
        if (0 == [(WBAuthorizeResponse *)response userID]) {
            return;
        }else{
            [QYNSDC postNotificationName:kQYNotificationNameLogin object:[(WBAuthorizeResponse *)response userID]];
            
        }
        
       

    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WeiboSDK handleOpenURL:url delegate:self];

}


-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{

    return [WeiboSDK handleOpenURL:url delegate:self];
}

@end
