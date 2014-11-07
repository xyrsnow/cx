//
//  QYAnswerTableViewCell.m
//  Hallyu
//
//  Created by qingyun on 14-8-11.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYAnswerTableViewCell.h"
#import "RTLabel.h"
#import "UIViewExt.h"

@interface QYAnswerTableViewCell()
@property (retain, nonatomic) UIImageView *avatarImage;
@property (retain, nonatomic) RTLabel *userName1;
@property (retain, nonatomic) RTLabel *creatAt;
@property (retain, nonatomic) RTLabel *answerArticl;
@property (retain, nonatomic) RTLabel *floor;
@property (retain, nonatomic) RTLabel *attitude;
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (strong, nonatomic) NSDictionary *userInfo;
@end

#define contentScrollViewContenSize 40.0

#define kUserName       @"usr_name"
#define kUserID         @"usr_id"
#define kFloor          @"floor_num"
#define kContent        @"content_text"
#define kDate           @"date"
#define kAttitudeCount  @"attitude_count"

@implementation QYAnswerTableViewCell


+(float)cellHeight:(NSDictionary *)data{
    NSString *str = @"sflasfl sdfls asdfalsdfj asdfalsdj fsafdas sdflasd.";
    CGSize rect = [str sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(50, 100) lineBreakMode:NSLineBreakByCharWrapping];
    NSLog(@"%@",NSStringFromCGSize(rect));
    
    return .0f;
}


-(CGFloat)highOfCell
{
    return _highOfCell;
}


-(void)setCellData:(NSDictionary *)cellData
{
    _cellData = cellData;
    [self layoutSubviews];
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        // 在cell.contentView上添加scrollView  在scerll上添加各个控件
        self.contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.backgroundColor = [UIColor clearColor];
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.bounces = NO;
        [_contentScrollView setContentOffset:CGPointZero animated:NO];
        [self.contentView addSubview:_contentScrollView];
        
        // 添加收藏按钮
        _btnOfCollect = [[ZYButton alloc] initWithFrame:CGRectZero];
        _btnOfCollect = [ZYButton buttonWithType:UIButtonTypeCustom];
        _btnOfCollect.backgroundColor = [UIColor grayColor];
        [_btnOfCollect setImage:[UIImage imageNamed:@"内页-评论-点赞"] forState:UIControlStateNormal];
        [_btnOfCollect setImage:[UIImage imageNamed:@"内页-评论-点赞-press"] forState:UIControlStateHighlighted];
        [_contentScrollView addSubview:_btnOfCollect];
        
        // 添加回复按钮
        _btnOfChat = [ZYButton buttonWithType:UIButtonTypeCustom];
        _btnOfChat.backgroundColor = [UIColor grayColor];
        [_btnOfChat setImage:[UIImage imageNamed:@"内页-评论-press"] forState:UIControlStateHighlighted];
        [_btnOfChat setImage:[UIImage imageNamed:@"内页-评论"] forState:UIControlStateNormal];
        [_contentScrollView addSubview:_btnOfChat];

        //用户头像
        self.avatarImage = [[UIImageView alloc ]initWithFrame:CGRectMake(10, 10, 30, 30)];
        self.avatarImage.userInteractionEnabled = YES;
        [_contentScrollView addSubview:self.avatarImage];
        
        // 添加手势,跳转到个人信息
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tap.numberOfTapsRequired = 1;
        [self.avatarImage addGestureRecognizer:tap];
        
        //用户名
        self.userName1 = [[RTLabel alloc]initWithFrame: CGRectMake(self.avatarImage.right + 10, 10, 0, 0)];
        self.userName1.textColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:0.5];
        self.userName1.font = [UIFont systemFontOfSize:14.0f];
        [_contentScrollView addSubview:self.userName1];
        self.shenglue = [[UIButton alloc]initWithFrame:CGRectMake(320-40, self.avatarImage.top, 15, 15)];
        [_contentScrollView addSubview:self.shenglue];
        
        //回帖
        self.answerArticl = [[RTLabel alloc]initWithFrame:CGRectMake(self.avatarImage.right+10, self.userName1.bottom+10, 260, 0)];
        self.answerArticl.font = [UIFont systemFontOfSize:16.0f];
        [_contentScrollView addSubview:self.answerArticl];
        
        //创建时间
        self.creatAt = [[RTLabel alloc]initWithFrame:CGRectMake(self.avatarImage.right +10,self.answerArticl.bottom +10, 0, 0)];
        self.creatAt.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        self.creatAt.font = [UIFont systemFontOfSize:10.f];
        [_contentScrollView addSubview:self.creatAt];
        
        //楼层
        self.floor = [[RTLabel alloc]initWithFrame:CGRectMake(self.creatAt.right + 10, 0, 0, 0)];
        self.floor.font = [UIFont systemFontOfSize:10.0f];
        self.floor.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [_contentScrollView addSubview:self.floor];
        
        //赞数
        self.attitude = [[RTLabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        self.attitude.font = [UIFont systemFontOfSize:10.f];
        self.attitude.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [_contentScrollView addSubview:self.attitude];
    }
    
    return self;
}


