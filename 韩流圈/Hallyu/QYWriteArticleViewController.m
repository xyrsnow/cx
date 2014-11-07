//
//  QYWriteArticleViewController.m
//  Hallyu
//
//  Created by jiwei on 14-8-10.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYWriteArticleViewController.h"
#import "QYArticleTableViewController.h"
#import "AFNetworking.h"
#import "ZYUsersCheckWriteViewController.h"
#import "QYEmojiPageView.h"
#import "BSImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>


@interface QYWriteArticleViewController ()<UITextViewDelegate,
                                            UINavigationControllerDelegate,
                                            UIImagePickerControllerDelegate,
                                            QYEmojPageViewDelegate,
                                            AVAudioRecorderDelegate,
                                            UIActionSheetDelegate>
@property (nonatomic, weak)   IBOutlet UITextView *titleTextView;
@property (nonatomic, weak)   IBOutlet UITextView *contentTextView;
@property (nonatomic, strong) NSMutableString *cacheTextViewText;
@property (nonatomic, strong) UIToolbar *ToolBar;
@property (nonatomic, strong) UISwipeGestureRecognizer *emojScrollView;
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) AVAudioPlayer *avPlay;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSURL *urlPlay;
@property (nonatomic, strong) UIButton *talkingButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *reTalkingButton;
@property (nonatomic, strong) UIView *Recordview;
@property (nonatomic, strong) UIScrollView *photoView;
@property (nonatomic, assign) NSInteger NumberOfPhoto;
@property (nonatomic, strong) UIView *inputAccess;
@property (nonatomic, strong) UIBarButtonItem *rightItem;
@property (nonatomic, strong) UILabel *collectLable;
@property (nonatomic, strong) NSMutableDictionary *saveAv_Photo_Text;

@end

BOOL isAV  = NO;//标记语音照片是否存在
BOOL isPhoto = NO;

CGRect isAVThere = (CGRect){115, 55, 90, 30};
CGFloat space = 215/2;

//contentTextView
CGFloat textViewX = 5;
CGFloat textViewWidh = 310;
CGFloat textViewYWithAV = 88;
CGFloat textViewYWithoutAV = 51;
CGFloat textViewWithInputViewWithAV = 130;
CGFloat textViewWithInputViewWithoutAV = 170;

//photo
CGFloat photoViewOfHigh = 70;
CGFloat photoOfSpace = 5;
CGFloat photoOfWidth = 50;
CGFloat photoOfHigh = 60;

//AV
CGFloat recordviewX = 0;
CGFloat recordviewHigh = 70;

@implementation QYWriteArticleViewController

// 预览界面传值
-(NSMutableDictionary *)saveAv_Photo_Text
{
    if ( nil == _saveAv_Photo_Text ) {
        self.saveAv_Photo_Text = [NSMutableDictionary dictionary];
    }
    return _saveAv_Photo_Text;
}

- (NSMutableArray *)photoArray
{
    if (!_photoArray) {
        _photoArray = [NSMutableArray array];
    }
    return _photoArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        isAV = NO;
        self.ToolBar.hidden = YES;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.text = @"编辑";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 设置navigationBar颜色样式
    [self setNavigationBar];
    // 设置navigationBar上的按钮
    [self creatBarButtonItem];
    //设置添加toobar
    [self createKeyboardTopBarItems];
    //下滑收回键盘
    self.emojScrollView = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leavedEditMode)];
    self.emojScrollView.direction = UISwipeGestureRecognizerDirectionDown;
    [self.contentTextView addGestureRecognizer:_emojScrollView];
    
    [self.titleTextView becomeFirstResponder];
   
}

//注册通知，关闭键盘，设置toolba
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:self];
    
    [self contentTextViewOfFrame];
}


