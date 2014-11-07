//
//  JHCustomCell.h
//  JH私信
//
//  Created by qingyun on 14-10-26.
//  Copyright (c) 2014年 JH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHCellMessage.h"

@interface JHCustomCell : UITableViewCell

/**
 *  时间
 */
@property (nonatomic, strong) UILabel *timeView;
/**
 *  头像
 */
@property (nonatomic, strong) UIImageView *iconView;
/**
 *  内容
 */
@property (nonatomic, strong) UIButton *textView;
/**
 *  frame及数据
 */
@property (nonatomic, strong) JHCellMessage *cellMessage;



@end

