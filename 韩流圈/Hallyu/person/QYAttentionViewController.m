//
//  QYAttentionViewController.m
//  Hallyu
//
//  Created by jiwei on 14-8-10.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYAttentionViewController.h"
#import "QYFansAndAttention.h"
#import "personConstDefine.h"
#import "QYFansAndAttentionTableViewCell.h"
#import "QYPersonInformationViewController.h"

@interface QYAttentionViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger _integer;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *attentionsInfo;

@end

@implementation QYAttentionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.title = @"关注名单";
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackButtonItem:)];
        [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回-press"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
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
//    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self downloadAttention];
}

- (void)downloadAttention
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"user_id": @"2",@"type":@"2"};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[BASE_URL stringByAppendingString:@"/hlq_api/follower/"]parameters:parameters success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSLog(@"%s",__func__);
        NSLog(@"JSON:%@",responseObject);
        NSLog(@"=======%@",operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"error:%@",error);
    }];
}

- (void)deleteAttention
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"user_id":@"1",@"follow_id":@"3",@"action":@"2"};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[BASE_URL stringByAppendingString:@"/hlq_api/add_fans/"] parameters:parameters success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSLog(@"JSON:%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"error:%@",error);
    }];
    
}


- (NSMutableArray *)attentionsInfo
{
    if (_attentionsInfo == nil) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"attentions" ofType:@"plist"];
        
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
        
        NSMutableArray *tgArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            QYFansAndAttention *fansAndAttention = [QYFansAndAttention tgWithDict:dict];
            
            [tgArray addObject:fansAndAttention];
        }
        _attentionsInfo = tgArray;
    }
    return _attentionsInfo;
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
    return self.attentionsInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYFansAndAttentionTableViewCell *cell = [QYFansAndAttentionTableViewCell cellWithTableView:tableView];
    cell.fansAndAttention = self.attentionsInfo[indexPath.row];
    NSInteger index = [self indexCellforTableView:tableView IndexPath:indexPath];
    [cell.userStatusImg addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.userStatusImg.tag = index;
    return cell;
}

- (int)indexCellforTableView:(UITableView *)table IndexPath:(NSIndexPath *)path
{
    int index = 0;
    index += path.row;
    return index;
}

- (void)onBtnClick:(UIButton *)sender
{
    _integer = sender.tag;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"确定要取消关注吗" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        [self deleteAttention];
        NSIndexPath *path = [NSIndexPath indexPathForRow:_integer inSection:0];
        [self.attentionsInfo removeObjectAtIndex:_integer];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
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
