//
//  QYMessageViewController.m
//  Hallyu
//
//  Created by jiwei on 14-8-9.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYMessageViewController.h"
#import "unifiedHeaderFile.h"
#import "QYCommentView.h"
#import <Social/Social.h>
#import "MJRefresh.h"
#import "QYCommon.h"
#import "QYLoginViewController.h"
#import "QYRegisterViewCFirst.h"
#import "QYImageManager.h"

@interface QYMessageViewController () <UITableViewDelegate, UITableViewDataSource, commentDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *articleView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (nonatomic, strong) UILabel *collectLable;//点击收藏弹出的视图
@property (nonatomic, strong) UIBarButtonItem *collectBtn;

//数据库和图片存储
@property (nonatomic, strong) QYMyDBManager *myDb;
@property (nonatomic, strong) QYImageManager *imageManage;
@end

static int tapNum;          //点击点赞按钮计数器
static BOOL isLogin = NO;   //登陆标志
static BOOL isCollect = NO; //收藏标志

@implementation QYMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.myDb = [QYMyDBManager shareInstance];
        self.imageManage = [[QYImageManager alloc]init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isLogin = [QYUserSingleton sharedUserSingleton].isLogin;
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    QYCommentView *bottemView = (QYCommentView *)[self.view viewWithTag:2300];
    //如果评论视图存在刷新底部按钮
    if (bottemView) {
        bottemView.delegate = self;
        UIView *commentBgView = [bottemView viewWithTag:COMBGVIEW_TAG];
        UIView *loginBtn = [commentBgView viewWithTag:LOGIN_TAG];
        UIView *registerBtn = [commentBgView viewWithTag:REGISTER_TAG];
        [loginBtn removeFromSuperview];
        [registerBtn removeFromSuperview];
        bottemView.loginState = isLogin;
        
        //重新加载子视图
        [bottemView layoutSubviews];
    }
    
    //重新设置收藏按钮状态
    if (!isLogin && _collectBtn) {
        UIImage *image = [UIImage imageNamed:@"内页-收藏"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_collectBtn setImage:image];
    }else{
        NSArray *array = [self.myDb messageQueryFromDB:kMessageCollect withColumns:@{kUserID:[QYUserSingleton sharedUserSingleton].user_id,
                                                                                     kId:_dataArray[_dataNum][kId]}];
        if (array.count > 0 && [array[0][kIsCollect]integerValue] == 1) {
            UIImage *image = [UIImage imageNamed:@"内页-收藏-press"];
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [_collectBtn setImage:image];
        }else{
            UIImage *image = [UIImage imageNamed:@"内页-收藏"];
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [_collectBtn setImage:image];
        }
    }
}

//设置上拉加载下一篇提示信息
- (void)setDownRefreshInfo
{
    //设置初始上拉提示信息
    NSString *refreshText = nil;
    NSString *refreshText4NullData = @"上拉切换\n已经是最后一篇了";
    
    //判断是否是最后一篇资讯
    if (self.dataNum < self.dataArray.count - 1) {
        refreshText = [NSString stringWithFormat:@"上拉切换\n               下一篇:%@",self.dataArray[_dataNum + 1][kTitle]];
        _articleView.footer.MJRefreshFooterPullToRefresh = refreshText;
        _articleView.footer.MJRefreshFooterReleaseToRefresh = refreshText;
    }else{
        _articleView.footer.MJRefreshFooterPullToRefresh = refreshText4NullData;
        _articleView.footer.MJRefreshFooterReleaseToRefresh = refreshText4NullData;
    }
}

