//
//  QYBBSHomeViewController.m
//  Hallyu
//
//  Created by 泰坦虾米 on 14-8-11.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYBBSHomeViewController.h"
#import "QYLoginViewController.h"
#import "QYRegisterViewCFirst.h"
#import "QYBBSSearchViewController.h"
#import "QYWriteArticleViewController.h"
#import "QYArticleTableViewController.h"
#import "focusView.h"
#import "MJRefresh.h"
#import "QYPersonInformationViewController.h"
#import "QYBBSHomeTableViewCell.h"
#import "RTLabel.h"
#import "UIViewExt.h"
#import "QYPopularTableViewCell.h"
#import "AFNetworking.h"
#import "QYUserSingleton.h"
#import "FMDB.h"
#import "UIImageView+AFNetworking.h"
#import "QYImageManager.h"
#import "AsyncImageView.h"


@interface QYBBSHomeViewController ()<focusViewDelegate>

@property (nonatomic, retain) NSArray *postList;
@property (nonatomic, retain) NSMutableArray *postListData;
@property (nonatomic, retain) NSDictionary *postDic;
@property (nonatomic, retain) UITapGestureRecognizer *tapedAvatar;
@property (nonatomic, retain) UITapGestureRecognizer *tapedUserName;
@property (nonatomic, retain) UITapGestureRecognizer *tapedPostTilte;
@property (nonatomic, retain) NSArray *hotPostList;
@property (nonatomic, assign) BOOL isload;
@property (nonatomic, strong) QYMyDBManager *dbBBS_List;
@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) UILabel *actvityLabel;
@property (nonatomic, strong) UIView *viewAssistant;
@property (nonatomic, strong) QYImageManager *imageManager;

@end


float width = 10.0f;
int numberOfHot = 3;
float highOfFocusImageView = 170.0f;
static int isactivity = 0;

#define kImage @"image"

@implementation QYBBSHomeViewController
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // 在TabBar上显示
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.text = @"韩流圈";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
        UIImage *bbsImage = [UIImage imageNamed:@"主导航-论坛-press"];
        UITabBarItem *bbsItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"主导航-论坛"] selectedImage:[bbsImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        self.tabBarItem = bbsItem;
        [self.tabBarItem setImageInsets:UIEdgeInsetsMake(10, 0, -10, 0)];

    }
    return self;
    
}

- (void)creatBarButton
{
    //导航栏右btn
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"搜索"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(onSearchBar) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem  = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    UIBarButtonItem *witeBBSItem =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(write)];
    witeBBSItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = witeBBSItem;
    self.navigationItem.rightBarButtonItem = rightItem;

}

- (UIView *)creatHeadView
{
    //点赞or取消
    CGRect headViewFrame = CGRectMake(0, 0, 320, highOfFocusImageView);
    UIView *headView = [[UIView alloc]init];
    headView.frame = headViewFrame;
    self.tableView.tableHeaderView = headView;
    return headView;

}

- (void)creatFocusView:(UIView *)headView
{
    //=========焦点图===========
    //接收数据
      NSMutableArray *imageArray  = [NSMutableArray arrayWithCapacity:5];
    for (int i = 1; i < 4; i++) {
        UIImage *focusImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i]];
        [imageArray addObject:focusImage];
    }
    
    focusView *focusImageView = [[focusView alloc]initWithFrame:CGRectMake(0, 0, 320, highOfFocusImageView) withImageArray:imageArray andStepTime:1.5];
    focusImageView.tag = 3000;
    NSArray *focusTitleArr = [NSArray array];
    focusTitleArr = @[@"#0你喜欢长腿欧巴嘛#",@"#1你喜欢长腿欧巴嘛#",@"#2你喜欢长腿欧巴嘛#",@"#3你喜欢长腿欧巴嘛#",@"#4你喜欢长腿欧巴嘛#"];
    focusImageView.focusTitleArr = focusTitleArr;
    focusImageView.delegate = self;

    [headView addSubview:focusImageView];
}

