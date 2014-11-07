//
//  MJMessage.h
//  01-QQ聊天布局
//
//  Created by apple on 14-4-2.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MJMessageTypeOther = 1, // 自己发的
    MJMessageTypeMe   // 别人发的
} MJMessageType;

@interface MJMessage : NSObject
/**
 *  聊天内容
 */
@property (nonatomic, copy) NSString *pm_text;
/**
 *  发送时间
 */
@property (nonatomic, copy) NSString *date;
/**
 *  信息的类型
 */
@property (nonatomic, assign) MJMessageType is_receice;

/**
 *  是否隐藏时间
 */
@property (nonatomic, assign) BOOL hideTime;

@property (nonatomic,strong) NSURL *urlPlay;   //信息中的语音 URL

@property (nonatomic, strong) UIImage *image;


+ (instancetype)messageWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end