//设置上拉回到上一篇提示信息
- (void)setUpRefreshInfo
{
    if (_dataNum == 0) {
        _articleView.header.MJRefreshHeaderReleaseToRefresh = @"已经是第一篇了";
        _articleView.header.MJRefreshFooterPullToRefresh = @"已经是第一篇了";
    }else{
        _articleView.header.MJRefreshHeaderReleaseToRefresh = @"回到上一篇";
        _articleView.header.MJRefreshFooterPullToRefresh = @"回到上一篇";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.commentData = [NSMutableArray array];
    
    tapNum = 0;
    //定义显示的已收藏lable
    _collectLable = [[UILabel alloc] initWithFrame:CGRectMake(90, 200, 140, 80)];
    _collectLable.layer.cornerRadius = 10.0f;
    _collectLable.clipsToBounds = YES;
    _collectLable.backgroundColor = [UIColor colorWithWhite:0.220 alpha:1.000];
    
    NSDictionary *dic = self.dataArray[self.dataNum];
    _articleInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    self.view.backgroundColor = [UIColor whiteColor];
    _articleView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, AutoScreenHeight) style:UITableViewStylePlain];
    _articleView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //44是toolbar的高度
    _articleView.height -= 44 + _articleView.top;
    _articleView.backgroundColor = [UIColor whiteColor];
    _articleView.delegate = self;
    _articleView.dataSource = self;
    [self.view addSubview:_articleView];
    
    //添加上拉和下拉控件
    [_articleView addHeaderWithTarget:self action:@selector(loadPrevious)];
    [_articleView addFooterWithTarget:self action:@selector(loadNext)];
    
    //设置上拉提示信息
    [self setUpRefreshInfo];
    
    //设置下拉提示信息
    [self setDownRefreshInfo];
    
    //添加上拉提示图标
    UIImageView *upRefreshImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"内页-刷新"]];
    upRefreshImage.frame = CGRectMake(100, 5, 20, 20);
    if (_articleView.footer.refreshing) {
        upRefreshImage.hidden = YES;
    }else{
        upRefreshImage.hidden = NO;
    }
    
    //顶部状态栏位置白色半透明
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
    topView.backgroundColor = [UIColor whiteColor];
    topView.alpha = 0.8;
    [self.view addSubview:topView];
    
    //配置底部toolbar视图
    [self computieBottomBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
}

//下拉加载上一篇
- (void)loadPrevious
{
    tapNum = 0;
    if (self.dataNum > 0) {
        self.dataNum--;
    }
    NSDictionary *dic = self.dataArray[_dataNum];
    _articleInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    [_articleView reloadData];
    
    //加载完数据后，停止刷新
    [_articleView headerEndRefreshing];
    
    [self setUpRefreshInfo];
    [self setDownRefreshInfo];
}

//下拉加载下一篇
- (void)loadNext
{
    tapNum = 0;
    if (self.dataNum != self.dataArray.count - 1) {
        self.dataNum++;
    }
    NSDictionary *dic = self.dataArray[_dataNum];
    _articleInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    [_articleView reloadData];
    
    //加载完数据后，停止刷新
    [_articleView footerEndRefreshing];
    
    [self setDownRefreshInfo];
    [self setUpRefreshInfo];
}

