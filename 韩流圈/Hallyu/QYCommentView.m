//
//  QYCommentView.m
//  Hallyu
//
//  Created by qingyun on 14-9-1.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYCommentView.h"
#import "AsyncImageView.h"
#import "unifiedHeaderFile.h"
#import "QYPersonInformationViewController.h"

@interface QYCommentView () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@end

@implementation QYCommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andComInfoArr:(NSArray *)infoArr
{
    self = [super initWithFrame:frame];
    if (self) {
        _comInfo = [NSMutableArray arrayWithArray:infoArr];
        
        //添加键盘事件通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
        [self deploySubViews];
    }
    return self;
}


- (void)layoutSubviews
{
    if (![_comTableView superview]) {
        _comTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height - COMBGV_HEIGHT) style:UITableViewStylePlain];
        _comTableView.delegate = self;
        _comTableView.dataSource = self;
        _comTableView.backgroundColor = [UIColor clearColor];
        [self addSubview:_comTableView];
    }
    UIView *comBGV = [self viewWithTag:COMBGVIEW_TAG];
    
    //登陆状态的判定
    if (_loginState) {
        _commentField.placeholder = @"发表自己的意见吧~";
        _commentField.hidden = NO;
        [comBGV viewWithTag:PUBLISHBTNTAG].hidden = NO;

    }else{
        //未登录状态
        _commentField.hidden = YES;
        [comBGV viewWithTag:PUBLISHBTNTAG].hidden = YES;
        UIButton *loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(_commentField.left + 40, 10, 80, comBGV.height - 20)];
        [loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
        loginBtn.layer.cornerRadius = 5;
        loginBtn.layer.borderWidth = 1;
        loginBtn.layer.borderColor = [UIColor blueColor].CGColor;
        loginBtn.backgroundColor = [UIColor greenColor];
        loginBtn.tag = LOGIN_TAG;
        [loginBtn addTarget:self action:@selector(loginOrRegister:) forControlEvents:UIControlEventTouchUpInside];
        [comBGV addSubview:loginBtn];
        
        UIButton *registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(loginBtn.right + 30, 10, 80, comBGV.height - 20)];
        [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
        registerBtn.layer.cornerRadius = 5;
        registerBtn.layer.borderWidth = 1;
        registerBtn.layer.borderColor = [UIColor blueColor].CGColor;
        registerBtn.backgroundColor = [UIColor greenColor];
        registerBtn.tag = REGISTER_TAG;
        [registerBtn addTarget:self action:@selector(loginOrRegister:) forControlEvents:UIControlEventTouchUpInside];
        [comBGV addSubview:registerBtn];
    }
}

#pragma mark - 
#pragma mark -  初始化时调用方法实现
- (void)deploySubViews
{
    //背景视图
    UIView *bgView = [[UIView alloc]initWithFrame:self.bounds];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.85;
    bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addSubview:bgView];

    //底部UI
    UIView *comBGV = [[UIView alloc]initWithFrame:CGRectMake(0, self.height, self.width, COMBGV_HEIGHT)];
    comBGV.top -= comBGV.height;
    comBGV.backgroundColor = [UIColor whiteColor];
    comBGV.tag = COMBGVIEW_TAG;
    [self addSubview:comBGV];
    
    //返回按钮
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10.5, 27, 27)];
    [backBtn setImage:[UIImage imageNamed:@"内页-返回"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismissViewFromSuperView) forControlEvents:UIControlEventTouchUpInside];
    [comBGV addSubview:backBtn];
    
    //评论框
    _commentField = [[UITextField alloc]initWithFrame:CGRectMake(backBtn.right + 5, 5, 0, comBGV.height - 10)];
    _commentField.width = self.width - _commentField.left - 50;
    _commentField.borderStyle = UITextBorderStyleRoundedRect;
    _commentField.delegate = self;

    //创建并设置发表、回复按钮
    UIButton *publishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [publishBtn setTitle:@"发表" forState:UIControlStateNormal];
    [publishBtn setTitle:@"发表" forState:UIControlStateHighlighted];
    [publishBtn setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    publishBtn.frame = CGRectMake(CGRectGetMaxX(_commentField.frame) + 5, 5, 40, CGRectGetHeight(_commentField.frame));
    [publishBtn addTarget:self.delegate action:@selector(publishContens:) forControlEvents:UIControlEventTouchUpInside];
    publishBtn.tag = PUBLISHBTNTAG;
    [comBGV addSubview:publishBtn];
    [comBGV addSubview:_commentField];
}