// *******勿删**********
//- (void)test
//{
//    QYMyDBManager *db = [QYMyDBManager shareInstance];
//    NSMutableArray *array = [[NSMutableArray alloc]init];
//    for (NSDictionary *dict in self.postListData) {
//        [array addObject:[db bbsQueryFromDB:kBBSListTable]];
//    }
//    NSLog(@"Test arry ----> ******** %@",array);
//}

- (void)viewDidLoad
{
   
    [super viewDidLoad];
    
    //上拉刷新
    [self updateDataSource];

    [self creatBarButton];
    

    
    self.postListData = [[NSMutableArray alloc] init];
    //初始化数据。
    AFHTTPRequestOperationManager *hotManager = [AFHTTPRequestOperationManager manager];
    NSDictionary *hotParameters = @{@"max_id":@"0",
                                    @"refresh":@"1",
                                    @"refresh_hot":@"1"};
    // 设置请求格式
    hotManager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    hotManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [hotManager POST:BBS_LIST parameters:hotParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@" ******BBSList数据请求******JSON: %@", responseObject);
        NSLog(@"%@",[[responseObject objectForKey:@"errors"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        NSLog(@"%@",operation.responseString);
        
        if ([[responseObject objectForKey:@"success"] doubleValue]) {
            NSArray *array = [responseObject objectForKey:@"data"];

            if ([array isKindOfClass:[NSArray class]]
                && array.count >= 3) {

                [self.postListData addObjectsFromArray:array];
                
     
                //请求下来的数据放在数据库里
               UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
                __block  UIImageView *iamgeViewWeak = imageView;
               for (int i = 0; i < self.postListData.count; i ++) {
                   
                   UIImageView *imgView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100 ,100)];
                   NSString *url = [NSString stringWithFormat:@"%@",self.postListData[i][@"image"]];
                   url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                   NSURL *imageURL = [[NSURL alloc] initWithString:url];
                   imgView.imageURL = imageURL;
                   imgView.contentMode = UIViewContentModeScaleAspectFit;

                   
                   //保存图片
                   __weak UIImageView *iamgeViewWeak = imgView;
                   [imgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                       
                       [iamgeViewWeak setImage:image];
                       QYImageManager *imageManager = [[QYImageManager alloc]init];
                       //[self.imageManager saveImage:image ImageURL:request.URL];
                       [imageManager saveImage:image ImageURL:request.URL];
                       
                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                       NSLog(@"failed:%@",error);
                   }];

               }
             
             
                //删除风火轮
                [self removeActivityIndicatorView];
                isactivity = 1;
                
                NSLog(@"arry :%@",array);
                NSRange range = NSMakeRange(0, 3);
                self.hotPostList = [self.postListData subarrayWithRange:range];
                
                
                NSLog(@"------self.postListData------%@",self.postListData);
                self.arrOfcollect =  [NSMutableArray array];
                NSLog(@"self.postListData.count %d",self.postListData.count);
                for (int i = 0; i < self.postListData.count; i++) {
                    [self.arrOfcollect addObject:@NO];
                }
                
                
                
                
                //存入数据库
                self.dbBBS_List = [QYMyDBManager shareInstance];
                for (NSDictionary *dic in self.postListData) {
                    [self.dbBBS_List saveMessageAndBBSListToDB:kBBSListTable withColumns:dic];
                }
                

                
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [self test];
//                });
               
                
            }else{
                self.postListData = nil;
            }
                [self.tableView reloadData];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"*****BBSList数据请求****** Error: %@", error);
    }];
    UIView *headView;
    headView = [self creatHeadView];
    headView.tag = 1000;
    [self creatFocusView:headView];

 
}


