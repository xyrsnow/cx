//
//  QYPopularTableViewCell.m
//  Hallyu
//
//  Created by 泰坦虾米 on 14/9/1.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYPopularTableViewCell.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIButton+AFNetworking.h"
#import "AsyncImageView.h"

@implementation QYPopularTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
   self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //用户头像
        self.avatarImage = [UIButton buttonWithType:UIButtonTypeCustom];
        self.avatarImage.frame = CGRectMake(10, 10, 30, 30);
        self.avatarImage.userInteractionEnabled = YES;
        [self.contentView addSubview:self.avatarImage];

        //用户名
        self.userName = [[RTLabel alloc]initWithFrame: CGRectMake(self.avatarImage.right + 10, 10, 0, 0)];
        self.userName.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
        self.userName.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:self.userName];

        //创建时间
        self.creatAt = [[RTLabel alloc]initWithFrame:CGRectMake(self.avatarImage.right +10,CGRectGetMaxY(self.userName.frame), 0, 0)];
        self.creatAt.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        self.creatAt.font = [UIFont systemFontOfSize:10.f];
        [self.contentView addSubview:self.creatAt];
        
        //收藏按钮
        self.favoritesBtn = [[UIButton alloc]initWithFrame:CGRectMake(320 - 40, 10, 40, 40)];
        [self.favoritesBtn setImage:[UIImage imageNamed:@"内页-收藏"] forState:UIControlStateNormal];
        [self.favoritesBtn setImage:[UIImage imageNamed:@"内页-收藏-press"] forState:UIControlStateHighlighted];
        self.favoritesBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 24, 14);
        [self.contentView addSubview:self.favoritesBtn];
        
        //回帖
        self.replyLable = [[RTLabel alloc]init];
        self.replyLable.textColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];
        self.replyLable.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:self.replyLable];
        
        //帖子标题
        self.postTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, self.avatarImage.bottom , 300 , 30)];
        self.postTitle.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        self.postTitle.font = [UIFont systemFontOfSize:15.0f];
        [self.contentView addSubview:self.postTitle];
    }
    
       return self;
}


#pragma mark - action
- (void)tap:(UITapGestureRecognizer *)gesture
{
    
    NSDictionary *dic = @{@"12":@"123"};
    // 传值(如ID)
    [[NSNotificationCenter defaultCenter] postNotificationName:@"chilkAvatarImg" object:self userInfo:dic];
    

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *userInfo = self.cellData;
    
    //用户头像
    NSString *image = [userInfo objectForKey:@"image"];
    [image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *imgString = [NSString stringWithFormat:@"%@%@",BASE_URL,image];
    imgString = [imgString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.avatarImage setImage:[UIImage imageNamed:@"taitanxiami.jpg"] forState:UIControlStateNormal];
#if 0
    self.avatarImage.imageView.imageURL = [[NSURL alloc] initWithString:imgString];
#endif
    
    self.avatarImage.layer.cornerRadius = 15.0f;
    self.avatarImage.layer.masksToBounds = YES;
    

    //用户名
    [self.userName setText:[userInfo objectForKey:@"author"]];
    self.userName.width = self.userName.optimumSize.width;
    self.userName.height = self.userName.optimumSize.height;
    [self.userName setNeedsDisplay];
    
    //post创建时间
    [self.creatAt setText:[userInfo objectForKey:@"date"]];
    self.creatAt.top = self.userName.bottom+ 5 ;
    self.creatAt.width = self.creatAt.optimumSize.width;
    self.creatAt.height = self.creatAt.optimumSize.height;
    
    //回帖
    NSString *reply = @"67";
    [self.replyLable setText:reply];
    self.replyLable.frame = CGRectMake(0, 13, self.replyLable.optimumSize.width, self.replyLable.optimumSize.height );
    
    self.replyLable.left = 320 - 50;
    //帖子标题
    [self.postTitle setText:[userInfo objectForKey:@"titile"]];
 
    //收藏
    if (self.isCollect) {
        self.favoritesBtn.selected = YES;
    }else
    {
        self.favoritesBtn.selected = NO;
    }
  
    [self.favoritesBtn setImage:[UIImage imageNamed:@"内页-收藏"]forState:UIControlStateNormal];
    [self.favoritesBtn setImage:[UIImage imageNamed:@"内页-收藏-press"]forState:UIControlStateSelected];
  
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    
    [self.userName addGestureRecognizer:tap];

    
    
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
