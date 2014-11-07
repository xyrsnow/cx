//
//  QYRootViewController.m
//  Hallyu
//
//  Created by jiwei on 14-8-12.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYRootViewController.h"

#import "QYBBSHomeViewController.h"
#import "QYMessageHomeViewController.h"
#import "QYLoginViewController.h"
#import "QYPersonInformationViewController.h"

@interface QYRootViewController () <UITabBarControllerDelegate>

@end

@implementation QYRootViewController

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
    
    QYMessageHomeViewController *messageVC = [[QYMessageHomeViewController alloc] init];
    UINavigationController *messageNav = [self createNav:messageVC];
    
    QYBBSHomeViewController *bbsVC = [[QYBBSHomeViewController alloc] init];
    UINavigationController *bbsNav = [self createNav:bbsVC];
    
    QYLoginViewController *homeVC = [[QYLoginViewController alloc] init];
    UINavigationController *homeNav = [self createNav:homeVC];
    
    self.viewControllers = @[messageNav, bbsNav, homeNav];
}



- (UINavigationController *)createNav:(UIViewController *)viewController
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.hidesBottomBarWhenPushed = NO;
    return nav;
}




@end
