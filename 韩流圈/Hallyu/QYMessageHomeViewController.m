//
//  QYMessageHomeViewController.m
//  Hallyu
//
//  Created by qingyun on 14-8-11.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYMessageHomeViewController.h"
#import "QYMessageViewController.h"
#import "QYStatuesTableViewCell.h"
#import "focusView.h"
#import "MJRefresh.h"
#import "UIViewExt.h"
#import "RTLabel.h"
#import "SunSearchMessageController.h"
#import "AsyncImageView.h"
#import "unifiedHeaderFile.h"
#import "UIImage+Extension.h"
#import "SVProgressHUD.h"
#import "QYPersonInformationViewController.h"
#import "UIImageView+AFNetworking.h"

static NSInteger const height =80;
static NSInteger const btny =14;
static NSInteger const btnWidth =32;
static NSInteger const btnHeight =32;
static int saveImageNum = 0;

char * imageName[] = {"筛选类别-综合","筛选类别-影视", "筛选类别-音乐","筛选类别-明星","筛选类别-时尚","筛选类别-文化"};
char * imagePressName[] = {"筛选类别-综合-press","筛选类别-影视-press", "筛选类别-音乐-press","筛选类别-明星-press",
    "筛选类别-时尚-press","筛选类别-文化-press"};

@interface QYMessageHomeViewController () <UITableViewDataSource,UITableViewDelegate,
UITabBarControllerDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;

//从API获取cell上的数据
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *leftTitleLabel;
@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) NSMutableArray *cellList;  //从API获取cell上的数据
@property (nonatomic, strong) UIView *bgView;            //背景图片
@property (nonatomic, strong) UILabel *titleLable;       //显示文章内容的头部信息，主要是文章的文章名。
@property (nonatomic, strong) UIImageView *textImgView;  //文章中附带的图片。
@property (nonatomic, strong) UIImageView *lineView ;    //自定义的分割线


//从API获取主题数据
@property (nonatomic, strong) NSArray *themeArray;
@property (nonatomic, strong) NSMutableArray *moreDataArray;

@property (nonatomic, strong) QYMyDBManager *myDB;            //数据库
@property (nonatomic, strong) QYImageManager *imageManager;   //图片保存和处理

@end

@implementation QYMessageHomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        titleLable.font = [UIFont boldSystemFontOfSize:20.0f];
        titleLable.text = @"韩流圈";
        titleLable.textColor = [UIColor whiteColor];
        titleLable.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = titleLable;
        self.myDB = [QYMyDBManager shareInstance];
        self.imageManager = [[QYImageManager alloc]init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //视图将要出现的时候显示Navigationbar
    self.navigationController.navigationBarHidden = NO;
    
    //设置navigationBar为不透明
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellList = [NSMutableArray array];
    //    NSString *stringDate = @"2014-10-10 12:00:09";
    //    QYDateSwith *date = [[QYDateSwith alloc]initWithDate:stringDate];
    //    NSLog(@"date :%d %d %d %d %d %d",date.year,date.month,date.day,date.hour,date.minute,date.second);
    //    NSLog(@"dateFromNow :%@",[QYDateSwith dateSwithWithDate:stringDate]);
    
    //从数据库取数据
    [self loadDataFromDBwithColumns:nil];
    
    //取消系统对图片颜色的修改
    UIImage *toolImage = [UIImage imageNamed:@"主导航-资讯-press"];
    UITabBarItem *msgItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"主导航-资讯"] selectedImage:[toolImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    //设置tabBar
    self.tabBarItem = msgItem;
    [self.tabBarItem setImageInsets:UIEdgeInsetsMake(10, 0, -10, 0)];
    
    
    //设置navigationBar有关颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];
    
    self.tabBarController.delegate = self;
    
    //从服务器端获取数据
    [self downLoadDataSource];
    
    //对左右barButtonItem的设置。
    [self setupInterface];
    
    //定义上拉、下拉加载数据
    [self updateDataSource];
    
    //添加焦点图
    [self addHeadImage];
    
    //设置分割线的边距。
    self.tableView.separatorInset = UIEdgeInsetsMake(0,10,0,10);
    
    //注册cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellForFirst"];
    [self.tableView registerClass:[QYStatuesTableViewCell class] forCellReuseIdentifier:@"cellForSecd"];
}

#pragma mark -
#pragma mark viewDidLoad 中的调用方法实现


//下载并保存图片到本地
- (void)saveImageWithDataArray:(NSArray *)array
{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < array.count; i++) {
    NSString *imageURL = array[i][kImage];
    __weak UIImageView *imageView = nil;
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]
                                           placeholderImage:nil
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                        dispatch_async(concurrentQueue, ^{
                                                            [self.imageManager saveImage:image ImageURL:request.URL];
                                                        });
                                                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                       
                                                        
                                                    }];
    }

}


