//
//  QYMessageSearchViewController.m
//  Hallyu
//
//  Created by jiwei on 14-8-9.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYMessageSearchViewController.h"
#import "QYStatuesTableViewCell.h"
#import "QYMessageViewController.h"
#import "MJRefresh.h"
#import "UIViewExt.h"
#import "RTLabel.h"
#import "AsyncImageView.h"

@interface QYMessageSearchViewController () <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(nonatomic,strong)    UITextField *seachBar;
@property (nonatomic,strong) NSArray *cellList;
@property (nonatomic,strong) NSMutableArray *cellMoreData;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong)NSString *lastMessageID;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property(nonatomic,strong)UIButton *btn;

@end

@implementation QYMessageSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
        _cellList = @[@{@"title": @"受打击了教室里",
                        @"text":@"受打击了教室里咖啡加速度了可分解落实的开发拉萨的减肥克                                                                 大佛速度速度来飞机上来看的房价来看是否",
                        @"imageUrl":@"http://e.hiphotos.baidu.com/image/pic/item/bd315c6034a85edf89ae5cbe4b540923dd547508.jpg"
                        },
                     
                      @{@"title": @"受打击了教室里",
                          @"text":@"受打击了教室里咖啡加速度了可分解落实的开发拉萨的减肥克                                                                 大佛速度速度来飞机上来看的房价来看是否",
                          @"imageUrl":@"http://e.hiphotos.baidu.com/image/pic/item/bd315c6034a85edf89ae5cbe4b540923dd547508.jpg"
                        },

                    
                      ];
        
    }
//    self.cellMoreData =[NSMutableArray arrayWithArray:self.cellList];

    
    return self;
}
//keyBoard第一相应
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    [self.searchBar becomeFirstResponder];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.btn removeFromSuperview];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	UIView *baView =[[UIView alloc]initWithFrame:self.view.bounds];
    baView.backgroundColor =[UIColor blackColor];
    baView.alpha =0.5;

    //添加navigationItem的leftBarButtonItem
    
    UIButton *leftButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [leftButton setImage:[UIImage imageNamed:@"搜索-返回"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backToPreviousVC:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem =[[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem=leftItem;
    
    //添加自定义SeachBar
    _seachBar =[[UITextField alloc]initWithFrame:CGRectMake(22, 25, 280, 35)];
    _seachBar.delegate=self;
    _seachBar.borderStyle = UITextBorderStyleRoundedRect;
    self.navigationItem.titleView =_seachBar;
    _seachBar.backgroundColor =[UIColor colorWithRed:26/255.0 green:200/255.0 blue:99/255.0 alpha:0.5];
    //textField.backgroundColor =[UIColor clearColor];
    _seachBar.textColor=[UIColor whiteColor];

    
    //找不到指定名字的图片
    _seachBar.disabledBackground =[UIImage imageNamed:@"bg"];
    
    
    //添加自定义searchBar的X按钮
    _btn =[[UIButton alloc]initWithFrame:CGRectMake(0, 12, 20, 20)];
    
    _btn.left=(_seachBar.right-5-15);
    [_btn setImage:[UIImage imageNamed:@"搜索-删除"] forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(deleteText) forControlEvents:UIControlEventTouchUpInside];

    //删除文字键不可用
    [self.navigationController.navigationBar addSubview:_btn];

    //创建uitableView
    self.tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,AutoScreenHeight  -44) style:UITableViewStylePlain];
    _tableView.backgroundColor =[UIColor blackColor];
    //_tableView.separatorColor =[UIColor clearColor];
// _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:baView];
    [baView addSubview:_tableView];
    
    //上拉和下滑刷新数据应用频繁，可以设置成公共接口
    //上拉刷新数据
    __block QYMessageSearchViewController *MessageSearchVC  = self;
    [self.tableView addFooterWithCallback:^{
        [MessageSearchVC upRefreshMoreData];
    }];
    
    //下拉刷新
    [self.tableView addHeaderWithCallback:^{
        [MessageSearchVC downRefreshMOreData];
    } ];   //backtn 设置背景色
    self.backBtn.backgroundColor =[UIColor colorWithRed:189/255.0 green:189/255.0 blue:195/255.0 alpha:1.0];
    
}

//代码可以优化，方法里定义一句话，可以不用写方法
-(void)resign
{
    [self.seachBar resignFirstResponder];
}
-(void)deleteText
{
    self.seachBar.text=@"";
    self.cellMoreData=nil;
    self.tableView.tableFooterView = nil;
    [self.tableView reloadData];
  
}
/**
 *  下拉加载更多
 *
 *  @return 最新数据
 */
-(void)downRefreshMOreData
{
    NSDictionary *fakeDict =@{@"title": @"是否健康的环境发生",
                          @"text":@"的房价开始看环境的口感好看过大佛速度速度来飞机上来看的房价来看是否",
                          @"imageUrl":@"http://e.hiphotos.baidu.com/image/pic/item/bd315c6034a85edf89ae5cbe4b540923dd547508.jpg"
                            };
   // [self.tableView beginUpdates];
    [self.cellMoreData removeAllObjects];
    [self.cellMoreData addObject:fakeDict];
    [self.cellMoreData addObject:fakeDict];
    //[self.tableView endUpdates];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // 刷新表格
//        [self.tableView reloadData];
//        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
//        [self.tableView headerEndRefreshing];
//    });
    [self.tableView reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [self.tableView headerEndRefreshing];
    
    
}
/**
 *  上拉数据调用加载更多数据
 */
-(void)upRefreshMoreData
{
    
    NSArray *data =self.cellList;
    NSMutableArray *ret =[[NSMutableArray alloc]initWithArray:data];
    //[ret removeObjectAtIndex:0];
    NSInteger currentCount =self.cellMoreData.count;
    //把历史数据放到新数据后面
    [self.cellMoreData addObjectsFromArray:ret];
    //统计插入历史微博后的总微博的个数
    NSUInteger lastCount =self.cellMoreData.count;
    NSMutableIndexSet *indexSet =[[NSMutableIndexSet alloc]init];
    
    for (NSInteger i =currentCount; i <lastCount; i++) {
        NSIndexSet *temIndexSet =[NSIndexSet indexSetWithIndex:i];
        [indexSet addIndexes:temIndexSet];
    }
    [self.tableView beginUpdates];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    [self.tableView footerEndRefreshing];

    //下面代码是否需要
     [self.tableView reloadData];
}


#pragma mark ----------UITableDatasource---------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"=======%lu",(unsigned long)self.cellMoreData.count);
    return self.cellMoreData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
    //把所有的cell标识定义成宏公用效果应该会更好
    static NSString *cellIdentify =@"QYMessage";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell ==nil) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        
    }
    UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(15, 20, 305, 14)];
    label.font=[UIFont systemFontOfSize:14.0];
    label.textColor =[UIColor whiteColor];
    cell.backgroundColor =[UIColor blackColor];
    label.text =[_cellList[indexPath.row]objectForKey:@"text"];
    [cell.contentView addSubview:label];
    
    return cell;
    //QYStatuesTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentify];
  //  UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentify];
