//
//  MJMessageCell.m
//  01-QQ聊天布局
//
//  Created by apple on 14-4-2.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "MJMessageCell.h"
#import "MJMessageFrame.h"
#import "MJMessage.h"
#import "UIImage+Extension.h"

@interface MJMessageCell()
/**
 *  时间
 */
@property (nonatomic, weak) UILabel *timeView;
/**
 *  头像
 */
@property (nonatomic, weak) UIImageView *iconView;
/**
 *  正文
 */
//@property (nonatomic, weak) UIButton *textView;
@end

@implementation MJMessageCell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"message";
    MJMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[MJMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 子控件的创建和初始化
        // 1.时间
        UILabel *timeView = [[UILabel alloc] init];
        timeView.textAlignment = NSTextAlignmentCenter;
        timeView.textColor = [UIColor grayColor];
        timeView.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:timeView];
        self.timeView = timeView;
        
        // 2.头像
        UIImageView *iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:iconView];
        self.iconView = iconView;
        
        // 3.正文
        UIButton *textView = [[UIButton alloc] init];
        textView.titleLabel.numberOfLines = 0; // 自动换行
        textView.titleLabel.font = MJTextFont;
        textView.contentEdgeInsets = UIEdgeInsetsMake(MJTextPadding, MJTextPadding, MJTextPadding, MJTextPadding);
        [textView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:textView];
        self.textView = textView;
        
        // 4.设置cell的背景色
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setMessageFrame:(MJMessageFrame *)messageFrame
{
    _messageFrame = messageFrame;
    
    MJMessage *message = messageFrame.message;
    
    // 1.时间
    self.timeView.text = message.date;
    self.timeView.frame = messageFrame.timeF;
    
    // 2.头像
    NSString *icon = (message.is_receice == MJMessageTypeMe) ? @"1.jpg" : @"3.jpg";
    self.iconView.image = [UIImage imageNamed:icon];
    self.iconView.clipsToBounds = YES;
    self.iconView.frame = messageFrame.iconF;
    self.iconView.layer.cornerRadius = self.iconView.frame.size.height / 2;
    
    // 3.正文

        [self.textView setTitle:message.pm_text forState:UIControlStateNormal];
        self.textView.frame = messageFrame.textF;
    
    // 4.正文的背景
    if (message.is_receice == MJMessageTypeMe) { // 自己发的
        [self.textView setBackgroundImage:[UIImage resizableImage:@"SenderTextNodeBkg"] forState:UIControlStateNormal];
    } else { // 别人发的
        [self.textView setBackgroundImage:[UIImage resizableImage:@"SenderTextNodeBkgOther"] forState:UIControlStateNormal];
    }
    
    if (message.image != nil) {
         self.textView.frame = CGRectMake(100, 50, 120, 140);
        [self.textView setBackgroundImage:message.image forState:UIControlStateNormal];
    }
    
}
@end