#pragma mark -
#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identify = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (nil == cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //移除所有子视图，防止重用
    for (UIView *rview in [cell.contentView subviews]) {
        [rview removeFromSuperview];
    }
    
    //设置上方盛放图片的scrollView
    self.messageImgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, 320, 114)];
    _messageImgScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 114);
    _messageImgScrollView.delegate = self;
    _messageImgScrollView.pagingEnabled = YES;
    _messageImgScrollView.showsHorizontalScrollIndicator = NO;
    _messageImgScrollView.showsVerticalScrollIndicator = NO;
    _messageImgScrollView.directionalLockEnabled = YES;
    
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(120, 135, 80, 20)];
    _pageControl.numberOfPages = 1;
    [_pageControl addTarget:self action:@selector(chengeCurrentPage:) forControlEvents:UIControlEventValueChanged];
    _pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    
    
    UIImageView *articleImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 114)];
    
    //如果有图片，就加载图片
    if (![[_articleInfo objectForKey:kImage] hasPrefix:@"http://"]) {
        articleImgV.image = [self.imageManage getImage:[_articleInfo objectForKey:kImage]];
    }else{
        NSString *imageName = [[NSURL URLWithString:[_articleInfo objectForKey:kImage]]lastPathComponent];
        articleImgV.image = [self.imageManage getImage:imageName];
    }
    [_messageImgScrollView addSubview:articleImgV];
    [cell.contentView addSubview:_messageImgScrollView];
    [cell.contentView addSubview:_pageControl];
    
    //咨询标题文字
    UILabel *articleTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _pageControl.bottom + 20, 0, 60)];
    articleTitleLabel.width = self.view.width - 20;
    articleTitleLabel.textAlignment = NSTextAlignmentCenter;
    articleTitleLabel.font = [UIFont systemFontOfSize:20];
    articleTitleLabel.numberOfLines = 3;
    articleTitleLabel.text = [_articleInfo objectForKey:kTitle];
    [cell.contentView addSubview:articleTitleLabel];
    
    //咨询信息、日期
    RTLabel *dateLabel = [[RTLabel alloc]initWithFrame:CGRectMake(articleTitleLabel.left, articleTitleLabel.bottom + 10, 0, 10)];
    QYDateSwith *date = [[QYDateSwith alloc]initWithDate:_articleInfo[kDate]];
    dateLabel.text = [NSString stringWithFormat:@"%d.%d",date.month,date.day];
    dateLabel.font = [UIFont systemFontOfSize:8.92];
    dateLabel.textColor = [UIColor colorWithRed:0.157 green:0.791 blue:0.455 alpha:1.000];
    dateLabel.width = dateLabel.optimumSize.width;
    [cell.contentView addSubview:dateLabel];
    
    //所属主题
    NSString *messageText = [NSString stringWithFormat:@"%@   %@",[_articleInfo objectForKey:kAuthor],[_articleInfo objectForKey:kTheme]];
    RTLabel *otherLabel = [[RTLabel alloc]initWithFrame:CGRectMake(dateLabel.right + 10, dateLabel.top, 0, 10)];
    otherLabel.text = messageText;
    otherLabel.font = [UIFont systemFontOfSize:8.92];
    otherLabel.textColor = [UIColor grayColor];
    otherLabel.width = otherLabel.optimumSize.width;
    [cell.contentView addSubview:otherLabel];
    
    //正文
    RTLabel *bodyLabel = [[RTLabel alloc]initWithFrame:CGRectMake(dateLabel.left, dateLabel.bottom + 20, articleTitleLabel.width, 0)];
    bodyLabel.text = [_articleInfo objectForKey:kContent];
    bodyLabel.height = bodyLabel.optimumSize.height;
    [cell.contentView addSubview:bodyLabel];
    CGFloat heightTmp = bodyLabel.bottom;
    NSLog(@"bodyLable :%f",heightTmp);
    
    //有多少人喜欢界面
    UIView *bottomV = [[UIView alloc]initWithFrame:CGRectMake(articleTitleLabel.left, heightTmp + 20, articleTitleLabel.width, 45)];
    bottomV.layer.cornerRadius = 2.5;
    bottomV.layer.borderWidth = 0.5;
    bottomV.layer.borderColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0].CGColor;
    [cell.contentView addSubview:bottomV];
    
    //根据内容的多少重新设置底部刷新内容的位置
    CGRect footNewFram = bottomV.frame;
    footNewFram.origin.y = CGRectGetMaxY(bottomV.frame) + 10;
    _articleView.footer.frame = footNewFram;
    
    //配置多少人喜欢这篇文章前面的点赞按钮
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(52, 12, 20.5, 20.5)];
    if (tapNum) {
        [btn setImage:[UIImage imageNamed:@"内页-点赞-press"] forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"内页-点赞"] forState:UIControlStateNormal];
    }
    [btn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [bottomV addSubview:btn];
    
    //配置已经有多少人喜欢这篇文章了
    RTLabel *colLLabel = [[RTLabel alloc]initWithFrame:CGRectMake(btn.right + 10, btn.top, 0, 0)];
    colLLabel.text = @"已经有";
    colLLabel.font = [UIFont systemFontOfSize:14.0];
    colLLabel.width = colLLabel.optimumSize.width;
    colLLabel.height = colLLabel.optimumSize.height;
    colLLabel.top += (btn.height - colLLabel.height)/2;
    [bottomV addSubview:colLLabel];
    
    //喜欢这篇文章的人数
    RTLabel *colMidLabel = [[RTLabel alloc]initWithFrame:CGRectMake(colLLabel.right, colLLabel.top, 0, 0)];
    colMidLabel.font = [UIFont systemFontOfSize:14.0];
    colMidLabel.textColor = [UIColor colorWithRed:0.157 green:0.791 blue:0.455 alpha:1.000];
    colMidLabel.width = colMidLabel.optimumSize.width;
    colMidLabel.height = colMidLabel.optimumSize.height;
    colMidLabel.top -= 1;
    [bottomV addSubview:colMidLabel];
    
    RTLabel *colRLabel = [[RTLabel alloc]initWithFrame:CGRectMake(colMidLabel.right, colLLabel.top, 0, colLLabel.height)];
    colRLabel.text = @"人喜欢这篇文章了！";
    colRLabel.font = [UIFont systemFontOfSize:14.0];
    colRLabel.width = colRLabel.optimumSize.width;
    [bottomV addSubview:colRLabel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //根据文字的多少计算每个cell的高度
    RTLabel *judgeHeight = [[RTLabel alloc]initWithFrame:CGRectMake(0, 0, _articleView.width - 20, 0)];
    judgeHeight.text = [_articleInfo objectForKey:kContent];
    
    return 20 + 114 + 20 + 20 + 10 + 10 + 20 + judgeHeight.optimumSize.height + 20 + 45 + 60 ;
}


//点赞按钮事件（暂时未实现）
- (void)onButton:(UIButton *)sender
{
    //赞的人数加1
    //    if (!tapNum) {
    //       // NSString *num = _articleInfo[collectNum];
    //        NSInteger collNum = (NSInteger)[num integerValue];
    //        collNum++;
    //        NSString *string = [NSString stringWithFormat:@"%ld",(long)collNum];
    //        [_articleInfo removeObjectForKey:collectNum];
    //        [_articleInfo  setObject:string forKey:collectNum];
    //        [self.articleView reloadData];
    //    }
    //    tapNum++;
}

//点击pageControl切换上面scrollView内的图片
- (void)chengeCurrentPage:(UIPageControl *)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    _messageImgScrollView.contentOffset = CGPointMake(sender.currentPage * [UIScreen mainScreen].bounds.size.width, 0);
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _pageControl.currentPage = scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;
}



