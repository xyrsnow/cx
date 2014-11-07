//
//  QYArticleTableViewController.m
//  Hallyu
//
//  Created by qingyun on 14-8-11.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYArticleTableViewController.h"
#import "TSActionSheet.h"
#import "QYAnswerTableViewCell.h"
#import "QYPersonInformationViewController.h"
#import <Social/Social.h>
#import "NSString+FrameHeight.h"
#import "QYLoginViewController.h"
#import "QYRegisterViewCFirst.h"
#import "QYWriteArticleViewController.h"
#import "RTLabel.h"
#import "UIViewExt.h"
#import "AFNetworking.h"
#import "ZYButton.h"
#import "AsyncImageView.h"
#import "QYUserSingleton.h"
#import "FMDB.h"
#import "UIImageView+AFNetworking.h"

@interface QYArticleTableViewController ()<UITextFieldDelegate,UIAlertViewDelegate,UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *answerArray;
@property (nonatomic) BOOL isMoreArticle;
@property (nonatomic) BOOL isLogin;
@property (nonatomic, assign) NSInteger space ;
@property (nonatomic, retain) RTLabel *userName;
@property (nonatomic, strong) UILabel *collectLable;        //点击收藏弹出的视图
@property (nonatomic, retain) UIToolbar *myToolBar;
@property (nonatomic, retain) UIBarButtonItem *collectBtn;
@property (nonatomic, retain) NSMutableArray *imgArray;     // 数据下载的图片
@property (nonatomic, strong) NSMutableArray *diction;
@property (nonatomic, strong) NSArray *muDic;
@property (nonatomic, strong) NSMutableArray *articleDataArray;
@property (nonatomic, strong) NSDictionary *tempDataDIc;
@property (nonatomic, strong) NSMutableArray *arrOfCollect;
@property (nonatomic, strong) NSMutableArray *arrOfBarItems;
@property (nonatomic, strong) NSString *bbs_id_str;
@property (nonatomic, strong) NSString *user_id_Str;
@property (nonatomic, strong) UIScrollView *largeScrollView;
@property (nonatomic, assign) BOOL isCollect;


#define kWidhOfButton 60
#define kSpaceOfButton 20
#define kYOfButton 5
#define kTabBarOfHoigh 49
#define kNavigationBarOfY 66


@end

static BOOL isShare = NO;
int numOfPhoto = 1;
static NSString *cellID = @"cellIdentifiey";


@implementation QYArticleTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.collctOfArrForArticle = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)creatCollectLable
{
    _collectLable = [[UILabel alloc] initWithFrame:CGRectMake(90, 200, 140, 80)];
    _collectLable.layer.cornerRadius = 10.0f;
    _collectLable.clipsToBounds = YES;
    _collectLable.backgroundColor = [UIColor colorWithWhite:0.220 alpha:1.000];
    _collectLable.tag = 1113;
}


- (void)updateData
{
    [self.articleDataArray addObjectsFromArray:self.arrOfDataForArticle];
    self.tempDataDIc = self.articleDataArray[self.indexOfBBS];
    NSLog(@"根据indexBBS来取的数据 %@",self.tempDataDIc);
    self.bbs_id_str = self.tempDataDIc[@"id"];
    self.tableView.tableHeaderView = [self creatHeardView:1];
    self.tableView.tableFooterView = [self creatFooterView];
    [self.tableView reloadData];
    [self creatLeftBarButton];
    [self netWithData];
 
}

- (void)creatRightBarButton
{
    UIButton *rightItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightItemBtn setImage:[UIImage imageNamed:@"内页-菜单键"] forState:UIControlStateNormal];
    [rightItemBtn setImage:[UIImage imageNamed:@"内页-菜单键-press"] forState:UIControlStateHighlighted];
    [rightItemBtn addTarget:self action:@selector(onRightAction:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightItemBtn];
    if (_isLogin) {
        self.navigationItem.rightBarButtonItem = rightItem;
    } else {
        NSLog(@"do noting");
    }
}

