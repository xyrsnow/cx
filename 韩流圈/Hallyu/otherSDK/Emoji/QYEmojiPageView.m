//
//  QYEmojiPageView.m
//  QYNWeiBoClient
//
//  Created by qingyun on 14-8-2.
//  Copyright (c) 2014年 河南青云信息技术有限公司. All rights reserved.
//

#import "QYEmojiPageView.h"
#import "Emoji.h"

@interface QYEmojiPageView ()
@property (nonatomic, retain) NSArray *allEmojis;

@end

@implementation QYEmojiPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _allEmojis = [Emoji allEmoji];
    }
    return self;
}

+(NSUInteger)pageForAllEmoji:(int)countPage
{
    NSArray *emojis = [Emoji allEmoji];
    return emojis.count / countPage;
}



//page = 0 表示显示的第一页 在4行9列的布局， 具体显示哪一页
- (void)LoadEmojiItem:(int)page size:(CGSize)size
{
//    按行布局， 也就是一行一行的布局表情位置
    for (int i = 0;  i < 4; i++) {
        for (int j = 0; j < 9; j++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = CGRectMake(j*size.width, i * size.height, size.width, size.height);
            UIFont *emojiFont = [UIFont fontWithName:@"AppleColorEmoji" size:29.0];
            btn.titleLabel.font = emojiFont;
            // 每一页最后一个表情实际是一个表示删除含义的按纽，所以要单独处理
            if (i == 3 && j == 8) {
                [btn setImage:[UIImage imageNamed:@"delet"] forState:UIControlStateNormal];
                btn.tag = 10000;
            }else
            {
                NSString *emj = self.allEmojis[i*9 + j + page * 35];
                [btn setTitle:emj forState:UIControlStateNormal];
            }
            [btn addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
    }
}

- (void)itemSelected:(UIButton*)sender
{
    //在这里调用具体的代理方法，1首先判断代理类是否现了代理方法， 如果是，则调用
    if (sender.tag ==10000) {
        [self.delegate selectedFacialView:@"删除"];
    }else if([self.delegate respondsToSelector:@selector(emojiViewDidSelected:Item:)]) {
        [self.delegate emojiViewDidSelected:self Item:sender];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