#pragma mark -
#pragma mark - 底部按钮
//配置底部按钮
- (void)computieBottomBar
{
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //返回按钮
    UIImage *backBtnImg = [UIImage imageNamed:@"内页-返回"];
    backBtnImg = [backBtnImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithImage:backBtnImg style:UIBarButtonItemStylePlain target:self action:@selector(backToPrevious)];
    
    //收藏
    //判断是否已经收藏
    if (isLogin && isCollect) {
        UIImage *isCollectedImage = [UIImage imageNamed:@"内页-收藏-press"];
        isCollectedImage = [isCollectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _collectBtn = [[UIBarButtonItem alloc]initWithImage:isCollectedImage style:UIBarButtonItemStylePlain target:self action:@selector(collectAction:)];
    }else{
        UIImage *collectBtnImg = [UIImage imageNamed:@"内页-收藏"];
        collectBtnImg = [collectBtnImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _collectBtn = [[UIBarButtonItem alloc]initWithImage:collectBtnImg style:UIBarButtonItemStylePlain target:self action:@selector(collectAction:)];
    }
    
    //评论
    UIImage *commentBtnImg = [UIImage imageNamed:@"内页-评论"];
    commentBtnImg = [commentBtnImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *commentBtn = [[UIBarButtonItem alloc]initWithImage:commentBtnImg style:UIBarButtonItemStylePlain target:self action:@selector(commentAction)];
    
    //多少条评论
    //由于显示资讯评论条数需要评论数据，所以在这里请求评论数据
    //数据库请求数据
    NSArray *array = [self.myDb messageQueryFromDB:kMessageComment withColumns:@{kId: self.dataArray[_dataNum][kId]}];
    UIView *commentNumView = [[UIView alloc]initWithFrame:CGRectMake(201, 3, 15, 15)];
    commentNumView.backgroundColor = [UIColor redColor];
    commentNumView.layer.cornerRadius = 8;
    UILabel *numLable = [[UILabel alloc]initWithFrame:CGRectMake(5, 2, 10, 10)];
    numLable.backgroundColor = [UIColor clearColor];
    numLable.text = [NSString stringWithFormat:@"%d",array.count];
    numLable.font = [UIFont boldSystemFontOfSize:9];
    numLable.adjustsFontSizeToFitWidth = YES;
    numLable.textColor = [UIColor whiteColor];
    [commentNumView addSubview:numLable];
    [_bottomBar addSubview:commentNumView];
    if (array.count) {
        commentNumView.hidden = NO;
    }else{
        commentNumView.hidden = YES;
    }
    
    //从网络更新数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *messageId = self.dataArray[_dataNum][kId];
    NSLog(@"%d",[messageId intValue]);
    NSDictionary *parameters = nil;
    if (messageId) {
        parameters = @{@"messageid":messageId};
    }
    [manager POST:NEWS_COMMENTS parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([[responseObject objectForKey:kSuccess] doubleValue]) {
            NSArray *dataArr = [responseObject objectForKey:kData];
            [_commentData removeAllObjects];
            [_commentData addObjectsFromArray:dataArr];
            numLable.text = [NSString stringWithFormat:@"%d",_commentData.count];
            if (_commentData.count) {
                commentNumView.hidden = NO;
            }else{
                commentNumView.hidden = YES;
            }
            
            //保存数据到数据库
            for (int p = 0; p < dataArr.count; p++) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dataArr[p]];
                [dic setObject:messageId forKey:@"message_id"];
                if ( array.count != 0 && array != nil && [dic[kFloorNum] intValue] > [array[0][kFloorNum] intValue]) {
                    [self.myDb saveMessageAndBBSCommentToDB:kMessageComment withColumns:dic];
                }else if(array.count == 0){
                    [self.myDb saveMessageAndBBSCommentToDB:kMessageComment withColumns:dic];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
    //分享
    UIImage *shareBtnImg = [UIImage imageNamed:@"内页-分享"];
    shareBtnImg = [shareBtnImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *shareBtn = [[UIBarButtonItem alloc]initWithImage:shareBtnImg style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];
    
    NSArray *barArr = @[barBtn,backBtn,barBtn,_collectBtn,barBtn,commentBtn,barBtn,shareBtn,barBtn];
    _bottomBar.items = barArr;
}

//返回事件
- (void)backToPrevious
{
    [self.navigationController popViewControllerAnimated:YES];
}

//收藏事件
- (void)collectAction:(UIBarButtonItem *)sender
{
    //如果分享菜单存在，先取消分享
    UIView *shareView = [self.view viewWithTag:1234];
    if (shareView) {
        [shareView removeFromSuperview];
    }
    
    //判断是否登录
    if (isLogin) {
        NSString *collectAction = nil;
        if (isCollect == NO) {
            //点击收藏时弹出一个界面显示收藏成功。
            _collectLable.text = @"收藏成功";
            
            //收藏图标设置
            UIImage *isColletedImage = [UIImage imageNamed:@"内页-收藏-press"];
            isColletedImage = [isColletedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            sender.image = isColletedImage;
            collectAction = @"0";
            isCollect = YES;
        }else{
            _collectLable.text = @"取消收藏";
            UIBarButtonItem *barButtonItem = (UIBarButtonItem *)_bottomBar.items[3];
            UIImage *image = [UIImage imageNamed:@"内页-收藏"];
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [barButtonItem setImage:image];
            isCollect = NO;
            collectAction = @"1";
        }
        
        //网络数据上传
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"userid": [QYUserSingleton sharedUserSingleton].user_id,@"message_id":self.dataArray[_dataNum][kId],@"action":collectAction,@"type":@"1"};
        [manager POST:NEWS_COLLECT parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([[responseObject objectForKey:kSuccess]doubleValue]) {
                //存储数据到数据库
                NSDictionary *dic = @{@"user_id": [QYUserSingleton sharedUserSingleton].user_id,
                                      @"message_id":_dataArray[_dataNum][kId],
                                      @"iscollect":[NSString stringWithFormat:@"%d",isCollect]
                                      };
                //数据库数据存储
                [self.myDb saveMessageAndBBSCollectToDB:kMessageCollect withColumns:dic];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
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
    }else{
        [self loginOrRegisterWith:!isLogin];
    }
}


//评论事件
- (void)commentAction
{
    //如果分享菜单存在，先取消分享
    UIView *shareView = [self.view viewWithTag:1234];
    if (shareView) {
        [shareView removeFromSuperview];
    }
    
    //获取评论
    QYCommentView *bgView = [[QYCommentView alloc]initWithFrame:CGRectMake(0, 20, self.view.width, AutoScreenHeight - 20) andComInfoArr:_commentData];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.tag = 2300;
    bgView.loginState = isLogin;
    bgView.delegate = self;
    [self.view addSubview:bgView];
    
    //数据库取数据
    NSArray *array = [self.myDb messageQueryFromDB:kMessageComment withColumns:@{kId: self.dataArray[_dataNum][kId]}];
    [bgView.comInfo removeAllObjects];
    [bgView.comInfo addObjectsFromArray:array];
    [bgView.comTableView reloadData];
}


//分享事件
- (void)shareAction
{
    //判断是否登录
    if (!isLogin) {
        [self loginOrRegisterWith:!isLogin];
    }else{
        UIView *shareView = [self.view viewWithTag:1234];
        if (shareView) {
            //再次点击分享按钮取消分享
            [shareView removeFromSuperview];
            
        }else{
            UIView *bgShareView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.height-44)];
            bgShareView.backgroundColor = [UIColor blackColor];
            bgShareView.tag = 1234;
            bgShareView.alpha = 0.8f;
            
            //给背景视图添加手势，点击屏幕任何位置取消分享
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapGesture:)];
            [bgShareView addGestureRecognizer:tapGesture];
            
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x,[UIScreen mainScreen].bounds.size.height - 130 , [UIScreen mainScreen].bounds.size.width,86)];
            view.backgroundColor = [UIColor clearColor];
            
            //定义并设置分享按钮
            NSArray *imageName = @[@"内页-分享-微信",@"内页-分享-朋友圈",@"内页-分享-微博",@"内页-分享-QQ",@"内页-分享-复制",@"内页-分享-微信-press",@"内页-分享-朋友圈-press",@"内页-分享-微博-press",@"内页-分享-QQ-press",@"内页-分享-复制-press"];
            for (int i = 0; i < 5; i++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(25 + i * 60, 20, 32, 32);
                [btn setImage:[UIImage imageNamed:imageName[i]] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:imageName[i + 5]] forState:UIControlStateHighlighted];
                btn.backgroundColor = [UIColor clearColor];
                btn.tag = 100 + i;
                [btn addTarget:self action:@selector(onShareIconBtn:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
            }
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 300, 20)];
            nameLabel.text = @"微信好友   朋友圈     微博         QQ        复制";
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.font = [UIFont systemFontOfSize:14.0f];
            [view addSubview:nameLabel];
            
            
            //设置分享按钮上方的分割线
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(view.frame), [UIScreen mainScreen].bounds.size.width, 1)];
            lineView.backgroundColor = [UIColor colorWithRed:0.043 green:0.706 blue:0.443 alpha:1.000];
            
            UILabel *shareLable = [[UILabel alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(lineView.frame) - 30, 100, 20)];
            shareLable.text = @"分享内容至:";
            shareLable.textColor = [UIColor whiteColor];
            [bgShareView addSubview:view];
            [bgShareView addSubview:shareLable];
            [bgShareView addSubview:lineView];
            [self.view addSubview: bgShareView];
        }
    }
}

