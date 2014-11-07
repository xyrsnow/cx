//
//  QYPersonInformationViewController.m
//  Hallyu
//
//  Created by qingyun on 14-8-12.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYPersonInformationViewController.h"
#import "TSActionSheet.h"
#import "QYDetailPrivateMessageViewController.h"

#import "QYPersonChooseTableViewCell.h"
#import "QYPersonTableViewCell2.h"
#import "QYMessageCellTableViewCell.h"

#import "QYSettingViewController.h"

#import "QYSettingPersonInformationViewController.h"

#import "MJRefresh.h"

#import "QYpersonView.h"
#import "QYPersonCommon.h"

#import "AFNetworking.h"

#import "QYArticleTableViewController.h"


@interface QYPersonInformationViewController ()<UITableViewDelegate,UITableViewDataSource,QYPersonChooseTableViewCellCellDelegate,QYPersonTableViewCell2CellDelegate, UIAlertViewDelegate>

@property (nonatomic,retain) NSArray *messageArray;

@property (strong, nonatomic) IBOutlet UITableView *personMessage;

@property (nonatomic)BOOL isCollection;

@property (nonatomic,strong) NSDictionary *testData;
@property (nonatomic,strong) NSMutableArray *testDataDic;

@property (nonatomic, strong) QYpersonView *personView;

@property (nonatomic,retain)UIView *OtherUsersTabBar;

@end

@implementation QYPersonInformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"主导航-个人页-press"] withFinishedUnselectedImage:[UIImage imageNamed:@"主导航-个人页"]];
        [self.tabBarItem setImageInsets:UIEdgeInsetsMake(10, 0, -10, 0)];
        self.userID = [QYUserSingleton sharedUserSingleton].user_id;

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self creatPersonInformationHeader];
    
    self.navigationController.navigationBarHidden = NO;
    
    _personMessage.delegate = self;
    _personMessage.dataSource = self;
    
    self.navigationController.tabBarController.tabBar.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
   
//设置title
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];
    