- (void)creatLeftBarButton
{
    //帖子作者头像
    UIButton *avaImageBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [avaImageBtn setImage:[UIImage imageNamed:@"taitanxiami.jpg"] forState:UIControlStateNormal];
    avaImageBtn.layer.cornerRadius = 15;
    avaImageBtn.layer.masksToBounds = YES;
    [avaImageBtn addTarget:self action:@selector(onPersonInfoBtn) forControlEvents:UIControlEventTouchUpInside];
    
    // userName
    _userName = [[RTLabel alloc]initWithFrame:CGRectMake(40, 15, 170, 30)];
    [_userName setText:self.tempDataDIc[@"author"]];
    _userName.font = [UIFont systemFontOfSize:15.0f];
    _userName.textAlignment = NSTextAlignmentLeft;
    _userName.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0f];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    [leftView addSubview:avaImageBtn];
    [leftView addSubview:_userName];
    
    //给作者名添加手势
    UITapGestureRecognizer *tapOfAuthor = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPersonInfoBtn)];
    [leftView addGestureRecognizer:tapOfAuthor];
    
    UIBarButtonItem * leftBtn = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItem = leftBtn;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.articleDataArray = [[NSMutableArray alloc] init];
    self.tempDataDIc = [NSDictionary dictionary];
    self.view.backgroundColor = [UIColor whiteColor];
    self.isLogin = YES;
    self.tableView.delegate = self;
    self.tableView.userInteractionEnabled = YES;
    
    [self creatCollectLable];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.isMoreArticle = NO;
    self.space = 20;    //控件距离 视图的边缘  左右都有20
    
    [self creatRightBarButton];
    [self creatLeftBarButton];
    [self updateData];
    
    //个人信息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPersonInfoBtn) name:@"answerTap" object:nil];
    
    //点击空白处，取消textField的第一响应
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFoeldresinFirBecom)];
    [self.tableView addGestureRecognizer:tap];
   
}

-(void)netWithData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"bbs_id": self.bbs_id_str};
    NSLog(@"******self.bbs_id_str-> %@",self.bbs_id_str);
    
    [manager POST:BBS_COMMENT_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"**********帖子评论*******  JSON: %@", [responseObject objectForKey:@"data"]);
        
        self.answerArray = [[NSMutableArray alloc] initWithArray:[responseObject objectForKey:@"data"]];
        for (int i = 0; i < self.answerArray.count; i ++) {
            NSDictionary *dic = self.answerArray[i];
            NSMutableDictionary *mulDic = [dic mutableCopy];
            [mulDic setObject:self.bbs_id_str forKey:@"bbs_id"];
            [self.answerArray replaceObjectAtIndex:i withObject:mulDic];
            NSLog(@"********bbs_id***** %@",self.answerArray[i][@"bbs_id"]);
        }
        
        [self.tableView reloadData];
        
        self.arrOfCollect = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.answerArray.count; i++) {
            [self.arrOfCollect addObject:@NO];
        }
        
        //存入数据库
        self.dbBBS_comment = [QYMyDBManager shareInstance];
        for (NSMutableDictionary *dic in self.answerArray) {
            [self.dbBBS_comment saveMessageAndBBSCommentToDB:kBBSComment withColumns:dic];
        }
        NSLog(@"self.arrOfCollect %@",self.arrOfCollect);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"**********帖子评论******* Error: %@", error);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    //自定义tabBar
    [self creatTabBar];
    [self computieBottomBar];
    
    self.tabBarController.tabBar.frame = CGRectZero;
    
    self.isLogin = [QYUserSingleton sharedUserSingleton].isLogin;
    
    self.isCollect = [self.collctOfArrForArticle[self.indexOfBBS] boolValue];
    
    if (self.isCollect) {
        UIButton *btn = (UIButton*)[self.view viewWithTag:10];
        btn.selected = YES;
    }

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tableView.frame = CGRectMake(0,0,320,(iPhone5 ? 568 : 480 ) - kNavigationBarOfY - kTabBarOfHoigh);
    self.user_id_Str =  [NSString stringWithFormat:@"%@",[QYUserSingleton sharedUserSingleton].user_id];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.toolbarHidden = YES;
    self.tabBarController.tabBar.frame = CGRectMake(0, (iPhone5 ? 568 : 480) - kTabBarOfHoigh , 320, kTabBarOfHoigh);
    [_myToolBar removeFromSuperview];

}



- (void)creatTabBar
{
    _myToolBar = [[UIToolbar alloc] init];
    _myToolBar.frame = CGRectMake(0, (iPhone5 ? 568 : 480) - kNavigationBarOfY - kTabBarOfHoigh - 5, 320, 49 + 5);
    [self.view addSubview:_myToolBar];

}


