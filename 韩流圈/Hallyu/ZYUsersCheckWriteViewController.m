//
//  ZYUsersCheckWriteViewController.m
//  Hallyu
//
//  Created by Zhang's on 14-9-24.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "ZYUsersCheckWriteViewController.h"
#import "RTLabel.h"
#import "UIViewExt.h"
#import "AsyncImageView.h"
#import "QYLoginViewController.h"

#define kTitleTextView_text @"titleTextView_text"
#define kContentTextView_text @"contentTextView_text"
#define kPhoto_Array @"photo_Array"
#define kURLPlay @"urlPlay"


@interface ZYUsersCheckWriteViewController ()

@property (nonatomic, strong) UIScrollView *viewOfScrollView;

@end

@implementation ZYUsersCheckWriteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.avPlayTest =[[AVAudioPlayer alloc] init];
        self.av_photoArray_Title_Content = [NSMutableDictionary dictionary];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.text = @"预览";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewOfScrollView = [[UIScrollView alloc] init];
    self.viewOfScrollView.frame = self.view.bounds;
    [self.view addSubview:self.viewOfScrollView];
    [self creatHeadView];
    [self setBarButton];
    
}

- (void)setBarButton
{
    //右按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(sendBtn)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor yellowColor];
    //作按钮
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"background"] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(backToedit:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor yellowColor];
}
#pragma mark -
#pragma mark Custom Method
- (void)creatHeadView
{
    
    //标题
    RTLabel *postTitle = [[RTLabel alloc]initWithFrame:CGRectMake(10, 20, 300, 0)];
    NSString *title_text = [self.av_photoArray_Title_Content objectForKey:kTitleTextView_text] ;
    NSString *title = [@"标题: \r" stringByAppendingString:title_text];
    [postTitle setText:title];
    postTitle.font = [UIFont systemFontOfSize:17.0f];
    postTitle.height = postTitle.optimumSize.height;
    [self.viewOfScrollView addSubview:postTitle];
    
    //创建时间
    RTLabel *creat_at = [[RTLabel alloc] initWithFrame:CGRectMake(10, postTitle.bottom+5, 0, 0)];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    int year = [comps year];
    int month = [comps month];
    int day = [comps day];
    int hour = [comps hour];
    int min = [comps minute];
    
    [creat_at setText:[NSString stringWithFormat:@"%d-%d-%d  %d:%d",year,month,day,hour,min]
     ];
    creat_at.font = [UIFont boldSystemFontOfSize:10.0f];
    creat_at.width = creat_at.optimumSize.width;
    creat_at.height = creat_at.optimumSize.height;
    creat_at.textColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:0.5];
    [self.viewOfScrollView addSubview:creat_at];
    
    //浏览数
    RTLabel *broweLable = [[RTLabel alloc] initWithFrame:CGRectMake(creat_at.right + 10, creat_at.top, 0, 0)];
    [broweLable setText:[@"0" stringByAppendingString:@"浏览"]];
    broweLable.font = [UIFont systemFontOfSize: 10.0f];
    broweLable.textColor =  [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    broweLable.width = broweLable.optimumSize.width;
    broweLable.height = broweLable.optimumSize.height;
    [self.viewOfScrollView addSubview:broweLable];
    
    //赞
    RTLabel *attitudeLable = [[RTLabel alloc] initWithFrame:CGRectMake(broweLable.right + 10, broweLable.top, 0, 0)];
    [attitudeLable setText:[@"0" stringByAppendingString:@"赞"]];
    attitudeLable.font = [UIFont systemFontOfSize:10.0f];
    attitudeLable.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    attitudeLable.width = attitudeLable.optimumSize.width;
    attitudeLable.height = attitudeLable.optimumSize.height;
    [self.viewOfScrollView addSubview:attitudeLable];
    
    //评论
    RTLabel *comments = [[RTLabel alloc] initWithFrame:CGRectMake(attitudeLable.right + 10, broweLable.top, 0, 0)];
    [comments setText:[@"0" stringByAppendingString:@"评论"]];
    comments.font = [UIFont systemFontOfSize:10.0f];
    comments.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    comments.width = comments.optimumSize.width;
    comments.height = comments.optimumSize.height;
    [self.viewOfScrollView addSubview:comments];
    
    //收藏
    RTLabel *favorites = [[RTLabel alloc] initWithFrame:CGRectMake(comments.right + 10, broweLable.top, 0, 0)];
    [favorites setText:[@"10" stringByAppendingString:@"评论"]];
    favorites.font = [UIFont systemFontOfSize:10.0f];
    favorites.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    favorites.width = favorites.optimumSize.width;
    favorites.height = favorites.optimumSize.height;
    [self.viewOfScrollView addSubview:favorites];
    
    //帖子图
    NSArray *photoArry = [self.av_photoArray_Title_Content objectForKey:kPhoto_Array];
    UIScrollView *postImage = [[UIScrollView alloc]initWithFrame:CGRectMake(10, favorites.bottom+10, 300, 230)];
    if (0 == photoArry.count) {
        postImage.frame = CGRectMake(50, favorites.bottom+10,0, 0);
    }else
    {

       NSInteger p = photoArry.count;
        postImage.contentSize = CGSizeMake(postImage.frame.size.width*p, postImage.frame.size.height);
        postImage.pagingEnabled = YES;
        postImage.showsHorizontalScrollIndicator = YES;
        postImage.showsVerticalScrollIndicator = YES;
        postImage.backgroundColor = [UIColor lightTextColor];
        int numberOfphoto = 0;
        for (UIImage *image in photoArry)
            {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(postImage.frame.size.width * numberOfphoto, 0, postImage.frame.size.width, postImage.frame.size.height);
            imageView.contentMode =  UIViewContentModeScaleAspectFit;
            [postImage addSubview:imageView];
            numberOfphoto++;
            }
    }
    [self.viewOfScrollView addSubview:postImage];
    
    //  设置录音按钮位置
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.avPlayTest = [[AVAudioPlayer alloc]initWithContentsOfURL:[self.av_photoArray_Title_Content objectForKey:kURLPlay] error:nil];
    btn.frame = CGRectMake(5, postImage.bottom + 5, 50*(self.avPlayTest.duration/10 +1), 20);
    btn.layer.cornerRadius = 10;
    btn.layer.masksToBounds = YES;
    [self.viewOfScrollView addSubview:btn];

    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"发表-添加菜单-语音-press"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"发表-添加菜单-语音"] forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor brownColor];
    btn.imageEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 40);
    btn.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 0);
    btn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold"size:14.5f];
    [btn addTarget:self action:@selector(playAV) forControlEvents:UIControlEventTouchUpInside];
    NSString *AVTime = [NSString stringWithFormat:@"%0.fS",self.avPlayTest.duration];
    [btn setTitle:AVTime forState:UIControlStateNormal];
    NSLog(@"录音 时长 %f",self.avPlayTest.duration);
    if (self.avPlayTest.duration < 1) {
        btn.hidden = YES;
        btn.frame = CGRectMake(5, postImage.bottom + 5, 60*(self.avPlayTest.duration/10 +1), 0);
    }

    //帖子正文
    RTLabel *postText = [[RTLabel alloc]initWithFrame:CGRectMake(10, btn.bottom + 15, 300, 0)];
    [self.viewOfScrollView addSubview:postText];
    NSString *content_text = [self.av_photoArray_Title_Content objectForKey:kContentTextView_text];
    NSString *content = [@"正文: \r       " stringByAppendingString:content_text];
    [postText setText:content];
    postText.font = [UIFont systemFontOfSize:14.0f];
    postText.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    postText.height = postText.optimumSize.height;

    
    // 下滑线1
    UIView *diviLine1 = [[UIView alloc]initWithFrame:CGRectMake(10, postText.bottom+10, 300, 1)];
    diviLine1.backgroundColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.0f];
    [self.viewOfScrollView addSubview:diviLine1];
    
    // 下划线中间区域
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, diviLine1.bottom, 300, 10)];
    view.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0f];
    [self.viewOfScrollView addSubview:view];
    
    // 下划线2
    UIView *diviLine2 = [[UIView alloc]initWithFrame:CGRectMake(10, view.bottom, 300, 1)];
    diviLine2.backgroundColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.0f];
    [self.viewOfScrollView addSubview:diviLine2];
    

    // 根据heardView设定整个页面的ScrollView的内值
    self.viewOfScrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(diviLine2.frame) + 100);

}

