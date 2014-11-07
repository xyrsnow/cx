//
//  QYFansAndAttentionTableViewCell.h
//  Hallyu
//
//  Created by qingyun on 14-9-3.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QYFansAndAttention;

@interface QYFansAndAttentionTableViewCell : UITableViewCell

//@property (strong, nonatomic) NSDictionary *userInfo;

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userDescription;
@property (weak, nonatomic) IBOutlet UIButton *userStatusImg;

@property (strong, nonatomic)QYFansAndAttention *fansAndAttention;


+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end