- (void)dismissViewFromSuperView
{
    [self removeFromSuperview];
}

//判断是点击登录按钮还是注册按钮
- (void)loginOrRegister:(UIButton *)sender
{
    loginMes state;
    if (sender.tag == LOGIN_TAG) {
        state = doLogin;
    }else{
        state = doRegister;
    }
    if ([self.delegate respondsToSelector:@selector(loginOrRegisterWith:)]) {
        [self.delegate loginOrRegisterWith:state];
    }
}

#pragma mark -
#pragma mark - tableView  dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_comInfo.count != 0) {
        //设置tableView分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return _comInfo.count;
    }else{
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identify = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //移除cell上view，防止复用导致的重复问题
    for (UIView *rview in [cell.contentView subviews]) {
        [rview removeFromSuperview];
    }
    
    //背景视图
    UIView *cellBGV = [[UIView alloc]initWithFrame:cell.contentView.bounds];
    cellBGV.backgroundColor = [UIColor clearColor];
    cellBGV.tag = CELLBGV_TAG + indexPath.row;
    [cell.contentView addSubview:cellBGV];
    
    //头像
    UIImageView *avatarView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 35, 35)];
    avatarView.layer.cornerRadius = avatarView.height/2;
    avatarView.clipsToBounds = YES;
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,[_comInfo[indexPath.row] objectForKey:kAvatarImg]];
    avatarView.imageURL = [NSURL URLWithString:imageUrl];
    [cellBGV addSubview:avatarView];
    
    //用户名字
    UIButton *nameBtn = [[UIButton alloc]initWithFrame:CGRectMake(avatarView.right , 20, 80, 16)];
    [nameBtn setTitleColor:[UIColor colorWithRed:6/255.0 green:219/255.0 blue:136/255.0 alpha:1.0] forState:UIControlStateNormal];
    nameBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    nameBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [nameBtn setTitle:[_comInfo[indexPath.row] objectForKey:kUserName] forState:UIControlStateNormal];
    [nameBtn addTarget:self action:@selector(OnButton:) forControlEvents:UIControlEventTouchUpInside];
    [cellBGV addSubview:nameBtn];
    
    //评论内容
    RTLabel *commentTXT = [[RTLabel alloc]initWithFrame:CGRectMake(nameBtn.left, nameBtn.bottom + 10, cell.contentView.width - avatarView.right - 10 - 10, 0)];
    commentTXT.lineSpacing = LINESPACING;
    commentTXT.text = [_comInfo[indexPath.row] objectForKey:kContentText];
    commentTXT.height = commentTXT.optimumSize.height;
    [cellBGV addSubview:commentTXT];
    
    //评论信息
    RTLabel *commentInfo = [[RTLabel alloc]initWithFrame:CGRectMake(commentTXT.left, commentTXT.bottom + 10, cell.contentView.width - 65, 10)];
    commentInfo.font = [UIFont systemFontOfSize:8.9];
    NSString *text = [NSString stringWithFormat:@"%@  %@赞  %@评论",[QYDateSwith dateSwithWithDate:_comInfo[indexPath.row][kDate]],_comInfo[indexPath.row][kAttitude_count],@"1"];
    commentInfo.text = text;
    [cellBGV addSubview:commentInfo];
    
    //cell的contentView的bounds是固定大小的，需要重新改变cellBGV的高度
    cellBGV.height = commentInfo.bottom + 15;
    
    //回复信息
    CGRect answerFram = commentTXT.frame;
    answerFram.origin.y = CGRectGetMaxY(commentInfo.frame);
    RTLabel *answerInfo = [[RTLabel alloc]initWithFrame:answerFram];
    answerInfo.height = answerInfo.optimumSize.height;
    answerInfo.tag = ANSWERLABLETAG;
    [cellBGV addSubview:answerInfo];
    
    //设置不同行的颜色
    if (indexPath.row == 0) {
        commentTXT.textColor = [UIColor colorWithRed:243/255.0 green:232/255.0 blue:105/255.0 alpha:1.000];
        commentInfo.textColor = [UIColor colorWithRed:243/255.0 green:232/255.0 blue:105/255.0 alpha:1.000];
    }else{
        commentTXT.textColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.000];
        commentInfo.textColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.000];
    }
    
    //点赞和评论按钮
    UIView *cellEditV = [[UIView alloc]initWithFrame:CGRectMake(cellBGV.right, cellBGV.top, 138, cellBGV.height)];
    cellEditV.tag = CELLEDITV_TAG + indexPath.row;
    cellEditV.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.000];
    [cell.contentView addSubview:cellEditV];
    
    UIView *verticalLine = [[UIView alloc]initWithFrame:CGRectMake(0, 5, 0.5, 0)];
    verticalLine.height = cellEditV.height - verticalLine.top*2;
    verticalLine.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    [cellEditV addSubview:verticalLine];
    
    UIButton *supportBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
    supportBtn.left = cellEditV.width/4 - supportBtn.width/2;
    supportBtn.top = (cellEditV.height - supportBtn.height)/2;
    
    //需要判断是否已经点赞,然后选择图片和可否交互
    [supportBtn setBackgroundImage:[UIImage imageNamed:@"内页-点赞"] forState:UIControlStateNormal];
    supportBtn.userInteractionEnabled = YES;
    
    supportBtn.tag = SUPPORT_TAG + indexPath.row;
    [supportBtn addTarget:self action:@selector(supportTheCom:) forControlEvents:UIControlEventTouchUpInside];
    [cellEditV addSubview:supportBtn];
    
    //设置回复按钮
    UIButton *commBtn = [[UIButton alloc]initWithFrame:CGRectMake(cellEditV.width/2 + supportBtn.left, supportBtn.top, supportBtn.width, supportBtn.height)];
    [commBtn setBackgroundImage:[UIImage imageNamed:@"内页-评论"] forState:UIControlStateNormal];
    [commBtn setBackgroundImage:[UIImage imageNamed:@"内页-评论-press"] forState:UIControlStateHighlighted];
    commBtn.tag = COMMBTN_TAG + indexPath.row;
    [commBtn addTarget:self action:@selector(commentTheCom:) forControlEvents:UIControlEventTouchUpInside];
    [cellEditV addSubview:commBtn];
    
    //设置tableView分割线
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,80)];
    [footView addSubview:lineView];
    tableView.tableFooterView = footView;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //创建评论框
    RTLabel *commentTXT = [[RTLabel alloc]initWithFrame:CGRectZero];
    commentTXT.width = tableView.width - 65;
    commentTXT.lineSpacing = LINESPACING;
    commentTXT.text = [_comInfo[indexPath.row] objectForKey:kContentText];
    
    //根据评论、回复内容确定行高
    return 20 + 16 + 10 + commentTXT.optimumSize.height + 10 + 10 + 15;
}


