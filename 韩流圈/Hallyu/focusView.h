//
//  focusView.h
//  HallyuTest
//
//  Created by qingyun on 14-8-11.
//  Copyright (c) 2014年 田超的个人工程. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ROLL_INTERVAL_TIME 2.0

@protocol focusViewDelegate <NSObject>
/**
 *  点击滚动图触发的事件
 *
 *  @param index 点击的第几个图
 */
- (void)tapFocusSrcollViewAtIndex:(NSInteger)index;

@end


@interface focusView : UIView

@property (nonatomic, strong) NSArray *focusTitleArr;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, weak) id<focusViewDelegate>delegate;

//初始化视图并传入图片数组，数组内容为UIImage
- (id)initWithFrame:(CGRect)frame withImageArray:(NSArray *)imgArr andStepTime:(NSTimeInterval)time;

//重新开启定时器
- (void)startTimer;
//注销定时器
- (void)stopTimer;

@end