//手势方法的实现
- (void)onTapGesture:(UITapGestureRecognizer *)gesture
{
    UIView *backgroundView = [self.view viewWithTag:1234];
    [backgroundView removeFromSuperview];
}

#pragma mark -- 点击图标分享内容触发的事件
- (void)onShareIconBtn:(UIButton *)sender
{
    /**
     需要的框架是：Social.framework;需要的头文件Social.h
     *  这段代码是处理分享到不同的平台，决定是哪个平台的参数是：SLServiceTypeSinaWeibo。
     其中包括有：SOCIAL_EXTERN NSString *const SLServiceTypeTwitter NS_AVAILABLE(10_8, 6_0);(Twitter)     SOCIAL_EXTERN NSString *const SLServiceTypeFacebook NS_AVAILABLE(10_8, 6_0);（FACEBOOK）
     SOCIAL_EXTERN NSString *const SLServiceTypeSinaWeibo NS_AVAILABLE(10_8, 6_0);
     （新浪微博）
     SOCIAL_EXTERN NSString *const SLServiceTypeTencentWeibo NS_AVAILABLE(10_9, 7_0);（腾讯微博）
     SOCIAL_EXTERN NSString *const SLServiceTypeLinkedIn NS_AVAILABLE(10_9, NA);（LinkedIn）
     */
    
    NSString *twitterStr = @"sdfsf";
    
    //这个链接是跟在发表的微博的后面，当点击这个链接，会直接跳转到这个界面。
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id?mt=8"]];
    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult  result){
        [controller dismissViewControllerAnimated:YES completion:Nil];
    };
    controller.completionHandler = myBlock;
    [controller setInitialText:twitterStr];
    [controller addURL:url];
    if (controller) {
        [self presentViewController:controller animated:YES completion:Nil];
    }else{
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"No SinaWeibo account" message:@"There is no SinaWeibo account configured. You can add or create a SinaWeibo account in Settings."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles: nil];
        
        [alert show];
    }
}