#pragma mark -
#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *bgView = [self viewWithTag:COMBGVIEW_TAG];
    if (bgView.top == (self.height - bgView.height - KEYBOARD_HEIGHT)) {
        [_commentField resignFirstResponder];
        [self viewAnimation:^{
            bgView.top += KEYBOARD_HEIGHT;
            _comTableView.height += KEYBOARD_HEIGHT;
        }];
    }else{
        UIView *cellBGV = [self viewWithTag:CELLBGV_TAG + indexPath.row];
        UIView *cellEditV = [self viewWithTag:CELLEDITV_TAG + indexPath.row];
        [self viewAnimation:^{
            if (cellBGV.left == 0) {
                cellBGV.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.000];
                cellBGV.left -= 36;
                cellEditV.left -= cellEditV.width;
            }else{
                cellBGV.backgroundColor = [UIColor clearColor];
                cellBGV.left = 0;
                cellEditV.left = cellBGV.right;
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self rebackCellViewWithCellBGVTag:CELLBGV_TAG + indexPath.row andCellEditVTAG:CELLEDITV_TAG + indexPath.row];
}

//恢复cell原来的样式
- (void)rebackCellViewWithCellBGVTag:(NSInteger)cellBGVTAG andCellEditVTAG:(NSInteger)CellEditVTAG
{
    UIView *cellBGV = [self viewWithTag:cellBGVTAG];
    UIView *cellEditV = [self viewWithTag:CellEditVTAG];
    [self viewAnimation:^{
        cellBGV.backgroundColor = [UIColor clearColor];
        cellBGV.left = 0;
        cellEditV.left = cellBGV.right;
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width, 44)];
    topLabel.text = @"评论区";
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.textColor = [UIColor whiteColor];
    topLabel.font = [UIFont boldSystemFontOfSize:20];
    return topLabel;
}

//赞评论
- (void)supportTheCom:(UIButton *)sender
{
    UIButton *supBtn = (UIButton *)[self viewWithTag:sender.tag];
    [supBtn setBackgroundImage:[UIImage imageNamed:@"内页-评论-点赞-press"] forState:UIControlStateNormal];
}

//回复评论
- (void)commentTheCom:(UIButton *)sender
{
    [_commentField becomeFirstResponder];
    
    //把发表按钮的字设置为回复
    UIView *view = [self viewWithTag:COMBGVIEW_TAG];
    UIButton *backBtn = (UIButton *)[view viewWithTag:PUBLISHBTNTAG];
    [backBtn setTitle:@"回复" forState:UIControlStateNormal];
    [backBtn setTitle:@"回复" forState:UIControlStateHighlighted];
    [backBtn  setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [backBtn addTarget:self.delegate action:@selector(publishContens:) forControlEvents:UIControlEventTouchUpInside];
    
    [self rebackCellViewWithCellBGVTag:sender.tag - COMMBTN_TAG + CELLBGV_TAG andCellEditVTAG:sender.tag - COMMBTN_TAG + CELLEDITV_TAG];
    _commentField.text = [NSString stringWithFormat:@"@%@:",[_comInfo[sender.tag - COMMBTN_TAG] objectForKey:kUserName]];
}

#pragma mark - 
#pragma mark - UITextfieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIView *bgView = [self viewWithTag:COMBGVIEW_TAG];
    [self viewAnimation:^{
        bgView.top -= KEYBOARD_HEIGHT;
        _comTableView.height -= KEYBOARD_HEIGHT;
    }];
    return YES;
}

//点击键盘return，键盘消失
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self keyboardDismiss];
    [textField resignFirstResponder];
    textField.text = nil;
    return YES;
}

