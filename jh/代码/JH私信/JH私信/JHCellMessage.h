//
//  JHCellMessage.h
//  JH私信
//
//  Created by qingyun on 14-10-26.
//  Copyright (c) 2014年 JH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHCellMessage : NSObject

/**
 *  头像的frame
 */
@property (nonatomic, assign) CGRect iconFrame;
/**
 *  时间的frame
 */
@property (nonatomic, assign) CGRect timeFrame;
/**
 *  正文的frame
 */
@property (nonatomic, assign) CGRect textFrame;
/**
 *  cell的高度
 */
@property (nonatomic, assign) CGFloat cellHeight;
/**
 *  传过来的字典
 */
@property (nonatomic, strong) NSDictionary *messageDict;
/**
 *  是不是本人发送的信息
 */
@property (nonatomic, assign) BOOL sendPerson;
/**
 *  是否隐藏时间
 */
@property (nonatomic, assign, getter = isHideTime) BOOL hideTime;


@end