//使toolBar的位置在键盘上面
- (void)keyBoardWillShow:(NSNotification*)sender
{


    // 显示 / 隐藏 contentTextView.inputAccessoryView
    if ([self.contentTextView isFirstResponder])
    {
        self.contentTextView.inputAccessoryView.hidden = NO;
        
    }else
    {
        self.contentTextView.inputAccessoryView.hidden = YES;
    }
    
    if (isAV)
    {
        //将播放按钮放置文本编辑上方
        self.playButton.frame = isAVThere;
        [self.view addSubview:self.playButton];
        [self.reTalkingButton removeFromSuperview];

        //为了textView的编辑区域不超出可视范围 仅仅在键盘出现的时候
        self.contentTextView.frame = CGRectMake(textViewX, textViewYWithAV, textViewWidh,textViewWithInputViewWithAV);
     
    } else {
     
        self.contentTextView.frame = CGRectMake(textViewX, textViewYWithoutAV, textViewWidh,textViewWithInputViewWithoutAV);
    }
    
}


-(void)keyBoardWillHide:(NSNotification*)sender
{
    [self contentTextViewOfFrame];
}

// 判断内容的frame contentView
- (void)contentTextViewOfFrame
{
    self.Recordview.hidden = YES;
    
    if (!isPhoto)
    {
        self.photoView.hidden = YES;
    }
    
    if (isPhoto)
    {
        if (isAV)
        {
            self.contentTextView.frame = CGRectMake(textViewX, textViewYWithAV, textViewWidh, self.view.bounds.size.height - photoViewOfHigh - textViewYWithAV);
        }else
        {
            self.contentTextView.frame = CGRectMake(textViewX, textViewYWithoutAV, textViewWidh, self.view.bounds.size.height - photoViewOfHigh - textViewYWithoutAV);
        }
    }else
    {
        if (isAV) {
            self.contentTextView.frame = CGRectMake(textViewX, textViewYWithAV, textViewWidh, self.view.bounds.size.height - textViewYWithAV);
        }else
        {
            self.contentTextView.frame = CGRectMake(textViewX, textViewYWithoutAV, textViewWidh, self.view.bounds.size.height - textViewYWithoutAV);
        }
    }
}


// 设置 navogationBar颜色样式 边缘扩展模式 透明
- (void)setNavigationBar
{
    //来解决UINavigationBar透明的问题。设置了UIRectEdgeNone之后，你嵌在UIViewController里面的UITableView和UIScrollView就不会穿过UINavigationBar了
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIColor colorWithRed:200 green:200 blue:200 alpha:1],[UIFont boldSystemFontOfSize:18.0f],[UIColor colorWithWhite:0.0 alpha:1], nil] forKeys:[NSArray arrayWithObjects:UITextAttributeTextColor,UITextAttributeFont,UITextAttributeTextShadowColor, nil]];
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
}


// 设置 navogationBar  BarButtonItem
- (void)creatBarButtonItem
{
    //设置leftBarButtonItem
    UIImage *sureImage = [UIImage imageNamed:@"发表-返回"];
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.bounds= CGRectMake(0, 0, 30, 30);
    [sureButton setImage:sureImage forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sureButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sureButton];
    self.navigationItem.leftBarButtonItem = sureButtonItem;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"background"] forBarMetrics:UIBarMetricsDefault];
    
    //设置rightBarButtonItem
    _rightItem = [[UIBarButtonItem alloc]initWithTitle:@"预览" style:(UIBarButtonItemStylePlain) target:self action:@selector(right:)];
    [_rightItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = _rightItem;
    
    self.titleTextView.tag = 3100;
    self.contentTextView.tag = 3200;
    _titleTextView.delegate = self;
    _contentTextView.delegate = self;
    _contentTextView.returnKeyType = UIReturnKeyNext;
}

