//
//  QYUserArgeementViewController.m
//  Hallyu
//
//  Created by qingyun~sg on 14-9-26.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYUserArgeementViewController.h"

@interface QYUserArgeementViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textview;

@end

@implementation QYUserArgeementViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        titleLable.font = [UIFont boldSystemFontOfSize:17];
        titleLable.text = @"韩流圈用户使用规则";
        titleLable.textColor = [UIColor whiteColor];
        titleLable.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = titleLable;
        self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:241/255.0 green:243/255.0 blue:235/255.0 alpha:1.0];

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
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTextView];
}

- (void)initTextView
{
    self.textview.editable = NO;
    self.textview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_textview];
}

- (void)onBackButtonItem:(UIBarButtonItem*)buttonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
