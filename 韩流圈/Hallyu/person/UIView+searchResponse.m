//
//  UIView+searchResponse.m
//  ShareShell
//
//  Created by 宁晓明 on 14-7-25.
//  Copyright (c) 2014年 com.shareShell. All rights reserved.
//

#import "UIView+searchResponse.h"

@implementation UIView (searchResponse)


- (UIViewController *)viewContreller
{
    UIResponder *controller = [self nextResponder];
    do {
        if ([controller isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)controller;
        }
        controller = [controller nextResponder];
    } while (controller != nil);
    
    return nil;
}

@end