- (void)computieBottomBar
{
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //返回按钮
    UIImage *backBtnImg = [UIImage imageNamed:@"内页-返回"];
    backBtnImg = [backBtnImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithImage:backBtnImg style:UIBarButtonItemStylePlain target:self action:@selector(backToPrevious)];
 
    //收藏
    UIImage *collectBtnImg ;
    //collectBtnImg = [collectBtnImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIButton *collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    collectBtn.frame = CGRectMake(0, 0, 30, 30);
    [collectBtn addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
    [collectBtn setImage:[UIImage imageNamed:@"内页-收藏"] forState:UIControlStateNormal];
    [collectBtn setImage:[UIImage imageNamed:@"内页-收藏-press"] forState:UIControlStateSelected];
    collectBtn.tag = 10;
    _collectBtn = [[UIBarButtonItem alloc]initWithCustomView:collectBtn];
    
    //快速回复
    UIImage *commentBtnImg = [UIImage imageNamed:@"内页-评论"];
    commentBtnImg = [commentBtnImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *commentBtn = [[UIBarButtonItem alloc]initWithImage:commentBtnImg style:UIBarButtonItemStylePlain target:self action:@selector(commentAction)];
    
    //分享
    UIImage *shareBtnImg = [UIImage imageNamed:@"内页-分享"];
    shareBtnImg = [shareBtnImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *shareBtn = [[UIBarButtonItem alloc]initWithImage:shareBtnImg style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];
    
    NSArray *barArr = @[barBtn,backBtn,barBtn,_collectBtn,barBtn,commentBtn,barBtn,shareBtn,barBtn];
    _arrOfBarItems = [[NSMutableArray alloc] init];
    [self.arrOfBarItems addObject:backBtn];
    [self.arrOfBarItems addObject:_collectBtn];
    [self.arrOfBarItems addObject:commentBtn];
     [_myToolBar setItems:barArr];
}


#pragma mark - action
//返回之前
- (void)backToPrevious
{
    self.QYBBS.arrOfcollect = self.collctOfArrForArticle;
    [self.navigationController popViewControllerAnimated:YES];
}


//收藏事件
- (void)collectAction:(UIButton *)sender
{
    if (!_isLogin)
    {
        [self alterViewLoginOrSininView];
    }else {
        if (self.isCollect == NO) {
            
            //点击收藏时弹出一个界面显示收藏成功。
            _collectLable.text = @"收藏成功";
            _collectLable.backgroundColor = [UIColor colorWithRed:0.043 green:0.706 blue:0.443 alpha:1.000];

            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSDictionary *parameters = @{@"user_id": self.user_id_Str,
                                         @"bbs_id" :self.bbs_id_str,
                                         @"action" :@"1",
                                         @"type"   :@"2"};
            [manager POST:BBS_COLLECT_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"******收藏*****JSON: %@", responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];

            UIImage *img = [UIImage imageNamed:@"内页-收藏-press"];
            img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [_collectBtn setImage:img];
            self.isCollect = YES;
            sender.selected = YES;
            [self.collctOfArrForArticle replaceObjectAtIndex:self.indexOfBBS withObject:@YES];
            
        }else
        {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSDictionary *parameters = @{@"user_id": self.user_id_Str ,
                                         @"bbs_id" :self.bbs_id_str,
                                         @"action" :@"2",
                                         @"type"   :@"2"};
            [manager POST:BBS_COLLECT_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"******收藏***** JSON: %@", responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
            _collectLable.text = @"取消收藏";
            UIImage *img = [UIImage imageNamed:@"内页-收藏"];
            img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [_collectBtn setImage:img];
            self.isCollect = NO;
            sender.selected = NO;
            [self.collctOfArrForArticle replaceObjectAtIndex:self.indexOfBBS withObject:@NO];
            
        }
       
        _collectLable.textColor = [UIColor whiteColor];
        _collectLable.textAlignment = NSTextAlignmentCenter;
        _collectLable.alpha = 0.00001;
        [self.view addSubview:_collectLable];
        
        //为收藏界面的弹出添加动画事件
        [UIView beginAnimations:@"collect" context:nil];
        [UIView setAnimationDuration:2];
        _collectLable.alpha = 0.7;
        [UIView commitAnimations];
        
        //为收藏界面淡入添加动画事件。
        [UIView beginAnimations:@"collectAgain" context:nil];
        [UIView setAnimationDuration:2];
        _collectLable.alpha = 0.00001;
        [UIView commitAnimations];
            
    }
}


//评论
- (void)commentAction
{
    UITextField *textField =(UITextField *)[self.tableView.tableFooterView viewWithTag:3227];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    [textField becomeFirstResponder];
}


//分享事件
- (void)shareAction
{
    UIBarButtonItem *batItem = [[UIBarButtonItem alloc] init];
    if (isShare == NO)
    {
        for (UIBarButtonItem *bar in self.arrOfBarItems) {
            batItem = bar;
            batItem.enabled = NO;
        }

        UIView *bgShareView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height,568 - 2*kTabBarOfHoigh - 20)];
        bgShareView.backgroundColor = [UIColor blackColor];
        bgShareView.tag = 1234;
        bgShareView.alpha = 0.8f;
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x,[UIScreen mainScreen].bounds.size.height - 130 , [UIScreen mainScreen].bounds.size.width,86)];
        view.backgroundColor = [UIColor clearColor];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame =CGRectMake(144, 393, 32, 32);
        btn.backgroundColor = [UIColor clearColor];
        [btn setImage:[UIImage imageNamed:@"内页-分享-微博"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"内页-分享-微博-press"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(onShareIconBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(view.frame)-70, [UIScreen mainScreen].bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.043 green:0.706 blue:0.443 alpha:1.000];
        
        [bgShareView addSubview:btn];
        [bgShareView addSubview:view];
        [bgShareView addSubview:lineView];
        isShare = YES;
        
        [self.view addSubview: bgShareView];
        
    } else {
        for (UIBarButtonItem *bar in self.arrOfBarItems) {
            batItem = bar;
            batItem.enabled = YES;
        }
        UIView *bgShareView = [self.view viewWithTag:1234];
        [bgShareView removeFromSuperview];
        isShare = NO;
    }
    
}


-(void)onRightAction:(UIBarButtonItem*)sender forEvent:(UIEvent*)event
{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"bbs_id": self.bbs_id_str,
                                     @"userid":self.user_id_Str,
                                     @"content":@"sdjfashfkaf"};
        [manager POST:BBS_ADDANSWER_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"*****多选***** JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"*****多选***** Error: %@", error);
        }];
        
        TSActionSheet*tsActionSheet = [[TSActionSheet alloc]initWithTitle:@""];
        tsActionSheet.popoverBaseColor = [UIColor darkGrayColor];
        tsActionSheet.titleFont = [UIFont boldSystemFontOfSize:14.0f];
        CGRect oldFrame = tsActionSheet.frame;
        CGRect newFrame = (CGRect){oldFrame.origin,150,oldFrame.size.height};
        tsActionSheet.frame = newFrame;
        
        [tsActionSheet addButtonWithTitle:@"只看楼主" block:^{
            
        }];
        
        [tsActionSheet addButtonWithTitle:@"倒叙查看" block:^{
            
        }];
        
        [tsActionSheet addButtonWithTitle:@"最赞回复" block:^{
            
        }];
        
        [tsActionSheet addButtonWithTitle:@"举报" block:^{
            
        }];
        
        tsActionSheet.cornerRadius = 1.0f;
        [tsActionSheet showWithTouch:event];
}


