//
//  NSString+FrameHeight.h
//  SFWeiBoClicked
//
//  Created by qingyun on 14-7-26.
//  Copyright (c) 2014年 mapleaf. All rights reserved.
//

#import <Foundation/Foundation.h>
//这里创建的是一个类别，在这里只可添加处理方法。
@interface NSString (FrameHeight)
- (CGFloat)frameHeightWithFontSize:(CGFloat)fontSize forViewWith:(CGFloat)width;
@end
