//
//  JHCellMessage.m
//  JH私信
//
//  Created by qingyun on 14-10-26.
//  Copyright (c) 2014年 JH. All rights reserved.
//

#import "JHCellMessage.h"

@implementation JHCellMessage

- (void)setMessageDict:(NSDictionary *)messageDict
{
    _messageDict = messageDict;
    _sendPerson = [messageDict[kSendPerson] boolValue];

    //1.时间
    if (!self.isHideTime) {  //需要显示时间
        _timeFrame = CGRectMake(0, 0, kScreenW, 40);
    }
    
    //2.头像
    CGFloat iconY = CGRectGetMaxY(_timeFrame) + kSpacing;
    CGFloat iconWH = 40;
    CGFloat iconX;
    if (_sendPerson) {      //自己发的信息
        iconX = kScreenW - kSpacing - iconWH;
    } else {               //别人发的
        iconX = kSpacing;
    }
    _iconFrame = CGRectMake(iconX, iconY, iconWH, iconWH);
    
    //3.内容
    //算出传过来的文字的Size
    CGSize textSize = [messageDict[kText] boundingRectWithSize:CGSizeMake(200, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    //button的Size
    CGSize textButtonSize = CGSizeMake(textSize.width + kTextPadding * 2, textSize.height + kTextPadding * 2);
    CGFloat textY = iconY;
    CGFloat textX;
    if (_sendPerson) {       //自己发的
        textX = iconX - kSpacing - textButtonSize.width;
    } else {
        textX = CGRectGetMaxX(_iconFrame) + kSpacing;
    }
    _textFrame = CGRectMake(textX, textY, textButtonSize.width, textButtonSize.height);
    //4.cell的高度
    _cellHeight = CGRectGetMaxY(_textFrame) + kSpacing;
}

@end













