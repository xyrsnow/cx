//
//  QYFeedBackViewController.m
//  Hallyu
//
//  Created by xujingwei on 14-9-21.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYFeedBackViewController.h"

@interface QYFeedBackViewController ()<UITextViewDelegate>
@property (nonatomic,strong)UITextView *feedbackText;

@end

@implementation QYFeedBackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        titleLable.font = [UIFont boldSystemFontOfSize:17.0f];
        titleLable.text = @"反馈意见";
        titleLable.textColor = [UIColor whiteColor];
        titleLable.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = titleLable;
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackButtonItem:)];
        [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回-press"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;

    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendMessage:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _feedbackText = [[UITextView alloc]initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:_feedbackText];
    _feedbackText.text = @"新浪娱乐讯 SM、YG、JYP这三家公司今年上半年的总收入达到2228亿7589万6041韩元(约13亿5千万元)，比去年同期大幅上升500亿韩元(约3亿376万元)，创下了历史最高成绩。";
    _feedbackText.font = [UIFont systemFontOfSize:13];
    _feedbackText.multipleTouchEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //双击收回键盘
    UITapGestureRecognizer *doubleClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleClickForKeyboard:)];
    doubleClick.numberOfTapsRequired = 2;
    [self.feedbackText addGestureRecognizer:doubleClick];
    
    
}
- (void)doubleClickForKeyboard:(UITapGestureRecognizer *)ges
{
    if ([_feedbackText isFirstResponder]) {
        [_feedbackText resignFirstResponder];
    }else{
        [_feedbackText becomeFirstResponder];
    }
}

- (void)keyBoardWillShow:(NSNotification *)notification
{
    [self adjustViewForKeyboardReveal:YES notification:notification.userInfo];
    
}


-(void)keyBoardWillHide:(NSNotification *)notification
{
    [self adjustViewForKeyboardReveal:NO notification:notification.userInfo];
}
- (void)adjustViewForKeyboardReveal:(BOOL)showKeyboard notification:(NSDictionary*)notificationInfo
{
    NSDictionary *userInfo = notificationInfo;
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);//self.feedbackText.frame;
    if (showKeyboard) {
        frame.size.height -= CGRectGetHeight(keyboardRect);
    }else
    {
        
    }
    
    [UIView beginAnimations:@"resizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.feedbackText.frame = frame;
    NSLog(@"%@",NSStringFromCGRect(self.feedbackText.frame));
    [UIView commitAnimations];
}

#pragma mark - textView Delegate


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)onBackButtonItem:(UIBarButtonItem *)buttonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendMessage:(UIBarButtonItem *)barButtonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