//    if (cell == nil) {
//        //cell =[[QYStatuesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
//        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
//        cell.backgroundColor =[UIColor blackColor];
//        
//        cell.selectionStyle= UITableViewCellSelectionStyleNone;
//    }
// //   cell.messageCellData =self.cellMoreData[indexPath.section];
//    cell.textLabel.textColor =[UIColor whiteColor];
//    cell.textLabel.text =[_cellList[indexPath.row]objectForKey:@"text"];
//    //cell.textLabel.text=@"sdjkhgfkghj";
//   // NSURL *imageUrl = [NSURL URLWithString:@"http://e.hiphotos.baidu.com/image/pic/item/bd315c6034a85edf89ae5cbe4b540923dd547508.jpg"];
//   // cell.textImgView.imageURL =imageUrl;
//    
//    //tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    //[self.tableView reloadData];
//    return cell;
    
}

#pragma mark-------------UItableVIewDelegate-----------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYMessageViewController *messageViewC = [[QYMessageViewController alloc]init];
    [self.navigationController pushViewController:messageViewC animated:YES];
    
    [self.searchBar resignFirstResponder];
    NSLog(@"123");
}
#pragma mark------UIAlterViewDelegate-----------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [self.navigationController popViewControllerAnimated:YES];
            self.navigationController.navigationBarHidden =NO;
        }
            break;
        case 1:
        {
            self.searchBar.text = @"";
        }
            break;
        default:
            break;
    }
}
#pragma mark--------------UITextFiledDelegate------
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
    
    [self.seachBar resignFirstResponder];
    if ([_seachBar.text isEqualToString: @"A"]) {
         self.cellMoreData =[NSMutableArray arrayWithArray:self.cellList];
       UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(110, 100, 100, 20)];
        label.tintColor =[UIColor whiteColor];
        label.textColor=[UIColor whiteColor];
        label.text=@"没有其他的结果了";
        self.tableView.tableFooterView=label;
        [self.tableView reloadData];
    }
    else{
        RTLabel *label =[[RTLabel alloc]initWithFrame:CGRectMake(110, 50, 10, 0)];
        label.text=@"啊呜，没有搜到结果...\n换个关键词再试试？";
        label.tintColor =[UIColor whiteColor];
       label.textColor=[UIColor whiteColor];
        label.font =[UIFont systemFontOfSize:14.0f];
        label.width = label.optimumSize.width;
        label.height =label.optimumSize.height;
        self.tableView.tableFooterView=label;

    }
    return YES;
}
#pragma mark---------TopliftBackAction----------
- (IBAction)backToPreviousVC:(UIButton *)sender {

    [_btn removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
