   //
//  QYDetailPrivateMessageViewController.m
//  Hallyu
//
//  Created by qingyun on 14-9-19.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYDetailPrivateMessageViewController.h"
#import "MJMessage.h"
#import "MJMessageFrame.h"
#import "MJMessageCell.h"
#import "QYEmojiPageView.h"
#import "Emoji.h"
#import "UIImageView+AFNetworking.h"
#import <AVFoundation/AVFoundation.h>

#define InputHeight 48.5
#define ToolBarHeight 30
#define BottomTag 500
#define RecordHeight 51
#define RecordBtnWidth 80
#define RecordBtnHeight 30
#define photoHeight 70

@interface QYDetailPrivateMessageViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, QYEmojPageViewDelegate,AVAudioRecorderDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

{
    UIButton *moreBtn;   //更多按钮
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSDictionary *mainDict;  //请求数据
@property (nonatomic,strong) NSMutableArray *messageFrames;
@property (nonatomic,strong) NSDictionary *autoreply;

@property (nonatomic,strong) UITextField *inPutField;
@property (nonatomic,strong) UIView *Recordview;
@property (nonatomic,strong) UIScrollView *faceScrollView;
@property (nonatomic,strong) UIScrollView *bottomView;
@property (nonatomic,strong) AVAudioRecorder *recorder;
@property (nonatomic,strong) UIButton *avdoButton;
@property (nonatomic,strong) UIButton *loginButton;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) AVAudioPlayer *avPlay;
@property (nonatomic,strong) NSURL *urlPlay;
@property (nonatomic,strong) UIButton *recordBtn;
@property (nonatomic,strong) UIView *photoView;
@property (nonatomic,strong) NSMutableArray *photoArray;
@property (nonatomic,strong) UIButton *sendRedBtn;//发送语音按钮
@property (nonatomic,strong) AVAudioPlayer *aVCellPlay;

@end

@implementation QYDetailPrivateMessageViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    self.navigationController.navigationBarHidden = NO;
    self.userID = [QYUserSingleton sharedUserSingleton].user_id;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)downloadData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if (!_lastDate) {
        return;
    } else {
        NSDictionary *parameters = @{@"user_id": _userID,@"linkman_id":_linkmanID, @"last_date": _lastDate};
        [manager POST:@"" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"json: %@", responseObject);
            self.mainDict = responseObject;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self chatInput];
    
    [self downloadData];
    
