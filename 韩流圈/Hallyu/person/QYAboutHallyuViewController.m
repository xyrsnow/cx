//
//  QYAbooutHallyuViewController.m
//  Hallyu
//
//  Created by qingyun on 14-8-12.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYAboutHallyuViewController.h"
#import "QYLoginViewController.h"
#import "QYUserArgeementViewController.h"

@interface QYAboutHallyuViewController ()

@property (nonatomic, strong) NSArray *aboutSetArray;
@property (nonatomic, strong) NSArray *backArray;

@end

@implementation QYAboutHallyuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"关于韩流圈";
        UILabel *textlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        textlabel.text = @"关于韩流圈";
        textlabel.textAlignment = NSTextAlignmentCenter;
        textlabel.textColor = [UIColor whiteColor];
        textlabel.font = [UIFont systemFontOfSize:17];
        self.navigationItem.titleView = textlabel;
        
        self.tableView.backgroundColor = [UIColor colorWithRed:241/255.0 green:243/255.0 blue:235/255.0 alpha:1.0];
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackButtonItem:)];
        [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回-press"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.aboutSetArray = @[@"版本更新",@"用户使用协议"];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - tableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.aboutSetArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = @"tableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
    }
    if (indexPath.section) {
        cell.textLabel.text = self.backArray[indexPath.row];
    } else {
        cell.textLabel.text = self.aboutSetArray[indexPath.row];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section) {
        QYLoginViewController *loginVC = [[QYLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:NULL];
    } else {
        switch (indexPath.row) {
            case 0:
            {
                //版本更新
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"版本更新" message:@"检测中..." delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
                break;
            case 1:
            {
                //功能介绍界面
                QYUserArgeementViewController *usersAgreementVC = [[QYUserArgeementViewController alloc]init];
                usersAgreementVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:usersAgreementVC animated:YES];
                
            }
                break;
            default:
                break;
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - backButton event
- (void)onBackButtonItem:(UIBarButtonItem *)buttonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