- (void)viewMore:(UIButton *)sender
{
    UIScrollView *contentScrollView = (UIScrollView *)sender.superview;
    [contentScrollView setContentOffset:CGPointMake(80, 0) animated:YES];
}


- (void)playAV:(UIButton *)sender
{
    NSLog(@"播放或停止");
}


#pragma mark - heardView callback
-(UIView *)creatHeardView:(NSInteger)imgCount
{
    UIView *heardView = [[UIView alloc] init];
        
        //标题
        RTLabel *postTitle = [[RTLabel alloc]initWithFrame:CGRectMake(10, 20, 300, 0)];
        [postTitle setText:self.tempDataDIc[@"titile"]];
        postTitle.font = [UIFont systemFontOfSize:17.0f];
        postTitle.height = postTitle.optimumSize.height;
        [heardView addSubview:postTitle];
        
        //创建时间
        RTLabel *creat_at = [[RTLabel alloc] initWithFrame:CGRectMake(10, postTitle.bottom+5, 0, 0)];
        [creat_at setText:self.tempDataDIc[@"date"]];
        creat_at.font = [UIFont boldSystemFontOfSize:10.0f];
        creat_at.width = creat_at.optimumSize.width;
        creat_at.height = creat_at.optimumSize.height;
        creat_at.textColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:0.5];
        [heardView addSubview:creat_at];

        //浏览数
        RTLabel *broweLable = [[RTLabel alloc] initWithFrame:CGRectMake(creat_at.right + 10, creat_at.top, 0, 0)];
        [broweLable setText:[@"12" stringByAppendingString:@"浏览"]];
        broweLable.font = [UIFont systemFontOfSize: 10.0f];
        broweLable.textColor =  [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        broweLable.width = broweLable.optimumSize.width;
        broweLable.height = broweLable.optimumSize.height;
        [heardView addSubview:broweLable];
            
        //收藏
        RTLabel *attitudeLable = [[RTLabel alloc] initWithFrame:CGRectMake(broweLable.right + 10, broweLable.top, 0, 0)];
        [attitudeLable setText:[@"10" stringByAppendingString:@"收藏"]];
        attitudeLable.font = [UIFont systemFontOfSize:10.0f];
        attitudeLable.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        attitudeLable.width = attitudeLable.optimumSize.width;
        attitudeLable.height = attitudeLable.optimumSize.height;
        [heardView addSubview:attitudeLable];
        
        //评论
        RTLabel *comments = [[RTLabel alloc] initWithFrame:CGRectMake(attitudeLable.right + 10, broweLable.top, 0, 0)];
        [comments setText:[@"0" stringByAppendingString:@"评论"]];
        comments.font = [UIFont systemFontOfSize:10.0f];
        comments.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        comments.width = comments.optimumSize.width;
        comments.height = comments.optimumSize.height;
        [heardView addSubview:comments];

        //帖子图片
        _postImage =[[UIScrollView alloc] init];
        if ([self.tempDataDIc[@"image"] isEqualToString:@"http://hallyu-hqllyumedia.stor.sinaapp.com/"]) {
            _postImage.frame = CGRectMake(10, comments.bottom+10, 300, 0);
        }else
        {
            _postImage.frame = CGRectMake(10, comments.bottom+10, 300, 200);
        }
        
        _postImage.contentSize = CGSizeMake(_postImage.frame.size.width*_imgArray.count, _postImage.frame.size.height);
        _postImage.pagingEnabled = YES;
        _postImage.showsHorizontalScrollIndicator = YES;
        _postImage.showsVerticalScrollIndicator = YES;
        _postImage.backgroundColor = [UIColor whiteColor];

    
        UIImageView *imgView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _postImage.bounds.size.width, _postImage.bounds.size.height)];
        NSString *url = [NSString stringWithFormat:@"%@",self.tempDataDIc[@"image"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *imageURL = [[NSURL alloc] initWithString:url];
        imgView.imageURL = imageURL;
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [_postImage addSubview:imgView];
    
    
        UITapGestureRecognizer *tapOfPostImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlargeImage:)];
        [_postImage addGestureRecognizer:tapOfPostImage];
        [heardView addSubview:_postImage];

        //录音按钮
        UIButton *avBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        avBtn.frame = CGRectMake(10, _postImage.bottom +10, 100, 20);
        avBtn.backgroundColor = [UIColor brownColor];
        avBtn.imageEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 80);
        avBtn.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 0);
        avBtn.layer.cornerRadius = 9;
        [avBtn setImage:[UIImage imageNamed:@"发表-添加菜单-语音-press"] forState:UIControlStateNormal];
        [avBtn setImage:[UIImage imageNamed:@"发表-添加菜单-语音"] forState:UIControlStateHighlighted];
        [avBtn setTitle:@"3s" forState:UIControlStateNormal];
        [avBtn addTarget:self action:@selector(playAV:) forControlEvents:UIControlEventTouchUpInside];
        [heardView addSubview:avBtn];
    
        //帖子正文
        RTLabel *postText = [[RTLabel alloc]initWithFrame:CGRectMake(10, avBtn.bottom +5, 300, 0)];
        [heardView addSubview:postText];
        [postText setText:self.tempDataDIc[@"content"]];
        postText.font = [UIFont systemFontOfSize:14.0f];
        postText.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        postText.height = postText.optimumSize.height;
        UIView *diviLine1 = [[UIView alloc]initWithFrame:CGRectMake(10, postText.bottom+10, 300, 1)];
        diviLine1.backgroundColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.0f];
        [heardView addSubview:diviLine1];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, diviLine1.bottom, 300, 40)];
        view.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0f];
        [heardView addSubview:view];
        
        UIView *diviLine2 = [[UIView alloc]initWithFrame:CGRectMake(10, view.bottom, 300, 1)];
        diviLine2.backgroundColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.0f];
        [heardView addSubview:diviLine2];
    

        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(35, 6, 30, 30)];
        btn.backgroundColor = [UIColor clearColor];
        [btn setImage:[UIImage imageNamed:@"内页-点赞"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(supportTap:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        
        RTLabel *colLLabel = [[RTLabel alloc]initWithFrame:CGRectMake(73, 13, 0, 0)];
        colLLabel.text = @"已经有";
        colLLabel.font = [UIFont systemFontOfSize:14.0];
        colLLabel.width = colLLabel.optimumSize.width;
        colLLabel.height = colLLabel.optimumSize.height;
        //    colLLabel.top += (collectImg.height - colLLabel.height)/2;
        [view addSubview:colLLabel];
        
        RTLabel *colMidLabel = [[RTLabel alloc]initWithFrame:CGRectMake(colLLabel.right, colLLabel.top, 0, 0)];
        colMidLabel.text = @"178";
        colMidLabel.font = [UIFont systemFontOfSize:14.0];
        colMidLabel.textColor = [UIColor colorWithRed:0.157 green:0.791 blue:0.455 alpha:1.000];
        colMidLabel.width = colMidLabel.optimumSize.width;
        colMidLabel.height = colMidLabel.optimumSize.height;
        colMidLabel.top -= 1;
        [view addSubview:colMidLabel];
        
        RTLabel *colRLabel = [[RTLabel alloc]initWithFrame:CGRectMake(colMidLabel.right, colLLabel.top, 0, colLLabel.height)];
        colRLabel.text = @"人喜欢这篇文章了！";
        colRLabel.font = [UIFont systemFontOfSize:14.0];
        colRLabel.width = colRLabel.optimumSize.width;
        [view addSubview:colRLabel];


        heardView.frame = CGRectMake(0, 0, 320, diviLine2.bottom +10);
        return heardView;

}


#pragma mark - 点击头像  跳转页面到个人信息页面
-(void)onPersonInfoBtn
{
    QYPersonInformationViewController *personCenter = [[QYPersonInformationViewController alloc]init];
    personCenter.isOtherUser = YES;
    if (!_isLogin)
    {
        [self alterViewLoginOrSininView];
    }else if(personCenter.isOtherUser )
    {
        //跳转到他人界面
        [self.tabBarController.navigationController pushViewController:personCenter animated:YES];
    }else
    {
        self.tabBarController.selectedViewController = self.tabBarController.viewControllers[2];
       
        [self.tabBarController.selectedViewController.navigationController pushViewController: self.tabBarController.selectedViewController.navigationController.viewControllers[1] animated:NO];
        self.tabBarController.selectedIndex = 2;
    }
   
}


// 点赞事件
- (void)supportTap:(UIButton *)btn
{
    // 判断点赞
    if (!_isLogin) {
        [self alterViewLoginOrSininView];
    }else
    {
        //初始化数据。
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"message_id": @"39", @"type":@"3"};
        [manager POST:BBS_ZAN_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"*****点赞***** JSON: %@", responseObject);
            NSLog(@"%@",[[responseObject objectForKey:@"errors"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
            NSLog(@"%@",operation.responseString);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"*****点赞***** Error: %@", error);
        }];
        
        [btn setImage:[UIImage imageNamed:@"内页-点赞-press"] forState:UIControlStateNormal];
        btn.userInteractionEnabled = NO;
        
        _collectLable.text = @"赞个";
        _collectLable.textColor = [UIColor whiteColor];
        _collectLable.textAlignment = NSTextAlignmentCenter;
        _collectLable.alpha = 0.00001;
        _collectLable.backgroundColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];
        [self.view addSubview:_collectLable];
        
        //为收藏界面的弹出添加动画事件
        [UIView beginAnimations:@"collect" context:nil];
        [UIView setAnimationDuration:2];
        _collectLable.alpha = 0.7;
        [UIView commitAnimations];
        
        //为收藏界面淡入添加动画事件。
        [UIView beginAnimations:@"collectAgain" context:nil];
        [UIView setAnimationDuration:2];
        _collectLable.alpha = 0.00001;
        [UIView commitAnimations];

    }
}