//键盘消失时调整输入框位置
- (void)keyboardDismiss
{
    UIView *bgView = [self viewWithTag:COMBGVIEW_TAG];
    [self viewAnimation:^{
        NSLog(@"self.hegt :%f  bgView.top:%f",self.bounds.size.height,bgView.top);
        if (bgView.top <= (self.bounds.size.height - KEYBOARD__IOS5_HEIGHT) - bgView.height) {
            bgView.top += KEYBOARD__IOS5_HEIGHT;
            _comTableView.height += KEYBOARD__IOS5_HEIGHT;
        }else{
            bgView.top += KEYBOARD_HEIGHT;
            _comTableView.height += KEYBOARD_HEIGHT;
        }
    }];
}


//实现点击用户ID跳转到用户个人信息方法
- (void)OnButton:(UIButton *)sender
{
    [_commentField isFirstResponder] ? (sender.userInteractionEnabled = NO) : (sender.userInteractionEnabled = YES);
    UINavigationController *nav = nil;
    UITabBarController *tabBarCtr = nil;
    QYPersonInformationViewController *setVC = [[QYPersonInformationViewController alloc] init];
    setVC.isOtherUser = YES;
    UINavigationController *newsRootViewController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    //通过应用的代理找到TabBarController，再找到资讯页所在的NavigationController
    //第一次登陆
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"firstLaunch"]) {
        tabBarCtr = newsRootViewController.childViewControllers[2];
        nav = tabBarCtr.viewControllers[0];
    }else{
        //非第一次登陆
        tabBarCtr = newsRootViewController.viewControllers[0];
        nav = tabBarCtr.viewControllers[0];
    }
    [nav pushViewController:setVC animated:YES];
}

//通知调用方法的实现
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat hight = KEYBOARD__IOS5_HEIGHT - KEYBOARD_HEIGHT;
    
    //取出要调整高度的View
    UIView *view = [self viewWithTag:COMBGVIEW_TAG];
    CGFloat newViewTop = self.height - KEYBOARD__IOS5_HEIGHT - view.height;
    
    //通过判断键盘高度就能知道键盘的输入法类型，如果不是中文输入法
    if (kbSize.height == KEYBOARD_HEIGHT)
    {
        if (view.top == newViewTop) {
            view.top += hight;
        }
        
    //如果切换为中文输入法
    }else if(kbSize.height == KEYBOARD__IOS5_HEIGHT){
        view.top -= hight;
        NSString *string = @"UITableView";
        if ([self.subviews[2] isKindOfClass:NSClassFromString(string)]) {
            [self exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
        }
    }
}

//抽取出来的动画方法
- (void)viewAnimation:(void (^)())block
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    block();
    [UIView commitAnimations];
}


//重写dealloc方法，移除通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}
@end
