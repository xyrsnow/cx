//
//  TCGetImgSize.m
//  imgViewTest
//
//  Created by qingyun on 14-8-6.
//  Copyright (c) 2014年 田超的个人工程. All rights reserved.
//
/**
 *  通过这个类可以快速获得jpg、png和gif格式图片的大小
 */
#import "TCGetImgSize.h"

@implementation TCGetImgSize

+ (CGSize)quickGetImgSizeWithString:(NSString *)string
{
    CGSize retSize;
    NSURL *imgUrl = [NSURL URLWithString:string];
    if ([string hasSuffix:@"jpg"])
    {
        retSize = [self getJpgSizeWithURL:imgUrl];
    }
    else if ([string hasSuffix:@"png"])
    {
        retSize = [self getPngSizeWithURL:imgUrl];
    }
    else if ([string hasSuffix:@"gif"])
    {
        retSize = [self getGifSizeWithURL:imgUrl];
    }
    else
    {
        NSLog(@"Sorry! Can't recognition the file's type...");
        if (CGSizeEqualToSize(retSize, CGSizeZero)) {
            NSLog(@"图片读取失败");
        }
        retSize = CGSizeMake(0, 0);
    }
    return retSize;
}
+ (CGSize)getJpgSizeWithURL:(NSURL *)url
{
    NSMutableURLRequest *requset = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:INTERVAL_TIMEOUT];
    [requset setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:requset returningResponse:nil error:nil];
    
    if ([data length] <= 0x58)
    {
        return CGSizeZero;
    }
    if ([data length] < 210)
    {// 肯定只有⼀一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)]; [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)]; [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)]; short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    }
    else
    {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb)
        {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb)
            {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
            else
            {// ⼀一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        }
        else
        {
            return CGSizeZero;
        }
    }
    
}

+ (CGSize)getPngSizeWithURL:(NSURL *)url
{
    NSMutableURLRequest *requset = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:INTERVAL_TIMEOUT];
    [requset setValue:@"bytes=16-23" forKey:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:requset returningResponse:nil error:nil];
    
    int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
    [data getBytes:&w1 range:NSMakeRange(0, 1)];
    [data getBytes:&w2 range:NSMakeRange(1, 1)];
    [data getBytes:&w3 range:NSMakeRange(2, 1)];
    [data getBytes:&w4 range:NSMakeRange(3, 1)];
    int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
    int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
    [data getBytes:&h1 range:NSMakeRange(4, 1)];
    [data getBytes:&h2 range:NSMakeRange(5, 1)];
    [data getBytes:&h3 range:NSMakeRange(6, 1)];
    [data getBytes:&h4 range:NSMakeRange(7, 1)];
    int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
    return CGSizeMake(w, h);
}

+ (CGSize)getGifSizeWithURL:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:INTERVAL_TIMEOUT];
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (data.length > 4) {
        data = [data subdataWithRange:NSMakeRange(6, 4)];
    }
    short w1 = 0, w2 = 0;
    [data getBytes:&w1 range:NSMakeRange(0, 1)];
    [data getBytes:&w2 range:NSMakeRange(1, 1)];
    short w = w1 + (w2 << 8);
    short h1 = 0, h2 = 0;
    [data getBytes:&h1 range:NSMakeRange(2, 1)];
    [data getBytes:&h2 range:NSMakeRange(3, 1)];
    short h = h1 + (h2 << 8);
    return CGSizeMake(w, h);
}

@end
