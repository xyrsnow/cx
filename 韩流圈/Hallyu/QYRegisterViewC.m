//
//  QYRegisterViewC.m
//  Hallyu
//
//  Created by qingyun on 14-9-3.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYRegisterViewC.h"
#import "UIViewExt.h"

#define ADJUST_HEIGHT 80

@interface QYRegisterViewC ()

{
    CGFloat _screenHight;  //主屏幕高度
}

@end

@implementation QYRegisterViewC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
    
    [self hideKeyGesture];
}

- (void)hideKeyGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)createUI
{
    _screenHight = [UIScreen mainScreen].bounds.size.height;
    
    self.view.backgroundColor = [UIColor colorWithRed:29/255.0 green:216/255.0 blue:116/255.0 alpha:1.0];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 30, 25, 25)];
    [backBtn setImage:[UIImage imageNamed:@"搜索-返回"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"搜索-返回-press"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backToPreviousView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    _topLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 170, 220, 20)];
    _topLabel.textAlignment = NSTextAlignmentCenter;
    _topLabel.font = [UIFont boldSystemFontOfSize:19.0];
    _topLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_topLabel];
    
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(15, 215, 290, 45)];
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.font = [UIFont systemFontOfSize:17.0];
    _textField.layer.cornerRadius = 2.5;
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_textField];
    
    _makeSureBtn = [[UIButton alloc]initWithFrame:CGRectMake(_textField.left, _textField.bottom + 20, _textField.width, _textField.height)];
    _makeSureBtn.backgroundColor = [UIColor colorWithRed:20/255.0 green:138/255.0 blue:77/255.0 alpha:1.0];
    [_makeSureBtn addTarget:self action:@selector(makeSureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _makeSureBtn.layer.cornerRadius = 2.5;
    [self.view addSubview:_makeSureBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)backToPreviousView
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)makeSureBtnAction:(UIButton *)sender
{
    [self doMakerSuerAction:sender];
}

- (void)doMakerSuerAction:(UIButton *)sender
{
    
}

- (void)hideKeyBoard
{
    [_textField resignFirstResponder];
}

@end
