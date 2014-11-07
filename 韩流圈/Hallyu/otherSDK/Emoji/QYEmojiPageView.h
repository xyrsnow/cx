//
//  QYEmojiPageView.h
//  QYNWeiBoClient
//
//  Created by qingyun on 14-8-2.
//  Copyright (c) 2014年 河南青云信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

//协议的前向声明
@protocol QYEmojPageViewDelegate;




@interface QYEmojiPageView : UIView
//设计一个代理的属性
@property (nonatomic, assign) id<QYEmojPageViewDelegate> delegate;
//布局：根据具体的界面需求，布局表情界面
+(NSUInteger)pageForAllEmoji:(int)countPage;
- (void)LoadEmojiItem:(int)page size:(CGSize)size;

@end




//声明一个协议
@protocol QYEmojPageViewDelegate <NSObject>

- (void)emojiViewDidSelected:(QYEmojiPageView*)emojiView Item:(UIButton*)btnItem;
@optional
-(void)selectedFacialView:(NSString*)str;

@end