#pragma mark - creat footerView
-(UIView*)creatFooterView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 110)];
    UIButton *addMore = [[UIButton alloc] initWithFrame:CGRectMake(_space, 10, 280, 30)];
    [addMore setTitle:@"更多回帖" forState:UIControlStateNormal];
    [addMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addMore setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [addMore setBackgroundImage:[UIImage imageNamed:@"lightGray"] forState:UIControlStateNormal];
    [addMore setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateHighlighted];
    [addMore addTarget:self action:@selector(addMoreAriticle:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:addMore];
    
    //编辑回复内容的textField
    UITextField *answerText = [[UITextField alloc]initWithFrame:CGRectMake(_space, CGRectGetMaxY(addMore.frame)+_space, 220, addMore.frame.size.height)];
    answerText.placeholder = @"输入回复";
    answerText.clearsOnBeginEditing = YES;
    answerText.tag = 3227;
    answerText.delegate = self;
    answerText.borderStyle = UITextBorderStyleRoundedRect;
    [view  addSubview:answerText];
    
    //发布按钮
    UIButton *sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(answerText.frame)+10, answerText.frame.origin.y, 50,addMore.frame.size.height)];
    [sendBtn setTitle:@"发布" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(onSendBtn:) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    sendBtn.layer.cornerRadius = 3.0f;
    sendBtn.layer.masksToBounds = YES;
    sendBtn.layer.borderWidth = 0.5f;
    sendBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"lightGray"] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateHighlighted];
    [view addSubview:sendBtn];
    
    return view;
    
}


