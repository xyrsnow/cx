//
//  QYUserGuideViewController.m
//  Hallyu
//
//  Created by qingyun on 14-9-22.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYUserGuideViewController.h"
#import "QYRootViewController.h"

#define kCount 3   // 指引界面的图片数

@interface QYUserGuideViewController () <UIScrollViewDelegate>

@end

@implementation QYUserGuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createScrollView];

}

- (void)createScrollView
{
    // scrollView 创建
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    for (int i = 0; i < kCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(i * width, 0, width, height);
        imageView.userInteractionEnabled = YES;
        NSString *imgName = [NSString stringWithFormat:@"0%d.jpg", i + 1];
        imageView.image = [UIImage imageNamed:imgName];
        if (i == (kCount - 1)) {
            UIButton *startBtn = [[UIButton alloc] initWithFrame:CGRectMake(85, 150, 150, 50)];
            startBtn.backgroundColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1];
            [startBtn setTitle:@"现在体验" forState:UIControlStateNormal];
            [startBtn addTarget:self action:@selector(startUseApp:) forControlEvents:UIControlEventTouchDown];
            [imageView addSubview:startBtn];
        }
        [_scrollView addSubview:imageView];
    }
    _scrollView.contentSize = CGSizeMake(width * kCount, 0);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    
    
    // pageControl 创建
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.center = CGPointMake(width * 0.5, height - 20);
    _pageControl.bounds = CGRectMake(0, 0, 150, 50);
    _pageControl.numberOfPages = kCount;
    _pageControl.pageIndicatorTintColor = [UIColor redColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    _pageControl.enabled = NO;
    
    [self.view addSubview:_scrollView];
    [self.view addSubview:_pageControl];
}


// 引导界面将状态栏隐藏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

// 跳转到登录界面
- (void)startUseApp:(UIButton *)sender
{
    
    QYRootViewController *rootVC = [[QYRootViewController alloc] init];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:rootVC animated:YES];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    int page = scrollView.contentOffset.x / scrollView.frame.size.width + 0.5;
    // 设置页码
    _pageControl.currentPage = page ;
}

@end






