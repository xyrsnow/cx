//
//  SunSearchMessageController.m
//  hello
//
//  Created by sunbiao on 14-9-3.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunSearchMessageController.h"
#import"QYMessageViewController.h"
#import "UIViewExt.h"
#import "MJRefresh.h"
#import "RTLabel.h"

//自定义self.tableView的cell
@interface QYCustemCell : UITableViewCell
@end

@implementation QYCustemCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    //自定义分割线
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
            UIView *lineView =[[UIView alloc]initWithFrame:CGRectMake(0, 52, 320, 1)];
            lineView.backgroundColor =[UIColor grayColor];
            lineView.alpha = 0.5;
            [self addSubview:lineView];
        }
    return self;
}
@end


@interface SunSearchMessageController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UIButton *leftButton;
@property(nonatomic,strong)UITextField *searchBar;
@property(nonatomic,strong)UIButton *deleteBtn;
@property(nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong) NSArray *cellList;             //从API获取cell上的数据
@property (nonatomic,strong) NSMutableArray *cellMoreData;
@end

@implementation SunSearchMessageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

//设置视图将要出现的时候navigationBarHidden和tabBar的处理
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden=NO;
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cellMoreData = [NSMutableArray array];

    //添加半透明视图
    UIView *bgView =[[UIView alloc]initWithFrame:self.view.bounds];
    bgView.backgroundColor =[UIColor blackColor];
    bgView.alpha =0.8;
    
    //添加一个背景绿色图片，头部视图
    UIView *greenView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 64)];
    greenView.backgroundColor =  [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];
   
    //返回到上一个视图按钮
    _leftButton =[[UIButton alloc]initWithFrame:CGRectMake(10, 25, 30, 35)];
    [_leftButton setImage:[UIImage imageNamed:@"搜索-返回"] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(backToPreviousVC) forControlEvents:UIControlEventTouchUpInside];
    [greenView addSubview:_leftButton];
    
    //自定义searchBar
    _searchBar =[[UITextField alloc]initWithFrame:CGRectMake(_leftButton.right+5, 25, 260, 35)];
    _searchBar.delegate=self;
    _searchBar.borderStyle = UITextBorderStyleRoundedRect;
    _searchBar.backgroundColor =[UIColor colorWithRed:26/255.0 green:200/255.0 blue:99/255.0 alpha:0.5];
    _searchBar.textColor=[UIColor whiteColor];
    _searchBar.returnKeyType = UIReturnKeySearch;
    _searchBar.enablesReturnKeyAutomatically = YES;
    _searchBar.placeholder = @"请输入搜索关键词";
     [greenView addSubview:_searchBar];

    //添加删除按钮
    //添加自定义searchBar的X按钮
    _deleteBtn =[[UIButton alloc]initWithFrame:CGRectMake(greenView.right-50, 32, 20, 20)];
    [_deleteBtn setImage:[UIImage imageNamed:@"搜索-删除"] forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteText) forControlEvents:UIControlEventTouchUpInside];
    [greenView addSubview:_deleteBtn];
    
    //tableView设置
    self.tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, greenView.bottom, self.view.bounds.size.width,[UIScreen mainScreen].bounds.size.height - 44) style:UITableViewStylePlain];
    _tableView.backgroundColor =[UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:bgView];
    [self.view addSubview:greenView];
    
    
    //上拉加载更多数据
    __weak SunSearchMessageController *MessageSearchVC  = self;
    [self.tableView addFooterWithCallback:^{
        [MessageSearchVC upRefreshMoreData];
    }];
    
    //下拉刷新
    [self.tableView addHeaderWithCallback:^{
        [MessageSearchVC downRefreshMOreData];
    } ];
    
    //点击屏幕任何位置收回键盘
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSingleTapGesture:)];
    [bgView addGestureRecognizer:singleTapGesture];
    
    //去除tableView的分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

//定义手势方法
- (void)onSingleTapGesture:(UITapGestureRecognizer *)gesture
{
    [self.searchBar resignFirstResponder];
}

