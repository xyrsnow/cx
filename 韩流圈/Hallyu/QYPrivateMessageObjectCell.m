//
//  QYPrivateMessageObjectCell.m
//  Hallyu
//
//  Created by qingyun on 14-9-21.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYPrivateMessageObjectCell.h"
#import "QYPrivateMessageObject.h"
#import "QYPersonInformationViewController.h"
#import "UIButton+AFNetworking.h"



@implementation QYPrivateMessageObjectCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"message";
    QYPrivateMessageObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        // 从xib中加载cell
        cell = [[[NSBundle mainBundle] loadNibNamed:@"QYPrivateMessageObjectCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)setListObject:(QYPrivateMessageObject *)listObject
{
    _listObject = listObject;
    
    // 0.是否点击删除按钮
    self.isDeleteMessage = listObject.isChoiceDelete;
    
    // 1.头像
//    [_headImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,[self.personDict objectForKey:@"icon_url"]]]];
    [self.iconButton setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,listObject.linkman_icon_url]]];
    
    [self.iconButton setImage:[UIImage imageNamed:listObject.linkman_icon_url] forState:UIControlStateNormal];
    
    self.iconButton.layer.cornerRadius = 22;
    self.iconButton.clipsToBounds = YES;
    
    // 2.名字
    self.nameLabel.text = listObject.linkman_nickname;
    
    // 3.内容
    self.messageLabel.text = listObject.last_message;
    self.messageLabel.textColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];
    
    // 4.时间
    self.timeLabel.text = listObject.last_date;
    
    // 5.选择删除按钮
    [self.deleteBtn setImage:[UIImage imageNamed:@"私信列表-未标记"] forState:UIControlStateNormal];
    [self.deleteBtn setImage:[UIImage imageNamed:@"私信列表-标记"] forState:UIControlStateSelected];
    self.deleteBtn.userInteractionEnabled = NO;
    self.deleteBtn.hidden = (!self.isDeleteMessage);
}

- (void)onSelectBtn
{
    if (self.deleteBtn.selected) {
        self.deleteBtn.selected = NO;
    } else {
        self.deleteBtn.selected = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        if (self.deleteBtn.selected) {
            self.deleteBtn.selected = NO;
        } else {
            self.deleteBtn.selected = YES;
        }
    }
}

@end
