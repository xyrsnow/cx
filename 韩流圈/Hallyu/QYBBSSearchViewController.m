//
//  QYBBSSearchViewController.m
//  Hallyu
//
//  Created by 泰坦虾米 on 14-8-13.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYBBSSearchViewController.h"
#import "RTLabel.h"
#import "UIViewExt.h"

@interface QYBBSSearchViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (nonatomic, retain) UIView *transparentView;      //当搜索失败的时候，出现的半透明的视图
@property (nonatomic, retain) UITapGestureRecognizer *taps;
@property (nonatomic, retain) NSArray *quearyData;
@property (nonatomic, strong) NSArray *cellList;            //从API获取cell上的数据
@property (nonatomic, strong) NSMutableArray *cellMoreData;
@end

@implementation QYBBSSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *middleView;
    UIView *view;
    [self creatBackgroudView:&middleView view_p:&view];
    
    [self creatSearchBar:view];
    
    [self creatBackBtn:view];
    
    [self creatTableView:middleView];
    
    self.tabBarController.tabBar.hidden = YES;

}


 - (void)creatBackgroudView:(UIView **)middleView_p view_p:(UIView **)view_p
 {
     //半透明
     self.view.backgroundColor = [UIColor clearColor];
     *middleView_p = [[UIView alloc]initWithFrame:self.view.bounds];
     (*middleView_p).backgroundColor = [UIColor blackColor];
     (*middleView_p).alpha = 0.8;
     [self.view addSubview:*middleView_p];
     
     *view_p = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
     (*view_p).backgroundColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1];
     [self.view addSubview:*view_p];
 }


 - (void)creatSearchBar:(UIView *)view
 {
     //搜索栏
     self.searchBar = [[UITextField alloc]initWithFrame:CGRectMake(50, 27, 260, 30)];
     self.searchBar.placeholder = @"请输入帖子正文或者标题";
     self.searchBar.delegate  =self;
     self.searchBar.textColor = [UIColor whiteColor];
     self.searchBar.backgroundColor = [UIColor greenColor];
     
     UIButton *deleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 30, 30)];
     [deleBtn setImage:[UIImage imageNamed:@"搜索-删除"] forState:UIControlStateNormal];
     [deleBtn setImage:[UIImage imageNamed:@"搜索-删除-press"] forState:UIControlStateHighlighted];
     [deleBtn addTarget:self action:@selector(onDelebtn) forControlEvents:UIControlEventTouchUpInside];
     
     self.searchBar.rightView =  deleBtn;
     self.searchBar.rightViewMode = UITextFieldViewModeWhileEditing;
     self.searchBar.borderStyle = UITextBorderStyleRoundedRect;
     self.searchBar.backgroundColor =[UIColor colorWithRed:26/255.0 green:200/255.0 blue:99/255.0 alpha:0.5];
     [view addSubview:self.searchBar];
     self.searchBar.returnKeyType = UIReturnKeySearch;
 }


 - (void)creatBackBtn:(UIView *)view
 {
     //返回按钮
     UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 25, 30, 30)];
     [leftBtn addTarget:self action:@selector(onReturnBtn) forControlEvents:UIControlEventTouchUpInside];
     [leftBtn setImage:[UIImage imageNamed:@"搜索-返回"] forState:UIControlStateNormal];
     [leftBtn setImage:[UIImage imageNamed:@"搜索-返回-press"] forState:UIControlStateHighlighted];
     [view addSubview:leftBtn];
 }


 - (void)creatTableView:(UIView *)middleView
 {
     _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 480-44) style:UITableViewStylePlain];
     self.tableView.backgroundColor = [UIColor clearColor];
     [middleView addSubview:self.tableView];
 }


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.searchBar becomeFirstResponder];
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.contentOffset = CGPointMake(0, -20);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = YES;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.hidden = NO;
    [self.searchBar removeFromSuperview];
}


//返回按钮
-(void)onReturnBtn
{
    [self.view removeFromSuperview];
}


//删除按钮
-(void)onDelebtn
{
    self.searchBar.text = nil;
    NSArray *array = [self.tableView subviews];
    for (int i = 0; i < array.count; i++) {
        [array[i] removeFromSuperview];
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.quearyData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (nil == cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.textLabel.text = self.quearyData[indexPath.row];
    
    return cell;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}


#pragma mark - 搜索框的delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
     return YES;
}


#pragma mark--------------UITextFiledDelegate------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    NSArray *array = [self.tableView subviews];
    for (int i = 0; i < array.count; i++) {
        [array[i] removeFromSuperview];
    }
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchBar resignFirstResponder];
    if ([textField.text isEqualToString: @"A"]) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.cellMoreData =[NSMutableArray arrayWithArray:self.cellList];
        UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(110, 100, 100, 20)];
        label.tintColor =[UIColor whiteColor];
        label.textColor=[UIColor whiteColor];
        label.text=@"没有其他的结果了";
        [self.tableView addSubview:label];
        
        [self.tableView reloadData];
    } else if ([textField isEqual:@""]) {
        NSLog(@"do nothing...");
    }
    else{
        RTLabel *label =[[RTLabel alloc]initWithFrame:CGRectMake(100, 75, 200, 100)];
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


-(void)onTapGesture
{
    //点击视图的时候，把transparentView销毁
    [self.transparentView removeFromSuperview];
    self.transparentView = nil;
}

@end