//下拉刷新更多数据(暂时未实现)
-(void)downRefreshMOreData
{
    NSDictionary *fakeDict =@{@"title": @"是否健康的环境发生",
                              @"text":@"的房价开始看环境的口感好看过大佛速度速度来飞机上来看的房价来看是否",
                              @"imageUrl":@"http://e.hiphotos.baidu.com/image/pic/item/bd315c6034a85edf89ae5cbe4b540923dd547508.jpg"
                              };
    [self.cellMoreData removeAllObjects];
    [self.cellMoreData addObject:fakeDict];
    [self.cellMoreData addObject:fakeDict];
    
    //有数据时再添加tableView到self.view
    [self.view addSubview:self.tableView];
    
    // 刷新表格
    [self.tableView reloadData];
    [self.tableView headerEndRefreshing];
    
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [self.tableView headerEndRefreshing];
}


//上拉数据调用加载更多数据
-(void)upRefreshMoreData
{
    NSArray *data =self.cellList;
    NSMutableArray *ret =[[NSMutableArray alloc]initWithArray:data];
    NSInteger currentCount =self.cellMoreData.count;
    
    //把历史数据放到新数据后面
    [self.cellMoreData addObjectsFromArray:ret];
    
    //统计插入历史微博后的总微博的个数
    NSUInteger lastCount =self.cellMoreData.count;
    
    NSMutableArray *insertions =[[NSMutableArray alloc]init];
    [self.tableView beginUpdates];
    for (NSInteger i = currentCount; i < lastCount; i++) {
        [insertions addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [self.tableView insertRowsAtIndexPaths:insertions withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    [self.tableView footerEndRefreshing];
    [self.tableView reloadData];
}

- (void)deleteText
{
    self.searchBar.text =@"";
    self.cellMoreData=nil;
    
    //没有数据显示的时候将tableView移除，为了让用户随时点击屏幕收回键盘
    [self.tableView removeFromSuperview];
    
    self.tableView.tableFooterView = nil;
    [self.tableView reloadData];

}

//定义退出搜索方法
-(void)backToPreviousVC
{
    [self.view removeFromSuperview];
}

#pragma mark -
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellMoreData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.00001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentify=@"cellID";
    QYCustemCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (nil == cell) {
        cell =[[QYCustemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.textLabel.text=[self.cellMoreData[indexPath.row] objectForKey:@"title"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYMessageViewController *messageViewC = [[QYMessageViewController alloc]init];
    [self.navigationController pushViewController:messageViewC animated:YES];
    
    [tableView performSelector:@selector(deselectRowAtIndexPath:animated:) withObject:indexPath afterDelay:0.5];
}

#pragma mark -
#pragma mark - UITextFiledDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""]) {
        self.cellMoreData=nil;
        self.tableView.tableFooterView = nil;
        [self.tableView reloadData];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchBar resignFirstResponder];
    
    //对搜索条件进行判断
    if ([_searchBar.text isEqualToString: @"A"]) {
        
        //符合搜索条件的处理
        [self.view addSubview:self.tableView];
        self.cellMoreData =[NSMutableArray arrayWithArray:self.cellList];
        UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(110, 100, 100, 20)];
        label.tintColor = [UIColor whiteColor];
        label.textColor = [UIColor whiteColor];
        label.text = @"没有其他的结果了";
        label.font = [UIFont systemFontOfSize:12];
        self.tableView.tableFooterView=label;
        
        [self.tableView reloadData];
    }else{
        [self.view addSubview:self.tableView];
        RTLabel *label =[[RTLabel alloc]initWithFrame:CGRectMake(110, 30, 180, 20)];
        label.text=@"啊呜，没有搜到结果...\n换个关键词再试试？";
        label.tintColor =[UIColor whiteColor];
        label.textColor=[UIColor whiteColor];
        label.font =[UIFont systemFontOfSize:14.0f];
        label.width = label.optimumSize.width;
        label.height =label.optimumSize.height;
        [self.tableView addSubview:label];
    }
        return YES;
}

@end
