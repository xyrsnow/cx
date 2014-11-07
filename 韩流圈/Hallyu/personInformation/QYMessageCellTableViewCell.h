//
//  QYMassageCellTableViewCell.h
//  Hallyu
//
//  Created by qingyun on 14-9-1.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYMessageCellTableViewCell.h"
#import "RTLabel.h"
#import "UIViewExt.h"


@interface QYMessageCellTableViewCell : UITableViewCell

@property (nonatomic,retain)NSMutableDictionary *messageDic;

@property (nonatomic,retain)UILabel *MessageSubject;

@property (nonatomic,retain)UILabel *MessageTitle;

@property (nonatomic,retain)UILabel *MessageTime;



@property (nonatomic,retain)UILabel *MessageLookedCount;

@property (nonatomic,retain)UILabel *MessageSupportCount;

@property (nonatomic,retain)UILabel *MessageReplyCount;

@property (nonatomic,retain)UILabel *MessageCollectCount;



@property (nonatomic,retain)UILabel *MessageContent;


@end
