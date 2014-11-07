//
//  QYDateSwith.m
//  Hallyu
//
//  Created by qingyun on 14-10-9.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYDateSwith.h"
typedef NS_ENUM(int, timeFromNow){
    JUSTNOW = 10,
    SECONDS = 60,
    MINUTES = 60*60,
    HOURS = 60*60*60,
    DAYS = 60*60*60*24
};

@implementation QYDateSwith

- (id)initWithDate:(NSString *)date
{
    self = [super init];
    if (self) {
        NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
        [dateFormate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormate setCalendar:[NSCalendar currentCalendar]];
        NSDate *dateFromString = [dateFormate dateFromString:date];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:dateFromString];
        self.year = [components year];
        self.month = [components month];
        self.day = [components day];
        self.hour = [components hour];
        self.minute = [components minute];
        self.second = [components second];
    }
    return self;
}

+ (NSString *)dateSwithWithDate:(NSString *) myDate
{
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
    [dateFormate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormate setCalendar:[NSCalendar currentCalendar]];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:[dateFormate dateFromString:myDate]];
    NSDate *localeDate = [[dateFormate dateFromString:myDate]  dateByAddingTimeInterval: interval];
   // NSDate *dateFromString = [dateFormate dateFromString:myDate];
    //NSTimeInterval tim = [localeDate timeIntervalSinceNow];
    NSTimeInterval time = abs((int)[localeDate timeIntervalSinceNow]);
    
    NSString *string = nil;
    if (time < JUSTNOW) {
        string = @"刚刚";
    }else if (time < SECONDS){
        string = [NSString stringWithFormat:@"%.f秒前",time];
    }else if (time < MINUTES){
        string = [NSString stringWithFormat:@"%.f分钟前",time/60];
    }else if (time < HOURS){
        string = [NSString stringWithFormat:@"%.f小时前",time/60/60];
    }else{
        string = [NSString stringWithFormat:@"%.f天前",time/60/60/24];
    }
    return string;
}
@end
