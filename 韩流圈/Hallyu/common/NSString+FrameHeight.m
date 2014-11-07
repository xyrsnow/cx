//
//  NSString+FrameHeight.m
//  SFWeiBoClicked
//
//  Created by qingyun on 14-7-26.
//  Copyright (c) 2014年 mapleaf. All rights reserved.
//

#import "NSString+FrameHeight.h"

@implementation NSString (FrameHeight)

//根据指定的显示视图宽度，和指定的字体大小，计算字符串所占的高度（像素）
//总体思路：行数 = 字符串的总长度 / 控件每一行显示的宽度 ;总高度 = 行数 * 单个字体的高度。
//注意：算法由于使用了向下取整，所以为了高度的准确，不能把第一步和第二步合并。
//第一个参数：fontSize：是字体的大小（默认的字体的宽度和字体的大小相等）。
//第二个参数：width：是控件的宽度（也就是设备上显示该section的宽度）
- (CGFloat)frameHeightWithFontSize:(CGFloat)fontSize forViewWith:(CGFloat)width
{
    NSDictionary *attributs = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [self sizeWithAttributes:attributs];
    //每一行可以显示的字数：控件的宽度 / 单个字体的宽度（向下取整）
    NSUInteger wordsPerLine = floor(width / fontSize);
    //每一行显示所使用的宽度（单个字体的宽度 * 每一行显示的字数）
    CGFloat widthPerLine = fontSize * wordsPerLine;
    //显示的行数，使用字符串的整体宽度 / 每一行的宽度
    NSUInteger nLines = ceil( size.width / widthPerLine );
    //根据字体的高度，获取字符串所占用的行高。
    CGFloat height = nLines * size.height;

    return height;
}
@end
