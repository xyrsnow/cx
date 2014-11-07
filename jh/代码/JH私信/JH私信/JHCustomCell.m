//
//  JHCustomCell.m
//  JH私信
//
//  Created by qingyun on 14-10-26.
//  Copyright (c) 2014年 JH. All rights reserved.
//

#import "JHCustomCell.h"

@implementation JHCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //各个控件的创建
        //1.时间
        _timeView = [[UILabel alloc] init];
        _timeView.textAlignment = NSTextAlignmentCenter;
        _timeView.textColor = [UIColor grayColor];
        _timeView.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_timeView];
        
        //2.头像
        _iconView = [[UIImageView alloc] init];
        _iconView.clipsToBounds = YES;
        [self.contentView addSubview:_iconView];
        
        //3.内容
        _textView = [[UIButton alloc] init];
        _textView.titleLabel.numberOfLines = 0;
        _textView.titleLabel.font = [UIFont systemFontOfSize:15];
        [_textView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //设置button的内边距,使文字与控件边距保持一定的间距
        _textView.contentEdgeInsets = UIEdgeInsetsMake(10, kTextPadding, kTextPadding, kTextPadding);
        [self.contentView addSubview:_textView];
        
        // 4.设置cell的背景色
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setCellMessage:(JHCellMessage *)cellMessage
{
    _cellMessage = cellMessage;
    
    //1.时间
    _timeView.text = cellMessage.messageDict[kTime];
    _timeView.frame = cellMessage.timeFrame;
    
    //2.头像
    _iconView.image = [UIImage imageNamed:cellMessage.sendPerson ? @"1.jpg" : @"2.jpg"];
    _iconView.frame = cellMessage.iconFrame;
    _iconView.layer.cornerRadius = _iconView.frame.size.width * 0.5;
    
    //3.内容
    [_textView setTitle:cellMessage.messageDict[kText] forState:UIControlStateNormal];
    _textView.frame = cellMessage.textFrame;
    //判断button的背景图片
    UIImage *btnImage = cellMessage.sendPerson ? [UIImage imageNamed:@"SenderTextNodeBkg"] : [UIImage imageNamed:@"SenderTextNodeBkgOther"];
    //图片拉伸
    CGFloat h = btnImage.size.height * 0.5;
    CGFloat w = btnImage.size.width * 0.5;
    [_textView setBackgroundImage:[btnImage resizableImageWithCapInsets:UIEdgeInsetsMake(h, w, h, w)] forState:UIControlStateNormal];
//    [_textView setBackgroundImage:btnImage forState:UIControlStateNormal];
}


@end
