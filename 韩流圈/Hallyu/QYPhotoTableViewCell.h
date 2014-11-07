//
//  QYPhotoTableViewCell.h
//  Hallyu
//
//  Created by 张毅 on 14-9-28.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYButton.h"

@interface QYPhotoTableViewCell : UITableViewCell
@property (nonatomic) CGFloat highOfCell;

@property(nonatomic,strong)NSDictionary *cellData;
@property (nonatomic, strong) UIButton *btnOfCollect;
@property (nonatomic, strong) ZYButton *btnOfChat;
@property (retain, nonatomic) UIButton *shenglue;
@property (nonatomic) CGFloat highOfCellWithPhoto;

@end
