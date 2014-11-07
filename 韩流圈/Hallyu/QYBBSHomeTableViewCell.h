//
//  QYBBSHomeTableViewCell.h
//  Hallyu
//
//  Created by 泰坦虾米 on 14-8-13.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RTLabel;
@interface QYBBSHomeTableViewCell : UITableViewCell

@property(nonatomic,retain)UILabel *hotPic; //热门图片
@property(nonatomic,retain)UIImageView *postImage; //帖子内图
@property(nonatomic,retain)RTLabel *posTitleLable; //帖子标题
//@property(nonatomic,retain)UIImageView *recordingImageView; //录音长度视图
@property(nonatomic,retain)RTLabel *postContentLable;  //帖子正文
@property(nonatomic,retain)RTLabel *postAuthorLable; //帖子作者
@property(nonatomic,retain)RTLabel *creatTimeLable; //帖子创建时间
@property(nonatomic,retain) RTLabel *replyAndAttitudeLable; //帖子回复数和赞数
@property(nonatomic,retain)NSDictionary *cellData;

/*
 * 修改BUG
 */
@property (nonatomic, strong) UIButton *collect;
@property (nonatomic) BOOL isCollect;

//@property(nonatomic)BOOL isHot;
@end
