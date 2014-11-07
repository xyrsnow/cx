//
//  ZYButton.m
//  Hallyu
//
//  Created by Zhang's on 14-9-22.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "ZYButton.h"

@implementation ZYButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.placeHolder = 1;
    }
    return self;
}


-(void)holder
{
    self.placeHolder = 1;
}

@end
