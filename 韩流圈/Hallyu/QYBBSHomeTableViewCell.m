//
//  QYBBSHomeTableViewCell.m
//  Hallyu
//
//  Created by 泰坦虾米 on 14-8-13.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYBBSHomeTableViewCell.h"
#import "NSString+FrameHeight.h"
#import "RTLabel.h"
#import "UIViewExt.h"
@implementation QYBBSHomeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        //帖子标题
        _posTitleLable = [[RTLabel alloc]initWithFrame:CGRectZero];
        _posTitleLable.font = [UIFont boldSystemFontOfSize:14.0f];
        [_posTitleLable setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:_posTitleLable];
        
        //帖子录音 按钮
        
        //贴子收藏
        self.collect = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (self.isCollect) {
            _collect.selected = YES;
        }else
        {
            _collect.selected = NO;
        }
        [_collect setImage:[UIImage imageNamed:@"内页-收藏"] forState:UIControlStateNormal];
        [_collect setImage:[UIImage imageNamed:@"内页-收藏-press"] forState:UIControlStateHighlighted];
    
        [self.contentView addSubview: self.collect];
        
    }
    return self;
}

-(void)restoreCellFrame
{
    self.hotPic.frame =CGRectZero;
    self.posTitleLable.frame = CGRectZero;
    self.postImage.frame = CGRectZero;
    self.postContentLable.frame =CGRectZero;
    self.postAuthorLable.frame = CGRectZero;
    self.replyAndAttitudeLable.frame = CGRectZero;
}

