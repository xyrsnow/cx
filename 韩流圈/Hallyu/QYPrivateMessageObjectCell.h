//
//  QYPrivateMessageObjectCell.h
//  Hallyu
//
//  Created by qingyun on 14-9-21.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QYPrivateMessageObject;

@interface QYPrivateMessageObjectCell : UITableViewCell

/**
 *  通过一个tableView来创建一个cell
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView;

/**
 *  模型
 */
@property (nonatomic, strong) QYPrivateMessageObject *listObject;

@property (nonatomic, assign) BOOL isDeleteMessage;  //是否显示删除框

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (weak, nonatomic) IBOutlet UIButton *iconButton;

@end