- (void)addActivityIndicatorView
{
    UIView *headView = [self.view viewWithTag:1000];
    
    UIView *viewStoreAct = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width -100)/2, headView.bottom + 50, 100, 60)];
    viewStoreAct.backgroundColor = [UIColor colorWithWhite:0.220 alpha:0.0];
    self.viewAssistant = viewStoreAct;
    UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    act.frame = CGRectMake(35, 30, 30, 30);
    [UIView animateWithDuration:0.35 animations:^{
        self.activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.size.width, self.view.size.height - 100)];
        self.activityView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.activityView];
        viewStoreAct.layer.cornerRadius = 10.0f;
        viewStoreAct.clipsToBounds = YES;
        viewStoreAct.backgroundColor = [UIColor colorWithWhite:0.220 alpha:0.800];
        [self.activityView addSubview:viewStoreAct];
        [act startAnimating];
        self.actvityLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 70, 30)];
        self.actvityLabel.text = @"等我一下...";
        self.actvityLabel.textColor = [UIColor whiteColor];
        self.actvityLabel.adjustsFontSizeToFitWidth = YES;
        self.actvityLabel.textAlignment = NSTextAlignmentCenter;
        [viewStoreAct addSubview:self.actvityLabel];
        [viewStoreAct addSubview:act];

    }];
   
}

- (void)removeActivityIndicatorView
{
    
    [UIView animateWithDuration:0.45 animations:^{
        self.viewAssistant.backgroundColor = [UIColor colorWithWhite:0.220 alpha:0.0];

    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.activityView removeFromSuperview];

    });
}

- (void)updateDataSource
{
    __block QYBBSHomeViewController *BBSHomeVC =self;
    
    //上拉加载更多
    [self.tableView addFooterWithCallback:^{
        [BBSHomeVC upRefreshMoreData];
    }];
    
    //下拉加载更多
    [self.tableView addHeaderWithCallback:^{
        [self addActivityIndicatorView];
        [BBSHomeVC downRefreshMoreData];
    }];
}


//上拉加载更多
-(void)upRefreshMoreData
{

    [self.postListData addObjectsFromArray:_postList];
    
    //添加删除数据的开始和结束，数据的改变应该在其内部。
    //更新数据
    for (int i = 0; i < _postList.count; i++) {
        [self.arrOfcollect addObject:@NO];
    }
    [self.tableView reloadData];
    [self.tableView footerEndRefreshing];
}


//下拉刷新
-(void)downRefreshMoreData
{
    //这里只是一个测试下拉加载的效果。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView headerEndRefreshing];
        //初始化数据。
        AFHTTPRequestOperationManager *hotManager = [AFHTTPRequestOperationManager manager];
        NSDictionary *hotParameters = @{@"max_id":@"0", @"refresh":@"1", @"refresh_hot":@"1"};
        // 设置请求格式
        hotManager.requestSerializer = [AFJSONRequestSerializer serializer];
        // 设置返回格式
        hotManager.responseSerializer = [AFJSONResponseSerializer serializer];
        [hotManager POST:BBS_LIST parameters:hotParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"****下拉刷新**** JSON: %@", responseObject);
            NSLog(@"%@",[[responseObject objectForKey:@"errors"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
            NSLog(@"%@",operation.responseString);
            if ([[responseObject objectForKey:@"success"] doubleValue]) {
                NSArray *array = [responseObject objectForKey:@"data"];
                self.postListData = nil;
                if ([array isKindOfClass:[NSArray class]]
                    && array.count >=3) {
                    
                    self.postListData = nil;
                    self.postListData = [[NSMutableArray alloc] initWithArray:array];
                    self.hotPostList = nil;
                    self.hotPostList = [[NSArray alloc] init];
                    self.hotPostList = [self.postListData subarrayWithRange:NSMakeRange(0, numberOfHot)];
                }else
                {
                    self.postListData = nil;
                    
                }

                [self.tableView reloadData];
                [self removeActivityIndicatorView];
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"****下拉刷新**** Error: %@", error);
            self.actvityLabel.text = @"加载错误";
            
            [self removeActivityIndicatorView];
            
        }];

    });
}


#pragma mark - view 将要出现和消失
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeActivityIndicatorView];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    focusView *focusImageView =(focusView *) [self.view viewWithTag:3000];
    [focusImageView stopTimer];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    focusView *focusImageView =(focusView *) [self.view viewWithTag:3000];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:0.5];
    self.navigationController.navigationBar.translucent = NO;
    [focusImageView startTimer];
    self.isload = [QYUserSingleton sharedUserSingleton].isLogin;
    [self.tableView reloadData];
    if (!isactivity) {
        [self addActivityIndicatorView];
    }
}