//  跳转到最后一行
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.messageFrames.count - 1 inSection:0];
    if (self.messageFrames.count > 2) {
        [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    // navigationItem bar 设置
    UIButton *menu =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [menu setImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    [menu setImage:[UIImage imageNamed:@"返回-press.png"] forState:UIControlStateHighlighted];
    [menu addTarget:self action:@selector(returnLastController:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *menuList =[[UIBarButtonItem alloc]initWithCustomView:menu];
    self.navigationItem.leftBarButtonItem = menuList;
    
    UIButton *deleteBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [deleteBtn setImage:[UIImage imageNamed:@"私信列表-删除.png"] forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageNamed:@"私信列表-删除-press.png"] forState:UIControlStateHighlighted];
    [deleteBtn addTarget:self action:@selector(deleteDetailMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *deleteItem =[[UIBarButtonItem alloc]initWithCustomView:deleteBtn];
    self.navigationItem.rightBarButtonItem = deleteItem;
    
    
     // 1.表格的设置
    // 去除分割线
    self.tableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO; // 不允许选中
    self.tableView.delegate = self;
    
    // 2.监听键盘的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - navigationItem  bar事件
- (void)returnLastController:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteDetailMessage:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"删除与该联系人的聊天记录 " delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

// alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    } else {
        [_messageFrames removeAllObjects];
        [_tableView reloadData];
    }
}

//  移除通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  发送一条消息
 */
- (void)addMessage:(NSString *)text type:(MJMessageType)type
{
    if ([text isEqualToString:@""]) {
        return;
    }
    
    // 1.数据模型
    MJMessage *msg = [[MJMessage alloc] init];
    
    // 设置语音的 URL
    if (self.urlPlay != nil) {
        msg.urlPlay = _urlPlay;
    }
    
    // 设置  图片
    if (self.photoView != nil) {
        UIImageView *image = (UIImageView *)[self.photoView viewWithTag:101];
        msg.image = image.image;
    }
    
    msg.pm_text = text;
    msg.is_receice = type;
    // 设置数据模型的时间
    
    NSDate *now = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm";
    msg.date = [fmt stringFromDate:now];
    
    // 看是否需要隐藏时间
    MJMessageFrame *lastMf = [self.messageFrames lastObject];
    MJMessage *lastMsg = lastMf.message;
    msg.hideTime = [msg.date isEqualToString:lastMsg.date];
    
    // 发私信至服务器
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjects:@[_userID,_linkmanID,text] forKeys:@[@"user_id", @"linkman_id",@"pm_text"]];
    if (msg.image != nil) {
        NSData *imageData = UIImagePNGRepresentation(msg.image);
        NSString *base64Image = [imageData base64Encoding];
        [dic setObject:base64Image forKey:@"pm_image"];
    } else if (msg.urlPlay != nil) {
        // 语音编码
        NSData *soundData = [NSData dataWithContentsOfURL:msg.urlPlay];
        NSString *base64Sound = [soundData base64Encoding];
        [dic setObject:base64Sound forKey:@"pm_sound"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:PERSON_SEND parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [[responseObject objectForKey:@"errors"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"description: %@",[responseObject objectForKey:@"description"] );
        NSLog(@"json: %@", responseObject);
        NSLog(@"str: %@", str);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    // 2.frame模型
    if ([text isEqualToString:@"[图片]"]) {
        text = @" ";
    };
    msg.pm_text = text;
    
    MJMessageFrame *mf = [[MJMessageFrame alloc] init];
    mf.message = msg;
    
    [self.messageFrames addObject:mf];
    
    
    // 3.刷新表格
    [self.tableView reloadData];
    
    // 4.自动滚动表格到最后一行
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.messageFrames.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    _urlPlay = nil;
    
    [self photoIf];
    
}

#pragma mark - 文本框代理
/**
 *  点击了return按钮(键盘最右下角的按钮)就会调用
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    [textField resignFirstResponder];
    return YES;
}

/**
 *  当键盘改变了frame(位置和尺寸)的时候调用
 */
- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    // 设置窗口的颜色
    self.view.window.backgroundColor = self.tableView.backgroundColor;
    
    // 0.取出键盘动画的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 1.取得键盘最后的frame
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 2.计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height;
    
    // 3.执行动画
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, transformY);
    }];
}

// 自动回复的数据加载
- (NSDictionary *)autoreply
{
    if (_autoreply == nil) {
        _autoreply = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"autoreply.plist" ofType:nil]];
    }
    return _autoreply;
}

#pragma mark - 数据源 加载
- (NSMutableArray *)messageFrames
{
    if (_messageFrames == nil) {
        NSArray *dictArray = self.mainDict[@"pm"];
        
        NSMutableArray *mfArray = [NSMutableArray array];
        
        for (NSDictionary *dict in dictArray) {
            // 消息模型
            MJMessage *msg = [MJMessage messageWithDict:dict];
            
            // 取出上一个模型
            MJMessageFrame *lastMf = [mfArray lastObject];
            MJMessage *lastMsg = lastMf.message;
            
            // 判断两个消息的时间是否一致
            msg.hideTime = [msg.date isEqualToString:lastMsg.date];
            
            // 显示的图片
            if (dict[@"pm_image_url"] != nil) {
                UIImageView *imgView = [[UIImageView alloc] init];
                [imgView  setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,[dict objectForKey:@"pm_image_url"]]]];
                msg.image = imgView.image;
            }
            
            // frame模型
            MJMessageFrame *mf = [[MJMessageFrame alloc] init];
            mf.message = msg;
            
            // 添加模型
            [mfArray addObject:mf];
        }
        
        _messageFrames = mfArray;
    }
    return _messageFrames;
}

 #pragma mark - 数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
     return self.messageFrames.count;
 }

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // 1.创建cell
     MJMessageCell *cell = [MJMessageCell cellWithTableView:tableView];
     
     // 2.给cell传递模型
     cell.messageFrame = self.messageFrames[indexPath.row];
     
     NSInteger index = [self indexCellforTableView:tableView IndexPath:indexPath];
     
     cell.textView.tag = index;
     
     [cell.textView addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
     
     // 3.返回cell
     return cell;
 }

