//
//  QYPhotoTableViewCell.m
//  Hallyu
//
//  Created by 张毅 on 14-9-28.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYPhotoTableViewCell.h"
#import "RTLabel.h"
#import "UIViewExt.h"


@interface QYPhotoTableViewCell()
@property (retain, nonatomic) UIImageView *avatarImage;     //用户头像
@property (retain, nonatomic) RTLabel *userName1;           //用户名称
@property (retain, nonatomic) RTLabel *creatAt;             //时间
@property (retain, nonatomic) RTLabel *floor;               //多少楼
@property (retain, nonatomic) RTLabel *attitude;            //多少赞
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) UIButton *btnWithImage;

@end


#define contentScrollViewContenSize 40.0

@implementation QYPhotoTableViewCell


-(void)setCellData:(NSDictionary *)cellData
{
    _cellData = cellData;
    [self layoutSubviews];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //添加SCrollView为了滑动
        self.contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.backgroundColor = [UIColor clearColor];
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.bounces = NO;
        [self.contentView addSubview:_contentScrollView];
        
        //添加收藏按钮
        _btnOfCollect = [[UIButton alloc] initWithFrame:CGRectZero];
        _btnOfCollect = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnOfCollect.backgroundColor = [UIColor grayColor];
        [_btnOfCollect setImage:[UIImage imageNamed:@"内页-评论-点赞"] forState:UIControlStateNormal];
        [_btnOfCollect setImage:[UIImage imageNamed:@"内页-评论-点赞-press"] forState:UIControlStateHighlighted];
        [_contentScrollView addSubview:_btnOfCollect];
        
        //添加回复按钮
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
        
        //添加图片
        self.btnWithImage = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnWithImage.frame = CGRectMake(CGRectGetMaxX(self.userName1.frame), 5, 40, 55);
        [_contentScrollView addSubview:self.btnWithImage];
        
        //创建时间
        self.creatAt = [[RTLabel alloc]initWithFrame:CGRectMake(self.avatarImage.right +10,self.btnWithImage.bottom +10, 0, 0)];
        self.creatAt.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        self.creatAt.font = [UIFont systemFontOfSize:10.f];
        [_contentScrollView addSubview:self.creatAt];
        
        //楼层
        self.floor = [[RTLabel alloc]initWithFrame:CGRectMake(self.creatAt.right + 10, self.btnWithImage.bottom +10, 0, 0)];
        self.floor.font = [UIFont systemFontOfSize:10.0f];
        self.floor.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [_contentScrollView addSubview:self.floor];
        
        //赞数
        self.attitude = [[RTLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.floor.frame), self.btnWithImage.bottom +10, 0, 0)];
        self.attitude.font = [UIFont systemFontOfSize:10.f];
        self.attitude.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [_contentScrollView addSubview:self.attitude];
    }
    return self;
}


#pragma mark - 显示重绘图控件
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.userInfo = self.cellData;
    NSString *like = _userInfo[@"like"];
    
    //重构作者头像
    self.avatarImage.image = [UIImage imageNamed:@"taitanxiami.jpg"];
    self.avatarImage.layer.cornerRadius = 15.0f;
    self.avatarImage.layer.masksToBounds = YES;
    
    //设置cell的scrollView
    self.contentScrollView.frame = self.bounds;
    self.contentScrollView.contentSize = CGSizeMake(self.bounds.size.width + 2*contentScrollViewContenSize  , self.bounds.size.height);
    [self.contentScrollView setContentOffset:CGPointZero animated:YES];
    
    _btnOfCollect.frame = CGRectMake(self.bounds.size.width, 0, contentScrollViewContenSize -2, self.bounds.size.height);
    
    if ([like isEqualToString:@"0"]) {
        [_btnOfCollect setImage:[UIImage imageNamed:@"内页-评论-点赞"] forState:UIControlStateNormal];
    }else
    {
        [_btnOfCollect setImage:[UIImage imageNamed:@"内页-评论-点赞-press"] forState:UIControlStateNormal];
    }
    
    // addNew
    _btnOfChat.frame = CGRectMake(CGRectGetMaxX(_btnOfCollect.frame)+2 , 0, contentScrollViewContenSize +2, self.bounds.size.height);
    _btnOfChat.nameOfFloor = [@"@" stringByAppendingString:[NSString stringWithFormat:@"%@: ",self.userName1.text]];
    
    //用户名
    [self.userName1 setText:[_userInfo objectForKey:@"userName"]];
    self.userName1.width = 100;
    self.userName1.height = self.userName1.optimumSize.height;
    
    //弹出评论
    [self.shenglue setImage:[UIImage imageNamed:@"内页-评论-弹出键"] forState:UIControlStateNormal];
    [self.shenglue setImage:[UIImage imageNamed:@"内页-评论-弹出键-press"] forState:UIControlStateHighlighted];

}


#pragma mark -
#pragma mark 相应事件
- (void)tap:(UITapGestureRecognizer *)gesture
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"answerTap" object:self ];
    
}

@end