#pragma mark - 点击头像
-(void)onAvatar
{
    //判断(登录)
    QYPersonInformationViewController *personCenter = [[QYPersonInformationViewController alloc]init];
    personCenter.isOtherUser = YES;
    [self.tabBarController.selectedViewController.navigationController pushViewController:personCenter animated:YES];
    
   
}


-(void)onPostTilte
{
    QYArticleTableViewController *aritleVC = [[QYArticleTableViewController alloc]init];
    [self.navigationController pushViewController:aritleVC animated:YES];
}


-(void)onUserName
{
    QYPersonInformationViewController *personCenter = [[QYPersonInformationViewController alloc]init];
    personCenter.isOtherUser = YES;
    [self.navigationController pushViewController:personCenter animated:YES];
}

    // 实现方法
- (void)tapFocusSrcollViewAtIndex:(NSInteger)index
{
    QYArticleTableViewController *article  = [[QYArticleTableViewController alloc] init];
    article.collctOfArrForArticle = self.arrOfcollect;
    article.arrOfDataForArticle = self.postListData;

    article.indexOfBBS = index + 1;
    [self.navigationController pushViewController:article animated:YES];
}


#pragma mark - uitableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYArticleTableViewController *aritleVC = [[QYArticleTableViewController alloc] initWithStyle:UITableViewStylePlain];
    aritleVC.indexOfBBS = (int)(indexPath.section * numberOfHot + indexPath.row);
    aritleVC.collctOfArrForArticle = self.arrOfcollect;
    aritleVC.QYBBS = self;
    aritleVC.arrOfDataForArticle = self.postListData;
    [self.navigationController pushViewController:aritleVC animated:YES];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0)
    {
        return 20;
    }
    else
    {
        return 10;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *hotView = nil;
    UILabel *hotTitle = nil;
    
    if (section == 0) {
        
        hotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
        hotView.backgroundColor = [UIColor colorWithRed:234/255.0 green:86/255.0 blue:86/255.0 alpha:1.0f];
        
        hotTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 00, 320, hotView.height)];
        hotTitle.font = [UIFont systemFontOfSize:13.0f];;
        hotTitle.text = @"HOT";
        hotTitle.textColor = [UIColor whiteColor];
        hotTitle.textAlignment =  NSTextAlignmentCenter;
        [hotView addSubview:hotTitle];
        
    }else
    {
        hotView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0f];
        hotTitle = nil;
        
    }
    return hotView;

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if(section == 0)
   {
       return  self.hotPostList.count;
   }else
   {

       return self.postListData.count -3;
   }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    

    
    if (indexPath.section == 0)
    {
        NSString *identify = @"hotPost";
        QYPopularTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (cell  == nil) {
            cell = [[QYPopularTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        
        }
        cell.cellData = self.hotPostList[indexPath.row];
        [cell.favoritesBtn addTarget:self action:@selector(isLoadeding:) forControlEvents:UIControlEventTouchUpInside];
        [cell.avatarImage addTarget:self action:@selector(isLoadeding:) forControlEvents:UIControlEventTouchUpInside];
        cell.favoritesBtn.tag = indexPath.section * numberOfHot + indexPath.row +1;
        cell.isCollect = [self.arrOfcollect[cell.favoritesBtn.tag - 1] boolValue];
        
        // 根据数据判断是否被选中    
        if (cell.isCollect) {
            cell.favoritesBtn.selected = YES;
        }else
        {
            cell.favoritesBtn.selected = NO;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notivicationMethod:) name:@"chilkAvatarImg" object:cell];
        
        return cell;
    }else
    {
        NSString *identify = @"postlist";
        QYBBSHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (cell  == nil) {
            cell = [[QYBBSHomeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        cell.cellData = self.postListData[indexPath.section * numberOfHot + indexPath.row];
        [cell.collect addTarget:self action:@selector(isLoadeding:) forControlEvents:UIControlEventTouchUpInside];
        cell.collect.tag = indexPath.section * numberOfHot + indexPath.row +1;
        cell.isCollect = [self.arrOfcollect[cell.collect.tag -1] boolValue];

        
        // 根据数据判断是否被选中
        if (cell.isCollect) {
            cell.collect.selected = YES;
        }else
        {
            cell.collect.selected = NO;
        }
    
        return cell;

    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0) {
        
        NSDictionary *dic = self.hotPostList[indexPath.row];
        NSString *str = dic[@"posttitle"];
        CGSize  size = [str sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(270, 999) lineBreakMode:NSLineBreakByCharWrapping];
        return 70 + size.height;
       
    }else
    {

        NSDictionary *dic = self.postListData[indexPath.section * numberOfHot + indexPath.row];
        NSString *str = dic[@"titile"];
        CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(270, 100) lineBreakMode:NSLineBreakByCharWrapping];
        return 20 + size.height;
    }
    
}


#pragma mark - action
- (void)write
{
    if (!self.isload) {
        QYWriteArticleViewController *witeArticeView = [[QYWriteArticleViewController alloc]init];
        witeArticeView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:witeArticeView animated:YES];
    }else{
        [self alterViewLoginOrSininView];
        return;
    }
}

#pragma mark - onSerachBar
- (void)onSearchBar
{
     QYBBSSearchViewController *searchBarVC = [[QYBBSSearchViewController alloc]init];
    [self addChildViewController:searchBarVC];
    [self.view addSubview:searchBarVC.view];
    
}



-(void)isLoadeding:(UIButton *)sender
{
    if (!_isload) {
        [self alterViewLoginOrSininView];
        return;
    }else if (sender.tag > 0)
    {
        BOOL isCollect =  [self.arrOfcollect[sender.tag - 1] boolValue];
        if (isCollect) {
            sender.selected = YES;
            [self.arrOfcollect replaceObjectAtIndex:(sender.tag-1) withObject:@NO];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSDictionary *parameters = @{@"user_id": [QYUserSingleton sharedUserSingleton].user_id,
                                         @"bbs_id":@"7",
                                         @"action":@"2",
                                         @"type":@"2"};
            [manager POST:BBS_COLLECT_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"******不收藏***** JSON: %@", responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }else
        {
            sender.selected = NO;
            [self.arrOfcollect replaceObjectAtIndex:(sender.tag-1) withObject:@YES];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSDictionary *parameters = @{@"user_id": [QYUserSingleton sharedUserSingleton].user_id,
                                         @"bbs_id":@"7",
                                         @"action":@"1",
                                         @"type":@"2"};
            [manager POST:BBS_COLLECT_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"******收藏***** JSON: %@", responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];

        }
        
       [self.tableView reloadData];
        //数据上传
       NSLog(@"do something");
       
    }else
    {
         [self onAvatar];
    }
    
}

- (void)notivicationMethod:(NSNotification*)noti
{
    
    NSDictionary *dic = noti.userInfo;
    if (!_isload) {
        [self alterViewLoginOrSininView];
        return;
    }else
    {
        [self onAvatar];
    }
    
}

-(void)alterViewLoginOrSininView{
    UIAlertView*alterView = [[UIAlertView alloc]initWithTitle:@"登录或者注册" message:@"期待你的看法哦亲" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录",@"注册", nil];
    
    [alterView show];
}


#pragma mark - AlertViewDelegate  alertView上面的button的响应方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1:
            
            [self presnetToLoginViewController];
            break;
            
        case 2:
            [self presentToSigninView];
            
            break;
        default:
            break;
    }
}


- (void)presnetToLoginViewController
{
    QYLoginViewController *controller = [[QYLoginViewController alloc]init];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navCtrl animated:YES completion:nil];
}


-(void)presentToSigninView{
    QYRegisterViewCFirst *controller = [[QYRegisterViewCFirst alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -
#pragma mark Test Method


// 如何从通知的发送着找到发送通知的对象，并将它返回用其中的数据
- (void)testOnAvatar:(NSNotificationCenter *)noti
{
   
}


@end
