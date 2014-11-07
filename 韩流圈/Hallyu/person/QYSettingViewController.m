//
//  QYSettingViewController.m
//  Hallyu
//
//  Created by jiwei on 14-8-10.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYSettingViewController.h"
#import "QYFeedBackViewController.h"
#import "QYAboutHallyuViewController.h"
#import "QYUserSingleton.h"
#import "personConstDefine.h"

typedef NS_ENUM(NSUInteger, kTag) {
    kDeleteCacheTag = 1000,
    kMarkTag
};

@interface QYSettingViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong)QYMyDBManager *myDB;
@property (nonatomic, strong) NSArray *settingGroup2Array;
@property (nonatomic, strong) NSArray *settingGroup3Array;

@end

@implementation QYSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.myDB = [QYMyDBManager shareInstance];
        
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        titleLable.font = [UIFont boldSystemFontOfSize:17];
        titleLable.text = @"个人设置";
        titleLable.textColor = [UIColor whiteColor];
        titleLable.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = titleLable;
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemTapped:)];
        [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回-press"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
        
        self.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:241/255.0 green:243/255.0 blue:235/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.settingGroup2Array = @[@"清除缓存", @"反馈意见", @"关于韩流圈"];
    self.settingGroup3Array = @[@"给我们评分",@"退出账户"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.tabBarController.tabBar.hidden = YES;

}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
    self.tabBarController.tabBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retNumberOfRows;
    switch (section) {
            case 0:
                retNumberOfRows = self.settingGroup2Array.count;
                break;
            case 1:
                retNumberOfRows = self.settingGroup3Array.count;
            break;
        default:
            break;
    }
    return retNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentifier = @"cellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    switch (indexPath.section) {
            case 0:
                cell.textLabel.text = self.settingGroup2Array[indexPath.row];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            case 1:
                cell.textLabel.text = self.settingGroup3Array[indexPath.row];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"清除缓存" message:nil delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"确定", nil];
                alertView.tag = kDeleteCacheTag;
                [alertView show];
            }
                break;
            case 1:
            {
                QYFeedBackViewController *feedBackVC = [[QYFeedBackViewController alloc] init];
                [self.navigationController pushViewController:feedBackVC animated:YES];
            }
                break;
            case 2:
            {
                QYAboutHallyuViewController *aboutHallyuVC = [[QYAboutHallyuViewController alloc] initWithNibName:@"QYAboutHallyuViewController" bundle:nil];
                [self.navigationController pushViewController:aboutHallyuVC animated:YES];
            }
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            QYUserSingleton *singleton = [QYUserSingleton sharedUserSingleton];
            singleton.isLogin = NO;
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"给我们评分" message:@"评分" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"确定", nil];
            alertView.tag = kMarkTag;
            [alertView show];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        if (alertView.tag == kDeleteCacheTag) {
            [self deleteCache];
        }else{
#pragma mark -
#pragma mark testURL for login App store
        NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/wei-bo/id350962117?mt=8"];
        [[UIApplication sharedApplication]openURL:url];
    }
    }
}

#pragma mark - backBarButtonItem Event
- (void)leftBarButtonItemTapped:(UIBarButtonItem *)barButtonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark deleteCache
- (void)deleteCache
{
    [self.myDB deleteCacheFromDB];
}

- (void)dealloc
{
    [self.myDB close];
}

@end

