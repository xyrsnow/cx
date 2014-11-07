//
//  QYMessageViewController.h
//  Hallyu
//
//  Created by jiwei on 14-8-9.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//
//查看资讯

#import <UIKit/UIKit.h>

@interface QYMessageViewController : UIViewController

//传入相应文章的图片
@property (nonatomic, strong) UIImage *articleImage;
@property (nonatomic, strong) NSMutableDictionary *articleInfo;
@property (nonatomic, strong) UIScrollView *messageImgScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *commentData;
@property (nonatomic, assign) NSInteger dataNum;

- (void)publishContens:(UIButton *)sender;
@end
