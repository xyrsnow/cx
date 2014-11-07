//
//  QYFanceViewController.m
//  Hallyu
//
//  Created by jiwei on 14-8-10.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYFansViewController.h"
#import "QYFansAndAttention.h"
#import "personConstDefine.h"
#import "QYFansAndAttentionTableViewCell.h"
#import "QYPersonInformationViewController.h"
#import "unifiedHeaderFile.h"

@interface QYFansViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *fansInfo;
@property (strong, nonatomic) NSMutableArray *array4Data;
@property (strong, nonatomic) NSDictionary *dicFansUserInfo;

@end

@implementation QYFansViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.title = @"粉丝名单";
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackButtonItem:)];
        [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回-press"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self downloadFansList];
}

- (void)downloadFansList
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameter = @{@"user_id":@"2",@"type":@"2"};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:PERSON_FANSANDATTENTION_LIST parameters:parameter success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSLog(@">>>>>>>>>>>>JSON:%@",responseObject);
        if ([[responseObject objectForKey:kSuccess]doubleValue]) {
            NSArray *array = [responseObject objectForKey:kData];
            [self.fansInfo addObjectsFromArray:array];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"error:%@",error);
    }];

}

- (NSMutableArray *)fansInfo
{
    if (_fansInfo == nil) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"fans" ofType:@"plist"];
        
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
        
        NSMutableArray *tgArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            QYFansAndAttention *fansAndAttention = [QYFansAndAttention tgWithDict:dict];
            
            [tgArray addObject:fansAndAttention];
        }
        _fansInfo = tgArray;
        }
    return _fansInfo;

}
#pragma mark - tableView delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QYPersonInformationViewController *personInformationVC = [[QYPersonInformationViewController alloc]init];
    personInformationVC.isOtherUser = YES;
    [self.navigationController pushViewController:personInformationVC animated:YES];
}
#pragma mark - UItableView dateSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fansInfo.count;
}

//初始化cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYFansAndAttentionTableViewCell *cell = [QYFansAndAttentionTableViewCell cellWithTableView:tableView];
    cell.fansAndAttention = self.fansInfo[indexPath.row];
    return cell;
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