//  设置contentTextView.inputAccessoryView （表情、录音、添加图片按钮）
- (void)createKeyboardTopBarItems
{
    //表情
    UIImage *image = [UIImage imageNamed:@"发表-添加菜单-表情-press"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    button.frame = CGRectMake(15, 2, 25, 25);
    [button addTarget:self action:@selector(expressionItemes:) forControlEvents:UIControlEventTouchUpInside];
    
    //图片库按纽
    UIImage *photoImage = [UIImage imageNamed:@"发表-添加菜单-图片-press@2x"];
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton setImage:photoImage forState:UIControlStateNormal];
    photoButton.frame = CGRectMake(CGRectGetMaxX(button.frame) + space, 2, 25, 25);
    [photoButton addTarget:self action:@selector(photoItem:) forControlEvents:UIControlEventTouchUpInside];
    
    //录音
    UIImage *recordImage = [UIImage imageNamed:@"发表-添加菜单-语音-press"];
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordButton setImage:recordImage forState:UIControlStateNormal];
    recordButton.frame = CGRectMake(CGRectGetMaxX(photoButton.frame) + space, 2, 25, 25);
    [recordButton addTarget:self action:@selector(recordingItem:) forControlEvents:UIControlEventTouchUpInside];
    
    //自定义inputAccess
    self.inputAccess = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [self.inputAccess addSubview:button];
    [self.inputAccess addSubview:photoButton];
    [self.inputAccess addSubview:recordButton];
    self.contentTextView.inputAccessoryView = self.inputAccess;
    self.contentTextView.inputAccessoryView.backgroundColor = [UIColor grayColor];
    self.contentTextView.inputAccessoryView.alpha = 0.2;
}


//左上角 返回按钮
- (void)back:(UIBarButtonItem*)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


//右上角item  完成编辑/预览
- (void)right:(UIBarButtonItem*)sender
{
    NSString *stringOfcontentView = _contentTextView.text ;
    NSString *stringOftitleTextView = _titleTextView.text;
    NSString *regex = @"^\\s*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self MATCHES %@",regex];
    if ([predicate evaluateWithObject:stringOfcontentView]
        ||[predicate evaluateWithObject:stringOftitleTextView]
        || [_contentTextView.text isEqualToString:@"正文"]
        || [_titleTextView.text isEqualToString:@"您还没有写标题!"])
    {
        [self creatCollectLable];
        _collectLable.text = @"标题或内容不能为空";
        _collectLable.adjustsFontSizeToFitWidth = YES;
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

        return;
    }
   
    
    ZYUsersCheckWriteViewController *userCheck = [[ZYUsersCheckWriteViewController alloc] init];
    // 将图片录音还有文字转至检查页面
    [self.saveAv_Photo_Text setObject:self.titleTextView.text forKey:@"titleTextView_text"];
    [self.saveAv_Photo_Text setObject:self.contentTextView.text forKey:@"contentTextView_text"];
    if (nil != self.photoArray) [self.saveAv_Photo_Text setObject:self.photoArray forKey:@"photo_Array"];
    if (nil != _urlPlay) [self.saveAv_Photo_Text setObject:_urlPlay forKey:@"urlPlay"];
    userCheck.av_photoArray_Title_Content = self.saveAv_Photo_Text;
    [self.navigationController pushViewController:userCheck animated:YES];
}


// 提醒框 当没有文字输入时显示
- (void)creatCollectLable
{
    _collectLable = [[UILabel alloc] initWithFrame:CGRectMake(90, 200, 140, 80)];
    _collectLable.layer.cornerRadius = 10.0f;
    _collectLable.clipsToBounds = YES;
    _collectLable.backgroundColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];
    _collectLable.tag = 1113;
    
}


#pragma mark -
#pragma mark TextView Delegate
//textView的代理方法，开始编辑textView的时候执行的操作
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    //如果是标题栏 那么toolBar隐藏
    //如果是内容栏 那么toolBar显示
    if (((textView.tag == 3100) && [textView.text isEqualToString:@"您还没有写标题!"]) )
    {
        textView.text = @"";
    }else if (((textView.tag == 3200) && [textView.text isEqualToString:@"正文"] ))
    {
         textView.text = @"";
    }
    
    // toolBar是否要出现
    if ([self.contentTextView isFirstResponder])
    {
        self.contentTextView.inputAccessoryView.hidden = NO;
    }else
    {
        self.contentTextView.inputAccessoryView.hidden = YES;
    }
    return YES;

}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(leavedEditMode)];
    self.navigationItem.rightBarButtonItem = done;
    [done setTintColor:[UIColor yellowColor]];
}



- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    // 模仿placeholder
    if ((textView.tag == 3100 && textView.text.length == 0))
    {
        textView.text = @"您还没有写标题!";
        
    }else if ((textView.tag == 3200) && textView.text.length == 0)
    {
        textView.text = @"正文";
    }

    if (isPhoto) {
        self.Recordview.hidden = YES;
        self.photoView.hidden = NO;
    }
    
    //完成编辑后 显示“预览”
    self.navigationItem.rightBarButtonItem = self.rightItem;
    return YES;
}


#pragma mark -
#pragma mark Action
//全部编辑控件失去第一响应
- (void)leavedEditMode
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark 表情
//表情
- (void)expressionItemes:(UIButton *)sender
{

    if (self.scrollView != nil)
    {
        [self.scrollView removeFromSuperview];
         self.scrollView = nil;
         self.contentTextView.inputView = nil;
        [self.contentTextView resignFirstResponder];// 去除当前自定义键盘
        [self.contentTextView becomeFirstResponder];// 为了让自带键盘再次弹出来
    }else
    {
        _scrollView = [[UIScrollView alloc ] initWithFrame:CGRectMake(0, [[UIScreen mainScreen]bounds].size.height-216, 320, 216)]; 
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        NSUInteger nPageCount = [QYEmojiPageView pageForAllEmoji:35];
        self.scrollView.contentSize = CGSizeMake(320*nPageCount, 216);
        
        for (int i = 0;i < nPageCount; i++)
        {
            QYEmojiPageView *fView = [[QYEmojiPageView alloc] initWithFrame:CGRectMake(10+320*i, 15, 320, 216)];
            fView.delegate = self;
            fView.backgroundColor = [UIColor whiteColor];
            [fView LoadEmojiItem:i size:CGSizeMake(33, 43)];
            [self.scrollView addSubview:fView];
            
        }
        self.contentTextView.inputView = self.scrollView;
        [self.contentTextView resignFirstResponder];// 去除系统键盘
        [self.contentTextView becomeFirstResponder];// 弹出自定义键盘
    }


}


//表情代理
- (void)emojiViewDidSelected:(QYEmojiPageView *)emojiView Item:(UIButton *)btnItem
{
    NSMutableString *string =(NSMutableString *)self.contentTextView.text;
    string =(NSMutableString *) [string stringByAppendingString:[btnItem titleForState:UIControlStateNormal]];
    self.contentTextView.text =string;
}

// 代理,删除表情
-(void)selectedFacialView:(NSString *)str
{
//    NSString *newStr;
    if ([str isEqualToString:@"删除"])
    {
        if (self.contentTextView.text.length>0)
        {
            _contentTextView.text =[_contentTextView.text substringToIndex:_contentTextView.text.length-1];
        }
   
    }
}


#pragma mark -
#pragma mark 录音
// 点击assisiveView上的录音按键  录音
- (void)recordingItem:(UIButton *)sender
{
    // 每次点击这个按钮都会初始化语音
    self.playButton.hidden = YES;
    _urlPlay = nil;
    isAV = NO;

    [UIView animateWithDuration:.25f animations:^{
         [self contentTextViewOfFrame];
    }];
    [self.contentTextView resignFirstResponder];
    
    // 设置录音栏
    self.Recordview = [[UIView alloc]initWithFrame:CGRectMake(recordviewX, self.view.frame.size.height - recordviewHigh, CGRectGetWidth(self.view.frame), recordviewHigh)];
    self.Recordview.alpha = 0.8;
    self.Recordview.backgroundColor = [UIColor grayColor];
    
    // 设置录音按钮
    self.talkingButton = [[UIButton alloc]initWithFrame:CGRectMake(self.Recordview.bounds.origin.x+100, self.Recordview.bounds.origin.y + 20 , 120, 30)];
    self.talkingButton.backgroundColor = [UIColor brownColor];
    self.talkingButton.imageEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 80);
    self.talkingButton.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 0);
    self.talkingButton.layer.cornerRadius = 9;
    self.talkingButton.titleLabel.font = [UIFont systemFontOfSize:18];
    self.talkingButton.layer.borderWidth = .5f;
    self.talkingButton.layer.borderColor = [UIColor greenColor].CGColor;
    [self.talkingButton setImage:[UIImage imageNamed:@"发表-添加菜单-语音-press"] forState:UIControlStateNormal];
    [self.talkingButton setImage:[UIImage imageNamed:@"发表-添加菜单-语音"] forState:UIControlStateHighlighted];
    [self.talkingButton setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.talkingButton setTitle:@"正在录音" forState:UIControlStateHighlighted];
    [self.talkingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.talkingButton addTarget:self action:@selector(AudioRecorder:) forControlEvents:UIControlEventTouchDown];
    [self.talkingButton addTarget:self action:@selector(Audoend:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_Recordview];
    [_Recordview addSubview:_talkingButton];
}