//发表和回复评论方法实现
- (void)publishContens:(UIButton *)sender
{
    NSString *commentContents = nil;
    NSDictionary *parameters = nil;
    NSString *commentContent = nil;
    NSString *messageId = [NSString stringWithFormat:@"%@",self.dataArray[_dataNum][kId]];
    
    //如果输入内容为空或者全部是空格，什么也不做，否则发表(回复)评论
    NSString *condotion = @"|[ ]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self matches %@",condotion];
    
    //添加本次评论(回复)内容
    QYCommentView *bottemView = (QYCommentView *)[self.view viewWithTag:2300];
    if ([sender.titleLabel.text isEqualToString:@"发表"]) {
        commentContents = bottemView.commentField.text;
        if ([predicate evaluateWithObject:commentContents]) return;
        commentContent = commentContents;
    }else{
        commentContents = [NSString stringWithFormat:@"德玛西亚%@",bottemView.commentField.text];
        NSString *answerTxt = bottemView.commentField.text;
        NSRange subRange = [answerTxt rangeOfString:@":"];
        NSString *answerString = [answerTxt substringFromIndex:subRange.location + 1];
        
        //判定输入是否合法
        if ([predicate evaluateWithObject:answerString]) return;
        commentContent = answerString;
        UIView *view = [bottemView viewWithTag:COMBGVIEW_TAG];
        UIButton *backBtn = (UIButton *)[view viewWithTag:PUBLISHBTNTAG];
        [backBtn setTitle:@"发表" forState:UIControlStateNormal];
        [backBtn setTitle:@"发表" forState:UIControlStateHighlighted];
    }
    
    //向服务器提交数据
    parameters = @{@"userid":[QYUserSingleton sharedUserSingleton].user_id, @"messageid":messageId, @"message":commentContent};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:NEWS_ADDCOMMENTS parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"comment  JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    //添加评论内容到界面上
    //记录当前评论数
    NSInteger currentCommentCount = bottemView.comInfo.count;
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *resultDate = [dateFormater stringFromDate:date];
    [bottemView.comInfo addObject:@{kAttitude_count:@"0",
                                    kAvatarImg:[NSString stringWithFormat:@"%@",[QYUserSingleton sharedUserSingleton].icon_url],
                                    kContentText:commentContent,
                                    kDate:resultDate,
                                    kFloorNum:[NSString stringWithFormat:@"%d",bottemView.comInfo.count + 1],
                                    kUserId:[NSString stringWithFormat:@"%@",[QYUserSingleton sharedUserSingleton].user_id],
                                    kUserName:[NSString stringWithFormat:@"%@",[QYUserSingleton sharedUserSingleton].nickName]}];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:currentCommentCount inSection:0];
    NSArray *indexpathArr = @[newIndexPath];
    [bottemView.comTableView insertRowsAtIndexPaths:indexpathArr withRowAnimation:UITableViewRowAnimationBottom];
    
    //跳转到刚刚发表的评论的位置
    NSIndexPath *indexpth = [NSIndexPath indexPathForRow:currentCommentCount - 2 inSection:0];
    [bottemView.comTableView selectRowAtIndexPath:indexpth animated:YES scrollPosition:UITableViewScrollPositionBottom];
    
    //收回键盘并清空输入框内容
    UIView *testView = [bottemView viewWithTag:COMBGVIEW_TAG];
    if (testView.frame.origin.y < ([UIScreen mainScreen].bounds.size.height - testView.frame.origin.y)) {
        [bottemView keyboardDismiss];
        bottemView.commentField.text = @"";
        [bottemView.commentField resignFirstResponder];
    }
}


#pragma mark -
#pragma mark   QYCommentViewDelegate
- (void)loginOrRegisterWith:(loginMes)state
{
    if (state == doLogin) {
        //跳转登陆界面
        QYLoginViewController *login = [[QYLoginViewController alloc] init];
        [self presentViewController:login animated:YES completion:nil];
    }else{
        //跳转注册界面
        QYRegisterViewCFirst *signin = [[QYRegisterViewCFirst alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:signin];
        [self presentViewController:nav animated:YES completion:nil];
    }
    isLogin = YES;
}


@end