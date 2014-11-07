//
//  QYPersonChooseTableViewCell.m
//  Hallyu
//
//  Created by qingyun on 14-8-29.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYPersonChooseTableViewCell.h"

NSInteger summ = 1;

@implementation QYPersonChooseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _allCount = [[NSMutableArray alloc]initWithCapacity:5];
        _chooseState =[[NSMutableArray alloc]initWithCapacity:5];
        
        [_chooseState addObject:@1];
        
    
        
        UIView *publishView = [[UIView alloc]initWithFrame:CGRectMake(10, 0 , 100, 44)];
        UITapGestureRecognizer *tapPublish = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(canReloadPublishMessgae:)];
        [publishView addGestureRecognizer:tapPublish];
        
        _publish = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 24, 24)];
        _publish.userInteractionEnabled  = YES ;
        _publishLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_publish.frame)+6, 12, 60, 20)];
    
        _publishLab.textColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];;
        _publishLab.font =[UIFont systemFontOfSize:14.0f];
        [publishView addSubview:_publish];
        [publishView addSubview:_publishLab];
        
        [self.contentView addSubview:publishView];
        
        UIView *replyView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(publishView.frame), 0 , 100, 44)];
        
        UITapGestureRecognizer *tapReply = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(canReloadReplyMessgae:)];
        [replyView addGestureRecognizer:tapReply];
        
        _reply = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 24, 24)];
        _reply.userInteractionEnabled =YES;
        
        _replyLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_publish.frame)+6, 12, 60, 20)];
        _replyLab.textColor = [UIColor grayColor];
        _replyLab.font =[UIFont systemFontOfSize:14.0f];
        
        [replyView addSubview:_reply];
        [replyView addSubview:_replyLab];
        
        [self.contentView addSubview:replyView];
        
        
        UIView *collectView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(replyView.frame), 0 , 100, 44)];
        
        UITapGestureRecognizer *tapCollect = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(canReloadCollectMessgae:)];
        [collectView addGestureRecognizer:tapCollect];
        
        _collect = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 24, 24)];
        _collect.userInteractionEnabled = YES;
        
        _collectLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_collect.frame)+6, 12, 60, 20)];
        _collectLab.textColor = [UIColor grayColor];
        _collectLab.font =[UIFont systemFontOfSize:14.0f];
        
        [collectView addSubview:_collect];
        [collectView addSubview:_collectLab];
        
        [self.contentView addSubview:collectView];
        
        
    }
    
    return self;

}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    
    switch (summ) {
        case 1:
        {
            _publish.image = [UIImage imageNamed:@"导航-发表文章-press"];
            _publishLab.text = @"1845";
            _reply.image = [UIImage imageNamed:@"导航-文章评论"];
            _replyLab.text =@"4212";
            _collect.image =[UIImage imageNamed:@"导航-收藏"];
            _collectLab.text =@"475";
        
        }
            
            break;
            
            case 2:
        {
            _publish.image = [UIImage imageNamed:@"导航-发表文章"];
            _publishLab.text = @"1845";
            _publishLab.textColor = [UIColor grayColor];
            _reply.image = [UIImage imageNamed:@"导航-文章评论-press"];
            _replyLab.text =@"4212";
            _replyLab.textColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];;
            _collect.image =[UIImage imageNamed:@"导航-收藏"];
            _collectLab.text =@"475";
            _collectLab.textColor = [UIColor grayColor];
        }
            break;
            case 3:
        {
            _publish.image = [UIImage imageNamed:@"导航-发表文章"];
            _publishLab.text = @"1845";
            _publishLab.textColor = [UIColor grayColor];
            _reply.image = [UIImage imageNamed:@"导航-文章评论"];
            _replyLab.text =@"4212";
            _replyLab.textColor = [UIColor grayColor];
            _collect.image =[UIImage imageNamed:@"导航-收藏-press"];
            _collectLab.text =@"475";
            _collectLab.textColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];;
        }
            break;
        default:
            break;
    }

    
    
}


-(void)canReloadPublishMessgae:(UIGestureRecognizer *)gesture
{
    //    测试一下， self.delegate是否能够响应该代理方法， 如果不能响应， 则返回NO,否则返YES
    if ([self.delegate respondsToSelector:@selector(statuesTableViewCell:reloadPublishMessgae:)]) {
        
        [self.delegate statuesTableViewCell:self reloadPublishMessgae:gesture];
    }
    summ = 1;
}

-(void)canReloadReplyMessgae:(UIGestureRecognizer *)gesture
{
    //    测试一下， self.delegate是否能够响应该代理方法， 如果不能响应， 则返回NO,否则返YES
    if ([self.delegate respondsToSelector:@selector(statuesTableViewCell:reloadReplyMessgae:)]) {
        
        [self.delegate statuesTableViewCell:self reloadReplyMessgae:gesture];
    }

    summ = 2;
}


-(void)canReloadCollectMessgae:(UIGestureRecognizer *)gesture
{
    //    测试一下， self.delegate是否能够响应该代理方法， 如果不能响应， 则返回NO,否则返YES
    if ([self.delegate respondsToSelector:@selector(statuesTableViewCell:reloadCollectMessgae:)]) {
        
        [self.delegate statuesTableViewCell:self reloadCollectMessgae:gesture];
    }
    
    summ = 3;
}


@end