//实现录音
- (void)AudioRecorder:(UIButton*)sender
{
    // 再次点击的时候播放按钮隐藏 代表删去 展现出录音按钮
    self.playButton.hidden = YES;

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
    
    NSArray *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@lll.aac",strUrl]];
    _urlPlay = url;
    NSError *error = nil;
    
    //初始化
    _recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    if (error != nil) {
        NSLog(@"instance recorder error.%@",error);
    }
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    
    //准备录音
    if ([self.recorder prepareToRecord])
    {
        //开始录音
        [self.recorder record];
        isAV = YES;
    }
   
    //重新录音按钮
    _reTalkingButton = [[UIButton alloc] initWithFrame:CGRectMake(self.Recordview.bounds.origin.x+210, self.Recordview.bounds.origin.y+20, 35, 30)];
    [self.reTalkingButton.layer setCornerRadius:15];
    self.reTalkingButton.backgroundColor=[UIColor redColor];
    [self.reTalkingButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.reTalkingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //录音播放按钮，
    _playButton = [[UIButton alloc]initWithFrame:CGRectMake(self.Recordview.bounds.origin.x+115, self.Recordview.bounds.origin.y+20,90, 30)];
    [self.playButton.layer setCornerRadius:15];
    
    _playButton.backgroundColor = [UIColor brownColor];
    _playButton.imageEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 60);
    _playButton.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 10);
    _playButton.layer.cornerRadius = 9;
    [_playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"发表-添加菜单-语音-press"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"发表-添加菜单-语音"] forState:UIControlStateHighlighted];
    _playButton.layer.borderWidth = .5f;
    _playButton.layer.borderColor = [UIColor greenColor].CGColor;
    _playButton.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    
}

// 录音按钮抬起
- (void)Audoend:(UIButton *)sender
{
    if (self.recorder.currentTime > 1.5)
    {
        AVAudioPlayer *player  =[[AVAudioPlayer alloc]initWithContentsOfURL:_urlPlay error:nil];
        NSString *timer = [NSString stringWithFormat:@"%0.f s",player.duration];
        [self.playButton setTitle:timer forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(AVplayer:) forControlEvents:UIControlEventTouchUpInside];
         [self.Recordview addSubview:_playButton];
        
        // 设置重录按钮
        [self.reTalkingButton setTitle:@"重录" forState:(UIControlStateNormal)];
        [self.reTalkingButton addTarget:self action:@selector(recording:) forControlEvents:UIControlEventTouchUpInside];
        [self.Recordview addSubview:_reTalkingButton];
        
        //将录音按钮（button）从父试图移出，显示播放按钮，
        self.talkingButton.hidden = YES;
       
   
    }else
    {
        UIAlertView *avdoAlter = [[UIAlertView alloc]initWithTitle:@"警告" message:@"录音时间太短" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil , nil];
        [avdoAlter show];
        isAV = NO;
    }
    
    [self.recorder stop];
}


//重新录音
- (void)recording:(UIButton*)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"确定" destructiveButtonTitle:@"取消" otherButtonTitles:nil];
    [actionSheet showInView:self.Recordview];
}


//actionSheet的代理方法，实现是否删除录音功能
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            break;
        case 1:
        {
            int a = (int)self.recorder.currentTime ;
            //NSNumber *number = [NSNumber numberWithFloat:a];
            NSString *timer = [NSString stringWithFormat:@"%d s",a];
            [self.playButton setTitle:timer forState:UIControlStateNormal];
            [self.recorder deleteRecording];
            [self.recorder stop];
            self.talkingButton.hidden = NO;
            self.playButton.hidden = YES;
            self.reTalkingButton.hidden = YES;
            
            isAV = NO;
        }
            break;
        default:
            break;
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
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:_urlPlay error:nil];
    self.avPlay = player;
    [self.avPlay play];
}