- (void)onButtonClick:(UIButton *)sender
{
    MJMessageFrame *message = self.messageFrames[sender.tag];
    if (message.message.urlPlay != nil) {
        AVAudioPlayer *player  =[[AVAudioPlayer alloc]initWithContentsOfURL:message.message.urlPlay error:nil];
        self.aVCellPlay = player;
        [self.aVCellPlay play];
    }
}


// 获取当前cell的index
-(NSInteger)indexCellforTableView:(UITableView *)table IndexPath:(NSIndexPath *)path{
    NSInteger index = 0;
    //获得所在section之的所有cell的count
    for (int i= 0; i< path.section; i++) {
        index += [table numberOfRowsInSection:i];
    }
    index += path.row;
    return index;
}


 
#pragma mark - 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     MJMessageFrame *mf = self.messageFrames[indexPath.row];
     return mf.cellHeight;
}
 
/*
 *  当开始拖拽表格的时候就会调用
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 退出键盘
    [self.view endEditing:YES];
}


#pragma mark - 信息的单条删除

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    // 删除数据
    [self.messageFrames removeObjectAtIndex:indexPath.row];
    
    // UI（界面）上删除该行
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [_tableView reloadData];
        
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - chatInput
- (void)chatInput
{
    //底部容器视图
    
    _bottomView = [[UIScrollView alloc]init];
    
    if (iPhone5) {
        _bottomView.frame = CGRectMake(0, 568 - InputHeight, 320*2, InputHeight);
    } else {
        _bottomView.frame = CGRectMake(0, 480 - InputHeight, 320*2, InputHeight);
    }
    
    _bottomView.contentSize = CGSizeMake(self.view.frame.size.width * 2, InputHeight);
    _bottomView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320*2, InputHeight)];
    bgImageView.image = [UIImage imageNamed:@"chat_bottom_bg"];
    
    [_bottomView addSubview:bgImageView];
    
    _bottomView.showsHorizontalScrollIndicator = NO;
    _bottomView.pagingEnabled = YES;
    _bottomView.bounces = NO;
    //bottomView.scrollEnabled = NO;
    _bottomView.tag = BottomTag;
    [self.view addSubview:_bottomView];
    
    //左侧按钮
    moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(5,5,InputHeight - 10,InputHeight - 10);
    [moreBtn setImage:[UIImage imageNamed:@"发表-添加菜单键"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"发表-添加菜单键-press"] forState:UIControlStateHighlighted];
    [moreBtn addTarget:self action:@selector(moreButton) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:moreBtn];
    
    UIImageView *inputImage = [[UIImageView alloc] initWithFrame:CGRectMake(5 + CGRectGetMaxX(moreBtn.frame), 5, self.view.frame.size.width- 5 - 5 - 45 - CGRectGetMaxX(moreBtn.frame), _bottomView.frame.size.height - 10)];
    inputImage.image = [UIImage imageNamed:@"chat_bottom_textfield"];
    [_bottomView addSubview: inputImage];
    
    
    //输入框
    _inPutField = [[UITextField alloc]initWithFrame:CGRectMake(7 + CGRectGetMaxX(moreBtn.frame), 5, self.view.frame.size.width- 5 - 5 - 45 - CGRectGetMaxX(moreBtn.frame), _bottomView.frame.size.height - 10)];
    _inPutField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inPutField.delegate = self;
    _inPutField.placeholder = @"发表自己的意见吧~";
    [_bottomView addSubview:_inPutField];
    
    //发送按钮
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(CGRectGetMaxX(_inPutField.frame) + 5, _inPutField.frame.origin.y, 40, 38.5);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000] forState:UIControlStateNormal];
    
    [sendBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:sendBtn];
    //返回按钮
    for (int i = 1; i < 5; i++)
    {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(self.view.frame.size.width + 23 + (InputHeight - 10 +40)*(i-1), 5, InputHeight - 10, InputHeight - 10);
        backBtn.tag = BottomTag + i;
        [backBtn addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        //backBtn.backgroundColor = [UIColor redColor];
        [_bottomView addSubview:backBtn];
    }
    UIButton *btn = (UIButton *)[self.view viewWithTag:BottomTag +1];
    [btn setImage:[UIImage imageNamed:@"内页-返回-press"] forState:UIControlStateHighlighted];
    
    [btn setImage:[UIImage imageNamed:@"内页-返回"] forState:UIControlStateNormal];
    btn = (UIButton *)[self.view viewWithTag:BottomTag + 2];
    [btn setImage:[UIImage imageNamed:@"发表-添加菜单-表情-press"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"发表-添加菜单-表情"] forState:UIControlStateNormal];
    
    btn = (UIButton *)[self.view viewWithTag:BottomTag + 3];
    [btn setImage:[UIImage imageNamed:@"发表-添加菜单-语音"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"发表-添加菜单-语音-press"] forState:UIControlStateHighlighted];
    
    btn = (UIButton *)[self.view viewWithTag:BottomTag + 4];
    [btn setImage:[UIImage imageNamed:@"发表-添加菜单-图片"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"发表-添加菜单-图片-press"] forState:UIControlStateHighlighted];
    
}

#pragma mark -
#pragma mark 更多按钮

- (void)moreButton
{
    
    CGRect frame = _bottomView.frame;
    frame.origin.x -= self.view.frame.size.width;
    _bottomView.frame = frame;
    NSLog(@"%@",NSStringFromCGRect(frame));
}
- (void)moreButtonClick:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    switch (tag - BottomTag) {
        case 1:{
            //图片view处理
            [self photoIf];
            
            CGRect frame = _bottomView.frame;
            NSLog(@"%@",NSStringFromCGRect(frame));
            frame.origin.x += self.view.frame.size.width;
            _bottomView.frame = frame;
            if (_faceScrollView != nil) {
                [_faceScrollView removeFromSuperview];
                [_inPutField.inputView removeFromSuperview];
                _faceScrollView = nil;
                _inPutField.inputView = nil;
                [_inPutField resignFirstResponder];
                [_inPutField becomeFirstResponder];
                CGRect frame = _bottomView.frame;
                frame.origin.y += 216;
                _bottomView.frame = frame;
            }
            //去录音view
            [self recordIf];
            
        }
            break;
        case 2:{
            [self expressionItemes:sender];
            [self photoIf];
        }
            break;
        case 3:{
            [self recordingItem:sender];
        }
            break;
        case 4:{
            [self photoItem:sender];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark -
#pragma mark 图片
-(void)photoItem:(UIButton *)sender
{
    [self emojiIf];
    if (_photoView == nil) {
        [self phoToimage:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        self.Recordview.hidden = YES;
        self.bottomView.frame = CGRectMake(0 - self.view.bounds.size.width, self.view.bounds.size.height - photoHeight - self.bottomView.frame.size.height, self.bottomView.frame.size.width, InputHeight);
        NSLog(@"%@",NSStringFromCGRect(self.bottomView.frame));
        self.photoView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-photoHeight, 320, photoHeight)];
        _photoView.backgroundColor = [UIColor lightGrayColor];
         
        UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 20, 70, 35)];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        sendBtn.layer.cornerRadius = 5;
        sendBtn.backgroundColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];
        [sendBtn addTarget:self action:@selector(onSendImageBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        [_photoView addSubview:sendBtn];
        [self.view addSubview:_photoView];
    }else
    {
        self.bottomView.frame = CGRectMake(0 - self.view.bounds.size.width, self.view.bounds.size.height - self.bottomView.frame.size.height, self.bottomView.frame.size.width, InputHeight);
        [_photoView removeFromSuperview];
        _photoView = nil;
    }
    
    
}

// 点击发送图片按钮
- (void)onSendImageBtnClick
{
    [self addMessage:@"[图片]" type:MJMessageTypeMe];
}


- (void)phoToimage:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing  = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
        
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"警告" message:@"不支持照相机。。" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (self.photoArray == nil)
    {
        _photoArray  = [[NSMutableArray alloc]initWithCapacity:20];
        
    }
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5,50,60)];
    imageView.image = image;
    imageView.tag = 101;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.photoView addSubview: imageView];
}
-(void)photoIf
{
    if (_photoView != nil) {
        self.bottomView.frame = CGRectMake(0 - self.view.bounds.size.width, self.view.bounds.size.height - self.bottomView.frame.size.height, self.bottomView.frame.size.width, InputHeight);
        [_photoView removeFromSuperview];
        _photoView = nil;

    }
}

#pragma mark -
#pragma mark 录音
//录音
- (void)recordingItem:(UIButton *)sender
{
    [self photoIf];
    [self.inPutField resignFirstResponder];
    //去掉表情view Bug
    [self.faceScrollView removeFromSuperview];
    self.faceScrollView = nil;
    self.inPutField.inputView = nil;
    [self.inPutField resignFirstResponder];
    
    
    
    if (_Recordview == nil) {
        //重置键盘frame－动画
        CGRect frame = self.bottomView.frame;
        frame = CGRectMake(0-self.view.frame.size.width, self.view.frame.size.height - RecordHeight - self.bottomView.bounds.size.height,frame.size.width,frame.size.height);
        self.bottomView.frame = frame;
        NSLog(@"%@",NSStringFromCGRect(self.bottomView.frame));
        
        
        
        //录音view
        _Recordview = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bottomView.frame), self.view.bounds.size.width, RecordHeight)];
        _Recordview.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_Recordview];
        //录音按钮
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordBtn setTitle:@"按下录音" forState:UIControlStateNormal];
        [_recordBtn setTitle:@"正在录音" forState:UIControlStateHighlighted];
        [_recordBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_recordBtn setTitleColor:[UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000]  forState:UIControlStateHighlighted];
        _recordBtn.frame = CGRectMake((self.view.bounds.size.width - RecordBtnWidth)/2, (_Recordview.frame.size.height -RecordBtnHeight)/2, RecordBtnWidth, RecordBtnHeight);
        _recordBtn.backgroundColor = [UIColor whiteColor];
        _recordBtn.layer.cornerRadius = _recordBtn.frame.size.height/3;
        [_recordBtn addTarget:self action:@selector(AudioRecorder:) forControlEvents:UIControlEventTouchDown];
        [_recordBtn addTarget:self action:@selector(Audoend:) forControlEvents:UIControlEventTouchUpInside];
        [_Recordview addSubview:_recordBtn];
        
    }else{
        CGRect frame = self.bottomView.frame;
        frame = CGRectMake(0-self.view.frame.size.width, self.view.frame.size.height - self.bottomView.bounds.size.height,frame.size.width,frame.size.height);
        self.bottomView.frame = frame;
        [_Recordview removeFromSuperview];
        _Recordview = nil;
    }
}


//实现录音
- (void)AudioRecorder:(UIButton*)sender
{
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数1或2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKeyPath:AVNumberOfChannelsKey];
    //线性采样位数8，16，24，32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKeyPath:AVLinearPCMBitDepthKey];
    //录音质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKeyPath:AVEncoderAudioQualityKey];
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    
    static int a = 1;
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%dlll.aac",strUrl, a]];
    NSLog(@"%@", url);
    a++;
    _urlPlay = url;
    NSError *error;
    //初始化
    _recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    //准备录音
    [self.recorder prepareToRecord];
    if ([self.recorder prepareToRecord])
    {
        //开始录音
        [self.recorder record];
    }

    //录音播放按钮，
    _avdoButton = [[UIButton alloc]initWithFrame:CGRectMake(self.Recordview.bounds.origin.x+100, self.Recordview.bounds.origin.y + 10 , 50, 30)];
    [self.avdoButton.layer setCornerRadius:15];
    _avdoButton.backgroundColor = [UIColor darkGrayColor];
    //重新录音按钮
    _loginButton = [[UIButton alloc]initWithFrame:CGRectMake(self.Recordview.bounds.origin.x+160, self.Recordview.bounds.origin.y + 10, 50, 30)];
    
    [self.loginButton.layer setCornerRadius:15];
    self.loginButton.backgroundColor=[UIColor whiteColor];
    [self.loginButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
//   发送按钮
    _sendRedBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.Recordview.bounds.origin.x+220, self.Recordview.bounds.origin.y+10, 50, 30)];
    self.sendRedBtn.layer.cornerRadius = 15;
    self.sendRedBtn.backgroundColor=[UIColor whiteColor];
    [self.sendRedBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.sendRedBtn setTitleColor:[UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000] forState:UIControlStateNormal];
    
}
- (void)Audoend:(UIButton*)sender
{
    
    if (self.recorder.currentTime>1)
    {
        int a = (int)self.recorder.currentTime ;
        NSString *timer = [NSString stringWithFormat:@"%d s",a];
        [self.avdoButton setTitle:timer forState:UIControlStateNormal];
        [self.loginButton setTitle:@"重录" forState:(UIControlStateNormal)];
        [self.loginButton addTarget:self action:@selector(recording:) forControlEvents:UIControlEventTouchUpInside];
        [self.avdoButton addTarget:self action:@selector(AVplayer:) forControlEvents:UIControlEventTouchUpInside];
        self.recordBtn.hidden = YES;
        
        self.sendRedBtn.tag = a;
        [self.sendRedBtn setTitle:@"发送" forState:UIControlStateNormal];
        
        [self.sendRedBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.Recordview addSubview:_sendRedBtn];
        [self.Recordview addSubview:_avdoButton];
        [self.Recordview addSubview:_loginButton];
    }else
    {
        UIAlertView *avdoAlter = [[UIAlertView alloc]initWithTitle:@"警告" message:@"录音时间太短" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil , nil];
        [avdoAlter show];
    }
    [self.recorder stop];
    
}
//重新录音
- (void)recording:(UIButton*)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"确定" destructiveButtonTitle:@"取消" otherButtonTitles:nil];
    [actionSheet showInView:self.Recordview];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        _recorder = nil;
        [self recordingItem:nil];
    }
}
//播放录音
-(void)AVplayer:(UIButton*)sender
{
    
    if (self.avPlay.playing)
    {
        [self.avPlay stop];
        return;
    }
    AVAudioPlayer *player  =[[AVAudioPlayer alloc]initWithContentsOfURL:self.urlPlay error:nil];
    self.avPlay=player;
    
    [self.avPlay play];
}

#pragma mark-
#pragma mark 表情
//表情
- (void)expressionItemes:(UIButton *)sender
{
    // 隐藏更多按钮
    moreBtn.hidden = YES;
    //去录音view
    [self recordIf];
    [self photoIf];
    if (self.faceScrollView != nil)
    {
        [self.faceScrollView removeFromSuperview];
        self.faceScrollView = nil;
        self.inPutField.inputView = nil;
        [self.inPutField resignFirstResponder];
        [self.inPutField becomeFirstResponder];
        CGRect frame = _bottomView.frame;
        frame.origin.y += 216;
        frame.origin.x = 0;
        _bottomView.frame = frame;
        
    }else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.0001];
        if (_bottomView.frame.origin.y == self.view.bounds.size.height - 216 - _bottomView.frame.size.height) {
            CGRect frame = _bottomView.frame;
            frame.origin.y += 216;
            //frame.origin.x = 0;
            _bottomView.frame = frame;
        }
        [UIView commitAnimations];
        _faceScrollView = [[UIScrollView alloc ] initWithFrame:CGRectMake(0, [[UIScreen mainScreen]bounds].size.height, 320, 216)];
        self.faceScrollView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        self.faceScrollView.pagingEnabled = YES;
        self.faceScrollView.showsHorizontalScrollIndicator = NO;
        self.faceScrollView.showsVerticalScrollIndicator = NO;
        NSUInteger nPageCount = [QYEmojiPageView pageForAllEmoji:35];
        self.faceScrollView.contentSize = CGSizeMake(320*nPageCount, 216);
        
        for (int i = 0;i < nPageCount; i++)
        {
            QYEmojiPageView *fView = [[QYEmojiPageView alloc] initWithFrame:CGRectMake(10+320*i, 15, 320, 170)];
            fView.delegate = self;
            fView.backgroundColor = [UIColor clearColor];
            [fView LoadEmojiItem:i size:CGSizeMake(33, 43)];
            [self.faceScrollView addSubview:fView];
            
        }
        self.inPutField.inputView = self.faceScrollView;
        
        if (_bottomView.frame.origin.x != 0) {
            CGRect frame = _bottomView.frame;
            frame.origin.x = 0;
            _bottomView.frame =frame;
        }
        
        [self.inPutField resignFirstResponder];
        [self.inPutField becomeFirstResponder];
    }
}
//去录音
- (void)recordIf
{
    //去录音view
    if (self.bottomView.frame.origin.y == self.view.frame.size.height - _Recordview.frame.size.height - self.bottomView.frame.size.height) {
        CGRect frame = self.bottomView.frame;
        frame.origin.y = self.view.frame.size.height - self.bottomView.frame.size.height;
        self.bottomView.frame = frame;
        [_Recordview removeFromSuperview];
        _Recordview = nil;
    }
}
//实现表情的代理
- (void)emojiViewDidSelected:(QYEmojiPageView *)emojiView Item:(UIButton *)btnItem
{
    NSMutableString *string =(NSMutableString *)self.inPutField.text;
   // string =(NSMutableString *) [string stringByAppendingString:[btnItem titleForState:UIControlStateNormal]];
    self.inPutField.text =string;
    
}
- (void)emojiIf
{
    if (_faceScrollView != nil) {
        [_faceScrollView removeFromSuperview];
        _faceScrollView = nil;
    }
}

#pragma mark-
#pragma mark 发送
- (void)sendMessage:(UIButton *)sender
{
    if (self.Recordview != nil) {
        
        NSString *message = [NSString stringWithFormat:@"🔊语音: %ld s", self.sendRedBtn.tag];
        
        [self addMessage:message type:MJMessageTypeMe];
        
        [self.Recordview removeFromSuperview];
        self.Recordview = nil;
    } else {
    
        moreBtn.hidden = NO;
    
    // 1.自己发一条消息
    [self addMessage:_inPutField.text type:MJMessageTypeMe];
    }
    
    [self.inPutField resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];

    CGRect frame = _bottomView.frame;
    if (frame.origin.y <= (self.view.frame.size.height - _bottomView.frame.size.height)) {
        frame.origin.y = self.view.frame.size.height - _bottomView.frame.size.height;
    }
    
    _bottomView.frame = frame;
    [UIView commitAnimations];
    NSLog(@"%@",NSStringFromCGRect(_bottomView.frame));
    _inPutField.text = @"";
    if (_faceScrollView != nil) {
        [_faceScrollView removeFromSuperview];
        _faceScrollView = nil;
        _inPutField.inputView = nil;
    }
    [self photoIf];
}




@end