//从服务器端获取数据
- (void)downLoadDataSource
{
    //初始化数据。
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"theme": @"综合", @"max_id":@"0", @"refresh":@"1"};
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NEWS_LIST parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:kSuccess] doubleValue]) {
            NSArray *array = [responseObject objectForKey:kData];
            [self.cellList removeAllObjects];
            [self.cellList addObjectsFromArray:array];
            [self.tableView reloadData];
            
            //更新数据库
            for (NSDictionary *dic in _cellList) {
                [self.myDB saveMessageAndBBSListToDB:kMessageListTable withColumns:dic];
            }
        }else{
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}


//从数据库中获取数据
- (void)loadDataFromDBwithColumns:(NSDictionary *)dictionary
{
    NSArray *array = [self.myDB messageQueryFromDB:kMessageListTable withColumns:dictionary];
    [_cellList removeAllObjects];
    [_cellList addObjectsFromArray:array];
}


//设置导航栏上的左右barButtonItem
- (void)setupInterface
{
    //自定义左边UIBarButtonItem
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 25, 30, 44)];
    _leftTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 13, 40, 17)];
    _leftTitleLabel.text=@"综合";
    _leftTitleLabel.textColor =[UIColor whiteColor];
    _filterBtn =[[UIButton alloc]initWithFrame:CGRectMake(35, 13, 10, 17)];
    [_filterBtn setImage:[UIImage imageNamed:@"筛选箭头"] forState:UIControlStateNormal];
    [view addSubview:_leftTitleLabel];
    [view addSubview:_filterBtn];
    
    //给自定义的左边的UIBarButtonItem添加单击手势
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(leftAction)];
    [view addGestureRecognizer:tap];
    
    UIBarButtonItem *left =[[UIBarButtonItem alloc]initWithCustomView:view];
    self.navigationItem.leftBarButtonItem = left;
    
    
    //设置右上角搜索按钮
    UIButton *rightBtn =[[UIButton alloc]initWithFrame:CGRectMake(270, 10, 25, 25)];
    [rightBtn addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setImage:[UIImage imageNamed:@"搜索"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    rightBtn.tintColor=[UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //定义主题栏下显示的主题类型文字
    self.themeArray = @[@"综合",@"影视",@"音乐",@"明星",@"时尚",@"文化"];
    
    
    //取消tableView自带的分割线。
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


//定义上拉下拉刷新数据的方法。
- (void)updateDataSource
{
    __block QYMessageHomeViewController *messageHomeVC = self;
    
    //上拉加载更多
    [self.tableView addFooterWithCallback:^{
        [messageHomeVC upRefreshMoreData];
    }];
    
    //下拉刷新
    [self.tableView addHeaderWithCallback:^{
        [messageHomeVC downRefreshMoreData];
    }];
}


//上拉加载更多（暂且未实现）
-(void)upRefreshMoreData
{
    //记录更新以前数据块的数量
    NSInteger currentCount =self.moreDataArray.count;
    [self.moreDataArray addObjectsFromArray:_cellList];
    
    //记录更新后的数据块数量
    NSInteger lastCount =self.moreDataArray.count;
    NSMutableArray *newData = [NSMutableArray array];
    for (NSInteger i = currentCount; i < lastCount; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:2];
        [newData addObject:indexpath];
    }
    
    //添加删除数据的开始和结束，数据的改变应该在其内部。
    //更新数据
    [self.tableView reloadData];
    [self.tableView footerEndRefreshing];
}


//下拉刷新
-(void)downRefreshMoreData
{
    [self.tableView performSelector:@selector(headerEndRefreshing) withObject:self.tableView afterDelay:0.6];
    
    //网络请求数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if (![_leftTitleLabel.text isEqualToString:@"综合"]) {
        [self loadDataFromDBwithColumns:@{kTheme: _leftTitleLabel.text}];
    }else{
        [self loadDataFromDBwithColumns:nil];
    }
    
    //记录当前资讯最大主题ID，用于下拉刷新时作为参数，向服务器请求比此ID更大的资讯
    NSString *maxId = nil;
    if (_cellList.count) {
        maxId = _cellList[0][kId];
    }else{
        maxId = @"0";
    }
    NSDictionary *parameters = @{@"theme": _leftTitleLabel.text, @"max_id":@"39", @"refresh":@"0"};
    
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NEWS_LIST parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //请求数据成功
        if ([[responseObject objectForKey:@"success"] doubleValue]) {
            NSLog(@"result :%@",operation.responseString);
            NSArray *array = [responseObject objectForKey:@"data"];
            [self.cellList addObjectsFromArray:array];
            [self.tableView reloadData];
        }
        
        //数据库更新存储数据
        for (NSDictionary *dic in _cellList) {
            [self.myDB saveMessageAndBBSListToDB:kMessageListTable withColumns:dic];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}



#pragma mark -
#pragma mark - UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //根据自定义的cell类QYStatuesTableViewCell设置cell
    QYStatuesTableViewCell *messageSection2Cell = nil;
    messageSection2Cell = [tableView dequeueReusableCellWithIdentifier:@"cellForSecd" forIndexPath:indexPath];
    
    //判断图片是从网络请求下来的还是从数据库中取出的
    //从网络请求的图片
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    if ([_cellList[indexPath.row][kImage] hasPrefix:@"http://"]) {
        NSString *imageURL = [NSString stringWithFormat:@"%@",_cellList[indexPath.row][kImage]];
        
        //下载并保存图片
        __weak UIImageView *imageView = messageSection2Cell.textImgView;
        [messageSection2Cell.textImgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]
                                               placeholderImage:nil
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                            [imageView setImage:image];
                                                            dispatch_async(concurrentQueue, ^{
                                                                [self.imageManager saveImage:image ImageURL:request.URL];
                                                            });
                                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                            NSLog(@"failed:%@",error);
                                                        }];
        //从数据库取出的图片
    }else{
        dispatch_async(concurrentQueue, ^{
        UIImage *image = [self.imageManager getImage:_cellList[indexPath.row][kImage]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                messageSection2Cell.textImgView.image = image;
            });
        });
    }
    
    //设置cell上的数据
    [messageSection2Cell loadCellData:self.cellList[indexPath.row]];
    return messageSection2Cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 91.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}