//发布按钮
- (void)sendBtn
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //语音加密
    NSData *data = [NSData dataWithContentsOfURL:[self.av_photoArray_Title_Content objectForKey:kURLPlay]];
    NSString *base64sound = [data base64Encoding];
    
    //图片加密
    UIImage *image = [UIImage imageNamed:@"返回-press"];
    NSData *imagedate = UIImagePNGRepresentation(image);
    NSString *base64image = [imagedate base64Encoding];

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"userid":[QYUserSingleton sharedUserSingleton].user_id ,
                                                                                        @"title":[self.av_photoArray_Title_Content objectForKey:kTitleTextView_text],
                                                                                        @"content":[self.av_photoArray_Title_Content objectForKey:kContentTextView_text]}];
    
    if (nil != base64sound) {
        
        [parameters setObject:base64sound forKey:@"sound"];
        
    }else if (nil != base64image)
    {
        [parameters setObject:base64image forKey:@"image"];
    }
    
    [manager POST:BBS_WRITE parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"发表提帖子的返回字符串 JSON: %@", responseObject);
        NSLog(@"发表提帖子的返回字 operation %@",operation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"发表提帖子的 Error: %@", error);
        
    }];
}

- (void)playAV
{
    NSLog(@"播放");
    [self.avPlayTest play];
}

- (void)backToedit:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
