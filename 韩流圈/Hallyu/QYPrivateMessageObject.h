//
//  QYPrivateMessageObject.h
//  Hallyu
//
//  Created by qingyun on 14-9-21.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYPrivateMessageObject : NSObject

@property (nonatomic, copy) NSString *linkman_nickname;
@property (nonatomic, copy) NSString *last_message;
@property (nonatomic, copy) NSString *last_date;
@property (nonatomic, copy) NSString *linkman_icon_url;
@property (nonatomic, copy) NSString *linkman_id;

@property (nonatomic, assign) BOOL isChoiceDelete;  //是否点击删除按钮

+ (instancetype)listWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