#pragma mark-
#pragma mark - UITableViewDelegate
//点击cell之后，进入相应的文章视图
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYMessageViewController *messageViewC = [[QYMessageViewController alloc]init];
    
    //将数据传送到下一个控制器
    messageViewC.dataArray = self.cellList;
    
    //记录当前点击行号，并传送到QYMessageViewController，用于提取dataArray中的数据
    messageViewC.dataNum = indexPath.row;
    [self.navigationController pushViewController:messageViewC animated:YES];
}


#pragma -
#pragma mark  UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    //点击tabbar上的资讯按钮取消资讯页面的主题选择,并自动切换到综合主题内容
    if (self.tableView.tableHeaderView && viewController == self.tabBarController.viewControllers[0]) {
        [self loadDataFromDBwithColumns:nil];
        [self.tableView reloadData];
        _leftTitleLabel.text = @"综合";
        [self addHeadImage];
        if ([self.bgView superview]) {
            [self.bgView removeFromSuperview];
            [_filterBtn  setImage:[UIImage imageNamed:@"筛选箭头"] forState:UIControlStateNormal];
        }
    }
    static BOOL isPush = NO;
    if (![QYUserSingleton sharedUserSingleton].isLogin) {
        isPush = NO;
    }else if ([QYUserSingleton sharedUserSingleton].isLogin && tabBarController.selectedIndex == 2) {
        if (!isPush) {
            QYPersonInformationViewController *personInfo = [[QYPersonInformationViewController alloc]init];
            [tabBarController.viewControllers[2] pushViewController:personInfo animated:NO];
            isPush = YES;
        }
    }
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 2 && tabBarController.selectedViewController == viewController) {
        return NO;
    }
    return YES;
}


