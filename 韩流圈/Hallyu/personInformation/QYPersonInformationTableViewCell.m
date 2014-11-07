//
//  QYPersonInformationTableViewCell.m
//  Hallyu
//
//  Created by qingyun on 14-8-12.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYPersonInformationTableViewCell.h"

@implementation QYPersonInformationTableViewCell

static const NSUInteger smallWidth  = 20.0f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIFont *customFont = [UIFont systemFontOfSize:14.0f];
        
        _messageTitle = [[UILabel alloc]initWithFrame:CGRectMake(smallWidth, 0 , 200, 25)];
        _messageTitle.font =customFont;
        _messageTitle.numberOfLines = 1;
        [self.contentView addSubview:_messageTitle];
        _messageTime = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_messageTitle.frame), 0, 80, 25)];
        _messageTime.textAlignment = NSTextAlignmentCenter;
        _messageTime.font = customFont;
        [self.contentView addSubview:_messageTime];
    }
    return self;
}

-(void)setIsHiddenDate:(BOOL)isHiddenDate{
    
    UIFont *customFont = [UIFont systemFontOfSize:14.0f];
    _isHiddenDate = isHiddenDate;
    
    if (_isHiddenDate) {
        
        _messageTitle.frame = CGRectMake(smallWidth, 0 , 300, 25);
        _messageTitle.font =customFont;
        _messageTitle.numberOfLines = 1;
        _messageTime.frame = CGRectZero;
        [self.contentView addSubview:_messageTitle];
        
    }else{
        
        _messageTitle.frame = CGRectMake(smallWidth, 0 , 200, 25);
        _messageTitle.font =customFont;
        _messageTitle.numberOfLines = 1;
        [self.contentView addSubview:_messageTitle];
        
        _messageTime.frame = CGRectMake(CGRectGetMaxX(_messageTitle.frame), 0, 80, 25);
        _messageTime.textAlignment = NSTextAlignmentCenter;
        _messageTime.font = customFont;
        [self.contentView addSubview:_messageTime];
    }
    
    
}

-(void)layoutSubviews
{
    _messageTitle.text = [_messageData objectForKey:@"title"];
    
    _messageTime.text = [_messageData objectForKey:@"time"];
    
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
