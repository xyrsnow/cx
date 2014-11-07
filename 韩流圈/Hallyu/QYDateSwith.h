//
//  QYDateSwith.h
//  Hallyu
//
//  Created by qingyun on 14-10-9.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYDateSwith : NSObject
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, assign) NSInteger second;

- (id)initWithDate:(NSString *) date;
+ (NSString *)dateSwithWithDate:(NSString *) myDate;
@end
