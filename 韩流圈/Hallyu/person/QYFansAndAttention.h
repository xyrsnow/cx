//
//  QYFansAndAttention.h
//  Hallyu
//
//  Created by qingyun on 14-9-21.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYFansAndAttention : NSObject

@property (nonatomic, copy) NSString *userImage;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userDescription;
@property (nonatomic, copy) NSString *userStatusImg;

+ (instancetype)tgWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