//添加更多帖子 Button方法的实现
-(void)addMoreAriticle:(UIButton*)button
{
   self.isMoreArticle = self.isMoreArticle != NO ? NO :YES;
    [self.tableView reloadData];
}


//注销键盘的第一响应
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


//必须登录才能编辑
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.isLogin) {
        return YES;
    }else{
        [self alterViewLoginOrSininView];
        return NO;
    }
}


#pragma mark - supportButton and answerButton call back 评论的方法
//正文下面的点赞button 以及 cell上的点赞button 回复
-(void)btnOfChat:(ZYButton *)sender
{
    UITextField *textField = (UITextField*)[self.tableView.tableFooterView viewWithTag:3227];
    [textField becomeFirstResponder];
    textField.text = sender.nameOfFloor;
    NSLog(@"do something to Chat to others");
}


-(void)onSupportBtn:(ZYButton *)button{
    if (!self.isLogin) {
        [self alterViewLoginOrSininView];
    }else
    {
        if ([self.arrOfCollect[button.tag] boolValue]) {
            [self.arrOfCollect replaceObjectAtIndex:button.tag withObject:@NO];
        }else
        {
            [self.arrOfCollect replaceObjectAtIndex:button.tag withObject:@YES];
            //初始化数据。
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSDictionary *parameters = @{@"bbs_id": self.bbs_id_str,
                                         @"type"  :@"1"};
            [manager POST:BBS_ZAN_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"*****喜欢***** JSON: %@", responseObject);
                NSLog(@"%@",[[responseObject objectForKey:@"errors"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
                NSLog(@"%@",operation.responseString);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"*****喜欢***** Error: %@", error);
            }];
        }
        
        NSLog(@"self.arrOfCollect %@",self.arrOfCollect);
        [self.tableView reloadData];
        NSLog(@"do something to Upadate");
    }
}