//======对试图重新布局=====
-(void)layoutSubviews
{
    [super layoutSubviews ];
    [self restoreCellFrame];
    
    //请求数据 接口
    NSDictionary *postInfo =self.cellData;
  
    //是否有热门BOOL,posttitle，postAuthor，postContent,creatTime,zanCount,replyCount image ,
#if 0
    //热门
    BOOL isHot =[[postInfo objectForKey:@"isHot" ] boolValue];
    NSString *tempPostTitle = [postInfo objectForKey:@"posttitle"];
    //帖子标题
    [self.posTitleLable setTextColor:[UIColor blackColor]];
    self.posTitleLable.font = [UIFont systemFontOfSize:14.0f];
    self.posTitleLable.lineBreakMode = RTTextLineBreakModeWordWrapping;
    // 配图
    UIImage *postIamge = [postInfo objectForKey:@"postImage"];
    //帖子正文
    self.postContentLable.font = [UIFont systemFontOfSize:10.0f];
    [self.postContentLable setTextColor:[UIColor colorWithWhite:0.621 alpha:1.000]];
    [self.postContentLable setText:[postInfo objectForKey:@"postCotent"]];
    self.postContentLable.lineBreakMode = RTTextLineBreakModeWordWrapping;
    //帖子作者
    [self.postAuthorLable setText: [postInfo objectForKey:@"postAtuthor"]];
    self.postAuthorLable.font = [UIFont systemFontOfSize:10.0f];
    [self.postAuthorLable setTextColor:[UIColor colorWithRed:0.397 green:0.405 blue:0.402 alpha:1.000]];
    //创建时间
    self.creatTimeLable.text = @"30分钟前";
    [self.creatTimeLable setTextColor:[UIColor lightGrayColor]];
    self.creatTimeLable.font = [UIFont systemFontOfSize:10.f];
    //回复和赞
    NSString *replyStr = [[[postInfo objectForKey:@"replyCount"] stringValue] stringByAppendingString:@"回复"];
    NSString *attitudeStr = [[[postInfo objectForKey:@"attitudeCount"] stringValue] stringByAppendingString:@"赞   "];
    [self.replyAndAttitudeLable setText:[attitudeStr stringByAppendingString:replyStr]];
    self.replyAndAttitudeLable.font = [UIFont systemFontOfSize:10.0f];
    [self.replyAndAttitudeLable setTextColor:[UIColor orangeColor]];

    if (isHot) {
        //热门
        self.hotPic.frame = CGRectMake(10, 10, 30, 15);
        self.hotPic.text = @"热门";
        self.hotPic.layer.masksToBounds = YES;
        self.hotPic.layer.cornerRadius = 5.0f;
        [self.hotPic setTextAlignment: NSTextAlignmentCenter]; //文字居中
        self.hotPic.font = [UIFont boldSystemFontOfSize:10.0f];
        self.hotPic.backgroundColor = [UIColor orangeColor];
        [self.hotPic setTextColor:[UIColor whiteColor]];
        
        [self.posTitleLable setText:[@"        " stringByAppendingString:tempPostTitle]];

        if (postIamge == nil) {
            
            //没有帖子图片的时候
            //帖子标题
            self.posTitleLable.frame = CGRectMake(10, 10, 280, 0);
            //======判断lable的高度========
            self.posTitleLable.height = (self.posTitleLable.optimumSize.height > 33 ? 33 : self.posTitleLable.optimumSize.height);
            
            //帖子正文
            self.postContentLable.frame =CGRectMake(10, self.posTitleLable.bottom+5, 280, 0);
            self.postContentLable.height = (self.postContentLable.optimumSize.height > 33 ? 33 :self.postContentLable.optimumSize.height);
            self.postContentLable.lineBreakMode = RTTextLineBreakModeWordWrapping;
            
            
        }else
        {
            //+=============有帖子图片高度的时候===========
            //帖子内图
            self.postImage.backgroundColor = [UIColor lightGrayColor];
            self.postImage.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame) - 70, CGRectGetMinY(self.contentView.frame)+10, 60, 60);
            
            //帖子标题
            self.posTitleLable.frame = CGRectMake(10, 10, 220, 0);
            //======判断lable的高度========
            self.posTitleLable.height = (self.posTitleLable.optimumSize.height > 33 ? 33 : self.posTitleLable.optimumSize.height);
        
            //帖子正文
            self.postContentLable.frame =CGRectMake(10, self.posTitleLable.bottom+5, 220, 0);
            self.postContentLable.height = (self.postContentLable.optimumSize.height > 33 ? 33 :self.postContentLable.optimumSize.height);
                 }
        

        
    }else
    {
          [self.posTitleLable setText:tempPostTitle];
        
        if (postIamge == nil) {

        
            //没有帖子图片的时候
            //帖子标题
            self.posTitleLable.frame = CGRectMake(10, 10, 280, 0);
            //======判断lable的高度========
            self.posTitleLable.height = (self.posTitleLable.optimumSize.height > 33 ? 33 : self.posTitleLable.optimumSize.height);
            
            //帖子正文
            self.postContentLable.frame =CGRectMake(10, self.posTitleLable.bottom+5, 280, 0);
            self.postContentLable.height = (self.postContentLable.optimumSize.height > 33 ? 33 :self.postContentLable.optimumSize.height);
            self.postContentLable.lineBreakMode = RTTextLineBreakModeWordWrapping;
            
            
        }else
        {
            //+=============有帖子图片高度的时候===========
            //帖子内图
            self.postImage.backgroundColor = [UIColor lightGrayColor];
            self.postImage.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame) - 70, CGRectGetMinY(self.contentView.frame)+10, 60, 60);
            
            //帖子标题
            self.posTitleLable.frame = CGRectMake(10, 10, 220, 0);
            //======判断lable的高度========
            self.posTitleLable.height = (self.posTitleLable.optimumSize.height > 33 ? 33 : self.posTitleLable.optimumSize.height);
            
            //帖子正文
            self.postContentLable.frame =CGRectMake(10, self.posTitleLable.bottom+5, 220, 0);
            self.postContentLable.height = (self.postContentLable.optimumSize.height > 33 ? 33 :self.postContentLable.optimumSize.height);
        }
        
        
    }
    
    self.postAuthorLable.frame = CGRectMake(10, CGRectGetMaxY(self.postContentLable.frame)+5, 0, 0);
    
    self.postAuthorLable.width = (self.postAuthorLable.optimumSize.width > 65 ? 65 : self.postAuthorLable.optimumSize.width);
    self.postAuthorLable.height = (self.postAuthorLable.optimumSize.height > 12 ? 12 : self.postAuthorLable.optimumSize.height);
    
    
    //创建时间
    self.creatTimeLable.frame = CGRectMake(self.postAuthorLable.right+5, self.postAuthorLable.top, 0, 0);
    self.creatTimeLable.width = self.creatTimeLable.optimumSize.width;
    self.creatTimeLable.height = self.creatTimeLable.optimumSize.height;
    
    //帖子回复数和赞数
    self.replyAndAttitudeLable.frame = CGRectMake(0, self.creatTimeLable.top, 0, 0) ;
    self.replyAndAttitudeLable.width = self.replyAndAttitudeLable.optimumSize.width;
    self.replyAndAttitudeLable.height = self.replyAndAttitudeLable.optimumSize.height;
    self.replyAndAttitudeLable.left = 320 -self.replyAndAttitudeLable.optimumSize.width - 10;
#endif
    
    // 帖子标题
    NSString *tempPostTitle = [postInfo objectForKey:@"titile"];
    [self.posTitleLable setTextColor:[UIColor blackColor]];
    self.posTitleLable.font = [UIFont systemFontOfSize:14.0f];
    self.posTitleLable.lineBreakMode = RTTextLineBreakModeWordWrapping;
    self.posTitleLable.frame = CGRectMake(10, 10, 270, 30);
    self.posTitleLable.text = tempPostTitle;
    self.posTitleLable.height = self.posTitleLable.optimumSize.height;
   
    // 帖子收藏
    self.collect.frame = CGRectMake(320 - 30,3 + self.posTitleLable.height/2 , 30, 30);
    [self.collect setImage:[UIImage imageNamed:@"内页-收藏-press"]forState:UIControlStateSelected];
    [self.collect setImage:[UIImage imageNamed:@"内页-收藏"]forState:UIControlStateNormal];
    self.collect.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 14, 14);

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