//  根据查看的是否是用户本身，显示不同的界面
    
    if (self.isOtherUser)
    {
        UIButton *menu =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [menu setImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
        [menu setImage:[UIImage imageNamed:@"返回-press.png"] forState:UIControlStateHighlighted];
        [menu addTarget:self action:@selector(returnLastController:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *menuList =[[UIBarButtonItem alloc]initWithCustomView:menu];
        self.navigationItem.leftBarButtonItem = menuList;
        
        
        self.tabBarController.tabBar.hidden = YES;
        
        
        _OtherUsersTabBar = [[UIView alloc]init];
        if  (iPhone5) {
            //4 in
            _OtherUsersTabBar.frame = CGRectMake(0, 519, 320, 49);
        }else{
            //3.5 in
            _OtherUsersTabBar.frame = CGRectMake(0, 431, 320, 49);
        }
        _OtherUsersTabBar.backgroundColor = [UIColor colorWithWhite:0.977 alpha:1.000];
        
        
        UIButton *talkButton = [[UIButton alloc]initWithFrame:CGRectMake(70, 10, 30, 30)];
        [talkButton setImage:[UIImage imageNamed:@"他人-导航-加好友"] forState:UIControlStateNormal];
        [talkButton setImage:[UIImage imageNamed:@"他人-导航-加好友-press"] forState:UIControlStateHighlighted];
        [talkButton addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *sendSiXin = [[UIButton alloc]initWithFrame:CGRectMake(220, 10, 30, 30)];
        [sendSiXin setImage:[UIImage imageNamed:@"他人-导航-私信"] forState:UIControlStateNormal];
        [sendSiXin setImage:[UIImage imageNamed:@"他人-导航-私信-press"] forState:UIControlStateHighlighted];
        [sendSiXin addTarget:self action:@selector(jumpToSend:) forControlEvents:UIControlEventTouchUpInside];
        
        //  设置title
        UILabel *TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        TitleLabel.font = [UIFont boldSystemFontOfSize:20];
        TitleLabel.text = @"个人信息";
        TitleLabel.textColor = [UIColor whiteColor];
        TitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        
        self.navigationItem.titleView = TitleLabel;
        
        [_OtherUsersTabBar addSubview:talkButton];
        [_OtherUsersTabBar addSubview:sendSiXin];
        [self.view addSubview:_OtherUsersTabBar];

    } else {
        
//      修改
        UIButton *changed =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        [changed setTitle:@"修改" forState:UIControlStateNormal];
        [changed setTitle:@"修改" forState:UIControlStateHighlighted];
        [changed setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [changed setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        changed.titleLabel.font =[UIFont boldSystemFontOfSize:18.0f];
        [changed addTarget:self action:@selector(changeUserInformation:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *changedList = [[UIBarButtonItem alloc]initWithCustomView:changed];
        self.navigationItem.leftBarButtonItem = changedList;
        
        //  设置title
        UILabel *TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        TitleLabel.font = [UIFont boldSystemFontOfSize:20];
        TitleLabel.text = @"个人信息";
        TitleLabel.textColor = [UIColor whiteColor];
        TitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        
        self.navigationItem.titleView = TitleLabel;
        
//       菜单
         UIButton *menu =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
         [menu setImage:[UIImage imageNamed:@"设置.png"] forState:UIControlStateNormal];
         [menu setImage:[UIImage imageNamed:@"设置-press.png"] forState:UIControlStateHighlighted];
         [menu addTarget:self action:@selector(showMenuList:) forControlEvents:UIControlEventTouchUpInside];
        
         UIBarButtonItem *menuList =[[UIBarButtonItem alloc]initWithCustomView:menu];
         self.navigationItem.rightBarButtonItem = menuList;
    }
    [self updateDataSource];
}

//定义上拉下拉刷新数据的方法。
- (void)updateDataSource
{
    __block QYPersonInformationViewController *personInformationVC = self;
    
    //上拉加载更多
    [self.personMessage addFooterWithCallback:^{
        [personInformationVC downRefreshMoreData];
    }];
}

- (void)downRefreshMoreData
{
    [self.personMessage performSelector:@selector(footerEndRefreshing) withObject:self.personMessage afterDelay:0.5];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark - 联系Ta 事件 进入私信界面
- (void)jumpToSend:(UIButton *)sender
{
    QYDetailPrivateMessageViewController *detailMessageVC = [[QYDetailPrivateMessageViewController alloc] init];
    
    detailMessageVC.linkmanID = self.userID;
    
    UILabel *TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    TitleLabel.font = [UIFont systemFontOfSize:17];
    TitleLabel.text = _personView.headName.text;
    TitleLabel.textColor = [UIColor whiteColor];
    TitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    detailMessageVC.navigationItem.titleView = TitleLabel;
    
    [self.navigationController pushViewController:detailMessageVC animated:YES];
}

// isOtherUser  添加好友
- (void)addFriend
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"添加该用户为好友" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    } else {
        
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

//修改信息
-(void)changeUserInformation:(UIButton *)sender
{
    QYSettingPersonInformationViewController *settingPersonInformation = [[QYSettingPersonInformationViewController alloc]init];
    settingPersonInformation.userID = self.userID;
    [self.navigationController pushViewController:settingPersonInformation animated:YES];
}

//返回上一个界面
-(void)returnLastController:(UIButton *)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark -
#pragma mark - creatPersonInformationHeader
//设置个人基本信息
-(void)creatPersonInformationHeader
{
    _personView = [[QYpersonView alloc] initWithFrame:CGRectMake(0, 0, 320, 104.5)];
    _personView.userIDNum = self.userID;
    _personView.isOtherUserInfo = self.isOtherUser;
    [_personView downLoadDataSource];
    self.personMessage.tableHeaderView = _personView;
}


-(void)showMenuList:(UIButton *)sender
{
    QYSettingViewController *setting = [[QYSettingViewController alloc]init];
    [self.navigationController pushViewController:setting animated:YES];
}


#pragma mark -
#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 10;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return 44;
    
    }
    return 80;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *section1Indentifier = @"personMseeage0";
    
    static NSString *section1Indentifier2 = @"persinMessage0-2";
    
    static NSString *section3Indentifier = @"personMseeage2";
    
    
    QYPersonChooseTableViewCell *cellType1 =[tableView dequeueReusableCellWithIdentifier:section1Indentifier];
    
    QYPersonTableViewCell2 *cellType1To2 = [tableView dequeueReusableCellWithIdentifier:section1Indentifier2];
    
    QYMessageCellTableViewCell *messageCell = [tableView dequeueReusableCellWithIdentifier:section3Indentifier];
    

    if (indexPath.section == 0) {
        
        if(_isOtherUser)
        {
            cellType1To2 =[[QYPersonTableViewCell2 alloc]
                        initWithStyle:UITableViewCellStyleDefault reuseIdentifier:section1Indentifier];
            cellType1To2.delegate =self;
            cellType1To2.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cellType1To2;
        }else
        {
            
        cellType1 =[[QYPersonChooseTableViewCell alloc]
                   initWithStyle:UITableViewCellStyleDefault reuseIdentifier:section1Indentifier];
        cellType1.delegate =self;
        cellType1.selectionStyle = UITableViewCellSelectionStyleNone;
        
        }
        return cellType1;
        
    } else {
        
        messageCell = [[QYMessageCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:section3Indentifier];
        messageCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return messageCell;
    
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYArticleTableViewController *message =[[QYArticleTableViewController alloc]init];
    NSArray *arr = @[@"1",@"1",@"1",@"1",@"1",];
    [message.collctOfArrForArticle addObjectsFromArray:arr];
    message.indexOfBBS = 0;
    NSDictionary *dic = @{@"author": @"<null>",
            @"content":@"Swqdwd",
            @"date":@"2014-10-13 15:31:37",
            @"id":@"66",
            @"image":@"http://hallyu-hqllyumedia.stor.sinaapp.com/",
            @"titile": @"Test\tBY ZY"};
    NSMutableArray *arrWithData = [[NSMutableArray alloc] init];
    [arrWithData addObject:dic];

    message.arrOfDataForArticle = arrWithData;
    [self.navigationController pushViewController:message animated:YES];
}

//在三个事件由于在section1中添加，数据无法加载，所以定协议，添加事件
-(void)statuesTableViewCell:(QYPersonChooseTableViewCell *)cell reloadPublishMessgae:(UIGestureRecognizer *)gesture
{
    [cell.chooseState replaceObjectAtIndex:0 withObject:@1];
    [_personMessage reloadData];
}

-(void)statuesTableViewCell:(QYPersonChooseTableViewCell *)cell  reloadReplyMessgae:(UIGestureRecognizer *)gesture
{
    [cell.chooseState replaceObjectAtIndex:0 withObject:@2];
    [_personMessage reloadData];
}

-(void)statuesTableViewCell:(QYPersonChooseTableViewCell *)cell reloadCollectMessgae:(UIGestureRecognizer *)gesture
{
    [cell.chooseState replaceObjectAtIndex:0 withObject:@3];
    [_personMessage reloadData];
}

//在两个事件由于在section1中添加，数据无法加载，所以定协议，添加事件
-(void)statuesTableViewCell:(QYPersonTableViewCell2 *)cell reloadOthersPublishMessgae:(UIGestureRecognizer *)gesture
{
    [cell.chooseState replaceObjectAtIndex:0 withObject:@1];
    [_personMessage reloadData];
    
}

-(void)statuesTableViewCell:(QYPersonTableViewCell2 *)cell reloadOthersReplyMessgae:(UIGestureRecognizer *)gesture
{
     [cell.chooseState replaceObjectAtIndex:0 withObject:@2];
     [_personMessage reloadData];
}


@end