//正文下面的回复Button  以及cell上的回复button  响应方法
-(void)onAnswerBtn:(UIButton*)button
{
    if (self.isLogin) {
        UITextField *textField = (UITextField*)[self.tableView.tableFooterView viewWithTag:3227];
        [textField becomeFirstResponder];
    }else{
        [self alterViewLoginOrSininView];
    }
}


-(void)onSendBtn:(UIButton*)button
{
    _muDic = [NSArray array];
    
    UITextField *textField = (UITextField*)[self.tableView.tableFooterView viewWithTag:3227];
    NSLog(@"1...textField.text -> %@",textField.text);
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    NSString *regex = @"^\\s+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self MATCHES %@",regex];
    if ([predicate evaluateWithObject:textField.text]) {
        _collectLable.text = @"  请发布有效内容";
        _collectLable.textColor = [UIColor whiteColor];
        _collectLable.textAlignment = kCTTextAlignmentLeft;
        [self.view addSubview:_collectLable];
        
        //提示发布内容
        [UIView beginAnimations:@"collect" context:nil];
        [UIView setAnimationDuration:2];
        _collectLable.alpha = 0.8;
        [UIView commitAnimations];
        
        //为收藏界面淡入添加动画事件
        [UIView beginAnimations:@"collectAgain" context:nil];
        [UIView setAnimationDuration:2];
        _collectLable.alpha = 0.00001;
        [UIView commitAnimations];
    } else if ([textField.text isEqualToString:@""]) {

        _collectLable.text = @"发布内容不能为空";
        _collectLable.textColor = [UIColor whiteColor];
        _collectLable.textAlignment = kCTTextAlignmentNatural;
        [self.view addSubview:_collectLable];
        
        //提示发布内容
        [UIView beginAnimations:@"collect" context:nil];
        [UIView setAnimationDuration:2];
        _collectLable.alpha = 0.8;
        [UIView commitAnimations];
        
        //为收藏界面淡入添加动画事件
        [UIView beginAnimations:@"collectAgain" context:nil];
        [UIView setAnimationDuration:2];
        _collectLable.alpha = 0.00001;
        [UIView commitAnimations];

    }else
    {
        [self.answerArray addObjectsFromArray:_muDic];
        
        //延迟 为了让键盘先收回后进行调整
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            if (self.answerArray.count != 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.answerArray.count- 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }

            //发送回复数据
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSLog(@"textField.text -> %@",textField.text);
            NSDictionary *parameters = @{@"bbs_id": self.bbs_id_str,
                                         @"userid":self.user_id_Str,
                                         @"content":textField.text};
            textField.text = @"";
            [manager POST:BBS_ADDANSWER_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"********跟贴****** JSON: %@", responseObject);
                NSLog(@"%@",[[responseObject objectForKey:@"errors"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
                NSLog(@"%@",operation.responseString);
                if ([[responseObject objectForKey:@"success"] doubleValue]) {
                    NSArray *array = [responseObject objectForKey:@"data"];
                    self.muDic = array;
                    [self.answerArray addObjectsFromArray:_muDic];
                    [self netWithData];
                    textField.text = @"";
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"********跟贴****** Error: %@", error);
            }];
        });

        [textField resignFirstResponder];
