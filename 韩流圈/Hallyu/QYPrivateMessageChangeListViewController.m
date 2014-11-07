//
//  QYPrivateMessageChangeListViewController.m
//  Hallyu
//
//  Created by qingyun on 14-9-21.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYPrivateMessageChangeListViewController.h"
#import "QYPrivateMessageObject.h"
#import "QYPrivateMessageObjectCell.h"
#import "QYDetailPrivateMessageViewController.h"
#import "QYPersonInformationViewController.h"
#import "QYpersonView.h"
#import "QYDateSwith.h"


@interface QYPrivateMessageChangeListViewController () <UITableViewDataSource, UITableViewDelegate>

{
    NSMutableArray *_deleteMessage;   //删除数组
    NSMutableArray *_readMessage;     //已读数组
}

@property (nonatomic, strong) NSMutableArray *lists;

@property (nonatomic, assign) BOOL isDeleteMessage;
@property (nonatomic, assign) BOOL isRemove;

@property (nonatomic, strong) UIView *bgView; // 选择时的背景View
@property (nonatomic, strong) CALayer *layer;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *readBtn;

@property (nonatomic, strong) NSMutableArray *mutableArray;

@property (nonatomic, strong) NSMutableArray *dictArray;//请求下来的部分数据

@end

@implementation QYPrivateMessageChangeListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        UILabel *TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        TitleLabel.font = [UIFont boldSystemFontOfSize:17];
        TitleLabel.text = @"私信箱";
        TitleLabel.textColor = [UIColor whiteColor];
        TitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.navigationItem.titleView = TitleLabel;
        
        _deleteMessage = [NSMutableArray array];
        _readMessage = [NSMutableArray array];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
    self.view.backgroundColor = [UIColor clearColor];   //消除跳转时的黑屏
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//barButtonItem上元素着色
    
    self.tableView.rowHeight = 60;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackButtonItem)];
    [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回-press"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [self downLoadData];
    [self setupRightBar];
 
}

- (void)downLoadData
{
    
    QYUserSingleton *singLeton = [QYUserSingleton sharedUserSingleton];
    self.userID = singLeton.user_id;
    // 获取私信列表
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"user_id":self.userID};
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:PERSON_GET parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"json: %@", responseObject);
        if ([responseObject count] >= 2) {
            if ([[responseObject objectForKey:@"success"] doubleValue]) {
                self.mutableArray = [NSMutableArray arrayWithArray:[responseObject objectForKey:@"data"]];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                
                // 判断图片或语音是否为空， 显示信息内容
//                if (![strImage isKindOfClass:[NSNull class]]) {
//                    dict[@"last_message"] = @"[图片]";
//                } else if (![strSound isKindOfClass:[NSNull class]]) {
//                    dict[@"last_message"] = @"[语音]";
//                } else {
                    dict[@"last_message"] = [self.mutableArray[0] objectForKey:@"last_message"];
//                }
                
                QYDateSwith *date = [[QYDateSwith alloc] initWithDate:[self.mutableArray[0] objectForKey:@"last_date"]];
                
                dict[@"last_date"] = [NSString stringWithFormat:@"%d-%d %d:%d", date.month, date.day, date.hour, date.minute];
                dict[@"linkman_icon_url"] = [self.mutableArray[0] objectForKey:@"linkman_icon_url"];
                dict[@"linkman_nickname"] = [self.mutableArray[0] objectForKey:@"linkman_nickname"];
                dict[@"linkman_id"] = [self.mutableArray[0] objectForKey:@"linkman_id"];
                
                self.dictArray = [NSMutableArray array];
                [self.dictArray addObject:dict];
                _lists = nil;
                [self.tableView reloadData];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (void)setupRightBar
{
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"私信列表-菜单"] style:UIBarButtonItemStylePlain target:self action:@selector(onChioceButtonItem)];
    [rightBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"私信列表-菜单"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [rightBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"私信列表-菜单-press"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - barbutton 事件
- (void)onBackButtonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onChioceButtonItem
{
    if (_bgView != nil) {
        return;
    }
    _bgView = [[UIView alloc] initWithFrame:self.view.frame];
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0.8;
 
    // 新建图层
    _layer = [CALayer layer];
    _layer.backgroundColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000].CGColor;
    _layer.frame = CGRectMake(0, 150, 320, 1);
    
    _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(90, 80, 50, 70)];
    [_deleteBtn setImage:[UIImage imageNamed:@"私信列表-菜单-删除"] forState:UIControlStateNormal];
    [_deleteBtn setImage:[UIImage imageNamed:@"私信列表-菜单-删除-press"] forState:UIControlStateHighlighted];
    [_deleteBtn addTarget:self action:@selector(clickDeleteBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 50, 20)];
    deleteLabel.text = @"删除";
    deleteLabel.textAlignment = NSTextAlignmentCenter;
    deleteLabel.textColor = [UIColor whiteColor];
    deleteLabel.font = [UIFont systemFontOfSize:10];
    [_deleteBtn addSubview:deleteLabel];
    
    _readBtn = [[UIButton alloc] initWithFrame:CGRectMake(190, 80, 50, 70)];
    [_readBtn setImage:[UIImage imageNamed:@"私信列表-菜单-标记已读"] forState:UIControlStateNormal];
    [_readBtn setImage:[UIImage imageNamed:@"私信列表-菜单-标记已读-press"] forState:UIControlStateHighlighted];
    [_readBtn addTarget:self action:@selector(clickReadBtn) forControlEvents:UIControlEventTouchDown];
    
    UILabel *readLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 50, 20)];
    readLabel.text = @"标记为已读";
    readLabel.textAlignment = NSTextAlignmentCenter;
    readLabel.font = [UIFont systemFontOfSize:10];
    readLabel.textColor = [UIColor whiteColor];
    [_readBtn addSubview:readLabel];
    
    [self.view addSubview:_bgView];
    [self.view.layer addSublayer:_layer];
    [self.view addSubview:_deleteBtn];
    [self.view addSubview:_readBtn];
}

