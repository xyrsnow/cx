//
//  QYPersonInformationTableViewCell.h
//  Hallyu
//
//  Created by qingyun on 14-8-12.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYPersonInformationTableViewCell : UITableViewCell

@property (nonatomic,retain)NSDictionary *messageData;

@property (nonatomic,retain)UILabel *messageTitle;

@property (nonatomic,retain)UILabel *messageTime;

@property (nonatomic)BOOL isHiddenDate;

@end
