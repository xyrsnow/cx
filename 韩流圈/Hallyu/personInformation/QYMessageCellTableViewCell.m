//
//  QYMassageCellTableViewCell.m
//  Hallyu
//
//  Created by qingyun on 14-9-1.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYMessageCellTableViewCell.h"
#import "NSString+FrameHeight.h"

@implementation QYMessageCellTableViewCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _messageDic = [[NSMutableDictionary alloc]initWithCapacity:100];
        
        [_messageDic setObject:@"中移动报告：“中华酷族”正在瓦解" forKey:@"title"];
        [_messageDic setObject:@"SM新女团Res Velvet" forKey:@"title1"];
        
        
        _MessageSubject  = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 50, 15)];
        _MessageSubject.tintColor = [UIColor blackColor];
        _MessageSubject.text = @"主题 :";
        _MessageSubject.font = [UIFont boldSystemFontOfSize:15.0f];
        
        _MessageTitle = [[UILabel alloc]initWithFrame:CGRectZero];
        _MessageTitle.font =[UIFont boldSystemFontOfSize:15.0f];
        
        
        _MessageTime = [[UILabel alloc]initWithFrame:CGRectZero];
        _MessageTime.font = [UIFont systemFontOfSize:10];
        _MessageTime.textColor = [UIColor grayColor];
        
        _MessageLookedCount = [[UILabel alloc]initWithFrame:CGRectZero];
        _MessageLookedCount.font =[UIFont systemFontOfSize:10.0f];
        _MessageLookedCount.textColor = [UIColor grayColor];
        
        _MessageSupportCount = [[UILabel alloc]initWithFrame:CGRectZero];
        _MessageSupportCount.font =[UIFont systemFontOfSize:10.0f];
        _MessageSupportCount.textColor = [UIColor grayColor];
        
        _MessageReplyCount = [[UILabel alloc]initWithFrame:CGRectZero];
        _MessageReplyCount.font =[UIFont systemFontOfSize:10.0f];
        _MessageReplyCount.textColor = [UIColor grayColor];
        
        _MessageCollectCount = [[UILabel alloc]initWithFrame:CGRectZero];
        _MessageCollectCount.font =[UIFont systemFontOfSize:10.0f];
        _MessageCollectCount.textColor = [UIColor grayColor];
        
        
        _MessageContent = [[UILabel alloc]initWithFrame:CGRectZero];
        _MessageContent.font =[UIFont systemFontOfSize:12.0f];
        _MessageContent.textColor = [UIColor grayColor];
        _MessageContent.numberOfLines = 1;
        
        [self.contentView addSubview:_MessageSubject];
        [self.contentView addSubview:_MessageTitle];
        [self.contentView addSubview:_MessageTime];
        [self.contentView addSubview:_MessageLookedCount];
        [self.contentView addSubview:_MessageSupportCount];
        [self.contentView addSubview:_MessageReplyCount];
        [self.contentView addSubview:_MessageCollectCount];
        [self.contentView addSubview:_MessageContent];
        
        
    }
    return self;
}

-(void)layoutSubviews
{
    
    _MessageTitle.frame = CGRectMake(CGRectGetMaxX(_MessageSubject.frame), 15, 250, 15);
    _MessageTitle.text = [_messageDic objectForKey:@"title"];
    

    _MessageTime.frame = CGRectMake(CGRectGetMinX(_MessageSubject.frame), CGRectGetMaxY(_MessageTitle.frame)+10, 70 , 10);
    _MessageTime.text = @"4月27日 13:14";
    
    _MessageLookedCount.frame =CGRectMake(CGRectGetMaxX(_MessageTime.frame)+10, CGRectGetMaxY(_MessageTitle.frame)+10, 40, 10);
    _MessageLookedCount.text = @"123浏览";
    
    
    _MessageSupportCount.frame =CGRectMake(CGRectGetMaxX(_MessageLookedCount.frame)+10, CGRectGetMaxY(_MessageTitle.frame)+10, 25, 10);
    _MessageSupportCount.text = @"1赞";
    
    
    _MessageReplyCount.frame =CGRectMake(CGRectGetMaxX(_MessageSupportCount.frame)+10, CGRectGetMaxY(_MessageTitle.frame)+10, 30, 10);
    _MessageReplyCount.text = @"2评论";
    
    
    _MessageCollectCount.frame =CGRectMake(CGRectGetMaxX(_MessageReplyCount.frame)+10, CGRectGetMaxY(_MessageTitle.frame)+10, 30, 10);
    _MessageCollectCount.text = @"2收藏";
    
    
    _MessageContent.frame = CGRectMake(CGRectGetMinX(_MessageSubject.frame), CGRectGetMaxY(_MessageCollectCount.frame)+10, 300, 12);
    _MessageContent.text = @"近日，一则来自中移动内部对于国内智能手机出货量的消息";
    

    
}

@end
