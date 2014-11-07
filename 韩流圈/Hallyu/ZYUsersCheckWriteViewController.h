//
//  ZYUsersCheckWriteViewController.h
//  Hallyu
//
//  Created by Zhang's on 14-9-24.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ZYUsersCheckWriteViewController : UIViewController
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) AVAudioPlayer *avPlayTest;
@property (nonatomic, strong)  NSURL *url;

@property (nonatomic, strong) NSMutableDictionary *av_photoArray_Title_Content;


@end