//leftNavigationItem（主题选择按钮）事件
-(void) leftAction{
    //判断bgView的父视图是否存在。
    if (![self.bgView superview])
    {
        //附加到self.view上的半透明层
        _bgView = [[UIView alloc]initWithFrame:self.view.bounds];
        _bgView.alpha =0.8;
        _bgView.backgroundColor = [UIColor blackColor];
        
        //定义主题栏的滚动视图
        UIScrollView *scrollView =[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, height-8)];
        scrollView.showsHorizontalScrollIndicator =NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.directionalLockEnabled=YES;
        scrollView.alwaysBounceHorizontal=YES;
        
        //scrollView下面的绿色的线
        UIView *lineView =[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(scrollView.frame), 320, 1)];
        lineView.backgroundColor =[UIColor greenColor];
        [_bgView addSubview:lineView];
        
        for (int i =0 ; i<self.themeArray.count; i++) {
            
            
            //定义并设置主题栏显示类型名字的lable
            UILabel *ttLabel =[[UILabel alloc]initWithFrame:CGRectMake(10+(32 + 25)*i,btny+22, btnWidth , btnHeight)];
            ttLabel.font =[UIFont systemFontOfSize:13.0f];
            ttLabel.tag =2000+i;
            ttLabel.lineBreakMode = NSLineBreakByCharWrapping;
            ttLabel.textAlignment =NSTextAlignmentCenter;
            ttLabel.textColor =[UIColor whiteColor];
            ttLabel.text=self.themeArray[i];
            [scrollView addSubview:ttLabel];
            
            //定义并设置主题栏button，用数组给button添加标题
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10 + (32 + 25)*i, btny, btnWidth, btnHeight)];
            [btn setTitle:self.themeArray[i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(themeAction:) forControlEvents:UIControlEventTouchUpInside];
            [btn addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchDown];
            NSString *imageStr = [NSString stringWithUTF8String:imageName[i]];
            [btn setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
            btn.tag =1000 +i;
            [scrollView addSubview:btn];
            scrollView.contentSize =CGSizeMake(btn.right + 10, height);
            
        }
        //设置leftBarButtonItem右边button的图片
        [_filterBtn setImage:[UIImage imageNamed:@"筛选箭头up"] forState:UIControlStateNormal];
        [self.bgView addSubview:scrollView];
        [self.view addSubview:self.bgView];
    }else{
        
        //再次点击主题筛选按钮，主题栏消失
        [_bgView removeFromSuperview];
        [_filterBtn setImage:[UIImage imageNamed:@"筛选箭头"] forState:UIControlStateNormal];
    }
    
}

//定义rightNavigationItem（搜索）事件
-(void)rightAction{
    //如果主题栏存在，移除它
    if ([self.bgView superview]) {
        [self.bgView removeFromSuperview];
        [_filterBtn setImage:[UIImage imageNamed:@"筛选箭头"] forState:UIControlStateNormal];
    }
    SunSearchMessageController *searchVC =[[SunSearchMessageController alloc]init];
    [self addChildViewController:searchVC];
    [self.view addSubview:searchVC.view];
}


//点击主题栏里某项时，此项处于选中状态
-(void)changeColor:(UIButton *)sender
{
    for (int i =0; i<self.themeArray.count; i++) {
        //用tag取值的时候注意
        UILabel *labelText =(UILabel *)[self.view viewWithTag:2000 + i];
        UIButton *btn = (UIButton *)[self.view viewWithTag:1000 + i];
        
        //判断是否被选中
        if ( sender.tag == btn.tag ) {
            labelText.textColor =[UIColor greenColor];
            NSString *imagePressStr =[NSString stringWithUTF8String:imagePressName[i]];
            [btn setImage:[UIImage imageNamed:imagePressStr] forState:UIControlStateNormal];
        }
        else{
            NSString *imageStr = [NSString stringWithUTF8String:imageName[i]];
            [btn setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
            labelText.textColor =[UIColor whiteColor];
        }
    }
}

//点击屏幕任何位置取消主题选择
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.bgView superview]) {
        [self.bgView  removeFromSuperview];
        [_filterBtn setImage:[UIImage imageNamed:@"筛选箭头"] forState:UIControlStateNormal];
    }
}

//点击主题栏中任意一项事件处理
- (void)themeAction:(UIButton *)sender
{
    [_bgView removeFromSuperview];
    [_filterBtn setImage:[UIImage imageNamed:@"筛选箭头"] forState:UIControlStateNormal];
    _leftTitleLabel.text = self.themeArray[sender.tag - 1000];
    [self.tableView performSelector:@selector(headerEndRefreshing) withObject:self.tableView afterDelay:0.5];
    if (![self.themeArray[sender.tag - 1000] isEqualToString:@"综合"]) {
        self.tableView.tableHeaderView = nil;
        NSString *theme = self.themeArray[sender.tag - 1000];
        [self loadDataFromDBwithColumns:@{kTheme: theme}];
        [self.tableView reloadData];
    }else{
        [self addHeadImage];
        [self loadDataFromDBwithColumns:nil];
        [self.tableView reloadData];
    }
}


//添加最上方大图方法实现
- (void)addHeadImage
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 170)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 150)];
    UILabel *tittleLable = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(imageView.frame), 310, 20)];
    [self loadDataFromDBwithColumns:nil];
    if (_cellList.count > 0) {
        imageView.image = [self.imageManager getImage:self.cellList[0][kImage]];
        tittleLable.text = self.cellList[0][kTitle];
    }else{
        [self performSelector:@selector(addHeadImage) withObject:nil afterDelay:1];
    }
    [view addSubview:imageView];
    [view addSubview:tittleLable];
    self.tableView.tableHeaderView = view;
}

@end