#pragma mark -
#pragma mark 图片
//图片
-(void)photoItem:(UIButton *)sender
{
    BSImagePickerController *bsImagePicker = [[BSImagePickerController alloc] init];
    
    [self presentImagePickerController:bsImagePicker
                              animated:YES
                            completion:nil
                                toggle:nil
                                cancel:^(NSArray *assets) {
        [bsImagePicker dismissViewControllerAnimated:YES completion:nil];
    }
                                finish:^(NSArray *assets)
    {
        
        [bsImagePicker dismissViewControllerAnimated:YES completion:nil];
        
        isPhoto = YES;
        self.NumberOfPhoto =  self.NumberOfPhoto + assets.count;
        
        for (ALAsset *ala in assets) {
               ALAssetRepresentation *alaRe =  [ala defaultRepresentation];
            CGImageRef cgImage = [alaRe fullResolutionImage];
            UIImage *image = [UIImage imageWithCGImage:cgImage];
            [self.photoArray addObject:image];
        }
        
        //设置照片栏
        [self makePhotoView];

    }];
    
}

//  设置招照片栏
- (void)makePhotoView
{
    self.Recordview.hidden = YES;
    [self contentTextViewOfFrame];

    if (nil == self.photoView)
    {
        self.photoView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height -70, 320, 70)];
        self.photoView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:self.photoView];
    }
    
    self.photoView.contentSize = CGSizeMake(photoOfSpace + (photoOfWidth+photoOfSpace)*self.NumberOfPhoto + photoOfWidth , photoOfHigh);
    self.photoView.hidden = NO;

    //    给照片栏添加手势 以便删除照片
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deletPhoto:)];
    swip.direction = UISwipeGestureRecognizerDirectionUp;
    [self.photoView addGestureRecognizer:swip];
    
    
    for (int i = 0; i < self.NumberOfPhoto ; i++) {
        [self addImage:self.photoArray[i] withIndex:i];
    }
    
}

// 向照片栏中添加照片
- (void)addImage:(UIImage *)image withIndex:(int)index
{
    if (self.photoArray == nil)
    {
        _photoArray  = [[NSMutableArray alloc]initWithCapacity:20];
        
    }
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(photoOfSpace + (photoOfWidth+photoOfSpace)*index ,photoOfSpace,photoOfWidth,photoOfHigh)];
    imageView.image = image;
    [self.photoView addSubview: imageView];

}

// 删除照片
- (void)deletPhoto:(UISwipeGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.photoView];
    int index = point.x/(photoOfSpace + photoOfWidth);
    if (self.photoArray.count) {
        UIImage *image = self.photoArray[index];
        [self.photoArray removeObject:image];
        NSLog(@"%d",index);
    }
   
    // 删除photo上的子视图 因为photoView。subviews在伤处照片时是动态的 所以找一个中间变凉以便取出所有的子视图 并删除
    NSMutableArray *arr = [NSMutableArray array];
    for (UIImageView *imageView in self.photoView.subviews) {
        [arr addObject:imageView];
    }
    
    for (int index = 0; index < arr.count; index ++) {
        UIImageView *imageView = arr[index];
        [imageView removeFromSuperview];
    }
    
    // 重新放置照片
    for (int i = 0; i < self.photoArray.count; i ++) {
        UIImage *image = self.photoArray[i];
        [self addImage:image withIndex:i];
    }
  
    _NumberOfPhoto--;
    if (_NumberOfPhoto < 0
        || _NumberOfPhoto == 0) {
            _NumberOfPhoto = 0;
        isPhoto = NO;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect rect = self.photoView.frame;
            rect.origin.y += 70;
            self.photoView.frame = rect;
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 重新判断contentView.frame
            [self contentTextViewOfFrame];
            CGRect rect = self.photoView.frame;
            rect.origin.y -= 70;
            self.photoView.frame = rect;
            
        });
    

    }
}

@end