//再次将回复拉回来
        [self netWithData];
    }
}


//跟帖
#pragma mark -- 点击图标分享内容触发的事件
- (void)onShareIconBtn:(UIButton *)sender
{
    NSString *twitterStr = @"sdfsf";
    
    //这个链接是跟在发表的微博的后面，当点击这个链接，会直接跳转到这个界面。
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id?mt=8"]];
    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult  result){
        [controller dismissViewControllerAnimated:YES completion:Nil];
    };
    controller.completionHandler =myBlock;
    [controller setInitialText:twitterStr];
    [controller addURL:url];
    
    if (controller) {
        [self presentViewController:controller animated:YES completion:Nil];
    }else{
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"No SinaWeibo account" message:@"There is no SinaWeibo account configured. You can add or create a SinaWeibo account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}


//评论前根据登录状态 弹出登录或者注册的alterView
-(void)alterViewLoginOrSininView
{
    UIAlertView*alterView = [[UIAlertView alloc]initWithTitle:@"登录或者注册" message:@"期待你的看法哦亲" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录",@"注册", nil];
    [alterView show];
}


#pragma mark - AlertViewDelegate  alertView上面的button的响应方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
    QYLoginViewController*controller = [[QYLoginViewController alloc]init];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navCtrl animated:YES completion:nil];
}


-(void)presentToSigninView
{
    QYRegisterViewCFirst *controller = [[QYRegisterViewCFirst alloc]init];
    UINavigationController*nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - TableView dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.answerArray.count;
}


#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYAnswerTableViewCell *cell = [[QYAnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    cell.cellData = self.answerArray[indexPath.row];
    return cell.highOfCell ;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYAnswerTableViewCell *cell;
    cell = [self writing:tableView indexPath:indexPath];

    BOOL isCollect = [self.arrOfCollect[indexPath.row] boolValue];
    if (isCollect) {
        cell.btnOfCollect.selected = YES;
    } else {
        cell.btnOfCollect.selected = NO;
    }
    return cell;
}


#pragma mark -
#pragma mark Cell 种类
- (QYAnswerTableViewCell *)writing:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    QYAnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil){
        cell = [[QYAnswerTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.cellData = self.answerArray[indexPath.row];
    
    [cell.btnOfChat addTarget:self action:@selector(btnOfChat:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnOfCollect addTarget:self action:@selector(onSupportBtn:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnOfCollect.tag = indexPath.row;
    [cell.shenglue addTarget:self action:@selector(viewMore:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


#pragma mark -
#pragma mark 手势
// 手势点击空白处就会把让编辑性质的控件都结束 键盘收回
-(void)textFoeldresinFirBecom
{
     [self.view endEditing:YES];
}


- (void)enlargeImage:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.postImage];
    int numOfImage = point.x/self.postImage.bounds.size.width;
    NSLog(@" numOfImage -> %d", numOfImage);
    self.largeScrollView = [[UIScrollView alloc] initWithFrame:self.postImage.frame];
    self.largeScrollView.contentMode = UIViewContentModeScaleAspectFit;
    self.largeScrollView.contentSize = CGSizeMake(self.view.bounds.size.width * numOfPhoto, self.view.bounds.size.height);
    self.largeScrollView.contentOffset = CGPointMake(numOfImage * self.largeScrollView.bounds.size.width, 0);
    self.largeScrollView.backgroundColor = [UIColor blackColor];
    self.largeScrollView.alpha = 1;
    self.largeScrollView.pagingEnabled = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.largeScrollView.frame = self.view.bounds;
        self.largeScrollView.alpha = 1;
    }];
    
    //添加图片
    UIImageView *imgView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.largeScrollView.bounds.size.width, self.largeScrollView.bounds.size.height)];
    NSString *url = [NSString stringWithFormat:@"%@",self.tempDataDIc[@"image"]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *imageURL = [[NSURL alloc] initWithString:url];
    imgView.imageURL = imageURL;
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.largeScrollView addSubview:imgView];
    
    UITapGestureRecognizer *tapOfLargeScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeLargeScrollView:)];
    [self.largeScrollView addGestureRecognizer:tapOfLargeScrollView];
    [self.view addSubview:self.largeScrollView];
}


- (void)removeLargeScrollView:(UITapGestureRecognizer *)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        self.largeScrollView.frame = self.postImage.frame;
        self.largeScrollView.alpha = 0;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sender.view removeFromSuperview];
    });
}


-(void)dealloc
{
    NSLog(@"释放了");
}

@end