//选择删除按钮
- (void)clickDeleteBtn
{
//    navigation的改变
    self.title = @"删除私信";
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"私信列表-菜单-删除"] style:UIBarButtonItemStylePlain target:self action:@selector(removeMessage)];
    [rightBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"私信列表-菜单-删除"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [rightBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"私信列表-菜单-删除-press"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.isDeleteMessage = YES;
    self.lists = nil;
    [self.tableView reloadData];
    [self removeChioceView];
}

// 点击删除
- (void)removeMessage
{
    [_readMessage removeAllObjects];
    self.isRemove = YES;
    
    NSMutableArray *deletePaths = [NSMutableArray array];
    for (QYPrivateMessageObject *obj in _deleteMessage) {
        NSInteger row = [_lists indexOfObject:obj];
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
        [deletePaths addObject:path];
    }
    [_lists removeObjectsInArray:_deleteMessage];
    [self.tableView deleteRowsAtIndexPaths:deletePaths withRowAnimation:UITableViewRowAnimationLeft];
    
    NSMutableArray *deleteArray = [NSMutableArray array];

    [deleteArray addObject:[_mutableArray[0] objectForKey:@"linkman_id"]];
    
    // 删除私信
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"user_id":self.userID,@"linkmans_id":deleteArray};
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:PERSON_DEL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [[responseObject objectForKey:@"errors"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"description: %@",[responseObject objectForKey:@"description"] );
        NSLog(@"json: %@", responseObject);
        NSLog(@"str: %@", str);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [_deleteMessage removeAllObjects];
}

//移除bgView及其他控件
- (void)removeChioceView
{
    [_bgView removeFromSuperview]; _bgView = nil;
    [_readBtn removeFromSuperview];
    [_deleteBtn removeFromSuperview];
    [_layer removeFromSuperlayer];
}

// 选择标记已读按钮
- (void)clickReadBtn
{
    self.title = @"标记已读";
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"私信列表-菜单-标记已读"] style:UIBarButtonItemStylePlain target:self action:@selector(alreadyRead)];
    [rightBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"私信列表-菜单-标记已读"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [rightBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"私信列表-菜单-标记已读-press"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.isDeleteMessage = YES;
    self.lists = nil;
    [self.tableView reloadData];
    [self removeChioceView];
}

//选择了已读 按钮
- (void)alreadyRead
{
    [_deleteMessage removeAllObjects];
    self.isRemove = YES;
    
    NSMutableArray *readPaths = [NSMutableArray array];
    for (QYPrivateMessageObject *obj in _readMessage) {
        NSInteger row = [_lists indexOfObject:obj];
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
        [readPaths addObject:path];
    }

// 将私信标记为已读
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"user_id":self.userID,@"linkmans_id":@[@2,@3,@4]};
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:PERSON_READ_MESSAGE parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [[responseObject objectForKey:@"errors"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"description: %@",[responseObject objectForKey:@"description"] );

        NSLog(@"json: %@", responseObject);
        NSLog(@"str: %@", str);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

    
    [self.tableView reloadData];
}

#pragma mark - 数据的懒加载

- (NSArray *)lists
{
    if (_lists == nil) {
        // 初始化
        
        // 3.将dictArray里面的所有字典转成模型对象,放到新的数组中
        NSMutableArray *tgArray = [NSMutableArray array];
        for (NSDictionary *dict in _dictArray) {
            // 3.1.创建模型对象
            QYPrivateMessageObject *messageObj = [QYPrivateMessageObject listWithDict:dict];
            
            // 3.2.添加模型对象到数组中
            [tgArray addObject:messageObj];
            
            if (self.isDeleteMessage) {
                messageObj.isChoiceDelete = YES;
            }
            //点击删除选择框消失
            if (self.isRemove) {
                messageObj.isChoiceDelete = NO;
            }
        }
        // 4.赋值
        _lists = tgArray;
    }

    self.isRemove = NO;
    return _lists;
}

#pragma mark - tableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYPrivateMessageObjectCell *cell = [QYPrivateMessageObjectCell cellWithTableView:tableView];
    cell.listObject = self.lists[indexPath.row];
    
    int index =  [self indexCellforTableView:tableView IndexPath:indexPath];
    cell.iconButton.tag = index;
    [cell.iconButton addTarget:self action:@selector(onClickIconBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([_deleteMessage containsObject:cell.listObject]) {
        cell.deleteBtn.selected = YES;
    }
    if ([_readMessage containsObject:cell.listObject]) {
        cell.messageLabel.textColor = [UIColor darkGrayColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QYPrivateMessageObject *obj = _lists[indexPath.row];
    if (self.isDeleteMessage) {
        if ([_deleteMessage containsObject:obj]) {
            [_deleteMessage removeObject:obj];
        } else {
            [_deleteMessage addObject:obj];
        }
        
        if ([_readMessage containsObject:obj]) {
            [_readMessage removeObject:obj];
        } else {
            [_readMessage addObject:obj];
        }
    } else {
//        跳转到聊天界面
        QYDetailPrivateMessageViewController *detailVC = [[QYDetailPrivateMessageViewController alloc] init];
        detailVC.title = obj.linkman_nickname;
        //  设置title
        UILabel *TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        TitleLabel.font = [UIFont boldSystemFontOfSize:17];
        TitleLabel.text = obj.linkman_nickname;
        TitleLabel.textColor = [UIColor whiteColor];
        TitleLabel.textAlignment = NSTextAlignmentCenter;
        
        detailVC.userID = self.userID;
        detailVC.linkmanID = [self.dictArray[indexPath.row] objectForKey:@"linkman_id"];
        detailVC.lastDate = [self.dictArray[indexPath.row] objectForKey:@"last_date"];
        
        detailVC.navigationItem.titleView = TitleLabel;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (int)indexCellforTableView:(UITableView *)table IndexPath:(NSIndexPath *)path
{
    int index = 0;
    index += path.row;
    return index;
}

- (void)onClickIconBtn:(UIButton *)sender
{
    
    QYPersonInformationViewController *personInformationVC = [[QYPersonInformationViewController alloc] init];
    personInformationVC.userID = [self.dictArray[sender.tag] objectForKey:@"linkman_id"];
    personInformationVC.isOtherUser = YES;
    
    [self.navigationController pushViewController:personInformationVC animated:YES];
}

@end
