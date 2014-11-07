//
//  QYAnswerTableViewCell.h
//  Hallyu
//
//  Created by qingyun on 14-8-11.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYButton.h"
@interface QYAnswerTableViewCell : UITableViewCell

@property(nonatomic,strong)NSDictionary *cellData;
   /*
    * BUG
    */
@property (nonatomic, strong) ZYButton *btnOfCollect;
@property (nonatomic, strong) ZYButton *btnOfChat;
@property (retain, nonatomic) UIButton *shenglue;
@property (nonatomic) CGFloat highOfCell;

+(float) cellHeight:(NSDictionary *)data;

@end