#pragma mark - action
- (void)tap:(UITapGestureRecognizer *)gesture
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"answerTap" object:nil ];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    _userInfo = self.cellData;

    self.avatarImage.image = [UIImage imageNamed:@"taitanxiami.jpg"];
    self.avatarImage.layer.cornerRadius = 15.0f;
    self.avatarImage.layer.masksToBounds = YES;
    
    self.contentScrollView.frame = self.bounds;
    self.contentScrollView.contentSize = CGSizeMake(self.bounds.size.width + 2*contentScrollViewContenSize  , self.bounds.size.height);
    [self.contentScrollView setContentOffset:CGPointZero animated:YES];
    _btnOfCollect.frame = CGRectMake(self.bounds.size.width, 0, contentScrollViewContenSize -2, self.bounds.size.height);
    
    [_btnOfCollect setImage:[UIImage imageNamed:@"内页-评论-点赞"] forState:UIControlStateNormal];
    [_btnOfCollect setImage:[UIImage imageNamed:@"内页-评论-点赞-press"] forState:UIControlStateSelected];
    
    _btnOfChat.frame = CGRectMake(CGRectGetMaxX(_btnOfCollect.frame)+2 , 0, contentScrollViewContenSize +2, self.bounds.size.height);

    //用户名
    id object = [_userInfo objectForKey:kUserName];
    if (object == [NSNull null]) {
        object = nil;
    }
    
    [self.userName1 setText:object];
    self.userName1.width = 100;
    self.userName1.height = self.userName1.optimumSize.height;
 
    _btnOfChat.nameOfFloor = [@"@" stringByAppendingString:[NSString stringWithFormat:@"%@: ",self.userName1.text]];
    
    //弹出评论
    [self.shenglue setImage:[UIImage imageNamed:@"内页-评论-弹出键"] forState:UIControlStateNormal];
    [self.shenglue setImage:[UIImage imageNamed:@"内页-评论-弹出键-press"] forState:UIControlStateHighlighted];

    //回帖
    [self.answerArticl setText:[_userInfo objectForKey:kContent]];
    self.answerArticl.height = self.answerArticl.optimumSize.height;
    self.answerArticl.top = self.userName1.bottom + 10;
    
    //post创建时间
    [self.creatAt setText:[_userInfo objectForKey:kDate]];
    self.creatAt.top = self.userName1.bottom+ 5 ;
    self.creatAt.width = self.creatAt.optimumSize.width;
    self.creatAt.height = self.creatAt.optimumSize.height;
    self.creatAt.top = self.answerArticl.bottom + 10;
    
    //楼层
    [self.floor setText:[NSString stringWithFormat:@"第%@楼",[[_userInfo objectForKey:kFloor] stringValue]]];
    self.floor.width = self.floor.optimumSize.width;
    self.floor.height = self.floor.optimumSize.height;
    self.floor.top = self.answerArticl.bottom + 10;
    self.floor.left = self.creatAt.right +10;
    
    //赞数
    [self.attitude setText:[NSString stringWithFormat:@"%@赞",[[_userInfo objectForKey:kAttitudeCount] stringValue] ]];
    self.attitude.left = self.floor.right + 10;
    self.attitude.top = self.answerArticl.bottom + 10;
    self.attitude.width = self.attitude.optimumSize.width;
    self.attitude.height = self.attitude.optimumSize.height;
    
    self.highOfCell = self.creatAt.bottom +5;
}

@end
