//
//  QYPersonTableViewCell2.m
//  Hallyu
//
//  Created by qingyun on 14-9-4.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYPersonTableViewCell2.h"

NSInteger summ2 = 1;

@implementation QYPersonTableViewCell2


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _allCount = [[NSMutableArray alloc]initWithCapacity:5];
        _chooseState =[[NSMutableArray alloc]initWithCapacity:5];
        
        [_chooseState addObject:@1];
        
        
        
        UIView *publishView = [[UIView alloc]initWithFrame:CGRectMake(30, 0 , 100, 44)];
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
        
        
        
        UIView *replyView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(publishView.frame)+60, 0 , 100, 44)];
        
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
        
    }
    
    return self;
    
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    
    switch (summ2) {
        case 1:
        {
            _publish.image = [UIImage imageNamed:@"导航-发表文章-press"];
            _publishLab.text = @"1845";
            _reply.image = [UIImage imageNamed:@"导航-文章评论"];
            _replyLab.text =@"4212";
            
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
            
        }
            break;
            default:
            break;
    }
        
}


-(void)canReloadPublishMessgae:(UIGestureRecognizer *)gesture
{
    //    测试一下， self.delegate是否能够响应该代理方法， 如果不能响应， 则返回NO,否则返YES
    if ([self.delegate respondsToSelector:@selector(statuesTableViewCell:reloadOthersPublishMessgae:)]) {
        
        [self.delegate statuesTableViewCell:self reloadOthersPublishMessgae:gesture];
    }
    summ2 = 1;
}

-(void)canReloadReplyMessgae:(UIGestureRecognizer *)gesture
{
    //    测试一下， self.delegate是否能够响应该代理方法， 如果不能响应， 则返回NO,否则返YES
    if ([self.delegate respondsToSelector:@selector(statuesTableViewCell:reloadOthersReplyMessgae:)]) {
        
        [self.delegate statuesTableViewCell:self reloadOthersReplyMessgae:gesture];
    }
    
    summ2 = 2;
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
