//
//  QYPopularTableViewCell.h
//  Hallyu
//
//  Created by 泰坦虾米 on 14/9/1.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"
#import "UIViewExt.h"
@interface QYPopularTableViewCell : UITableViewCell
/*
 * BUG  头像控件属性改称UIButton
 */
@property (retain, nonatomic) UIButton *avatarImage;
@property (retain, nonatomic) RTLabel *userName;
@property (retain, nonatomic) RTLabel *creatAt;
@property (retain, nonatomic) UILabel *postTitle;
@property (retain, nonatomic) UIButton *favoritesBtn;
@property (retain, nonatomic) RTLabel *replyLable;


@property (nonatomic, retain) NSDictionary *cellData;
@property (nonatomic) BOOL isCollect;

@end
