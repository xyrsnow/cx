//
//  QYPersonTableViewCell2.h
//  Hallyu
//
//  Created by qingyun on 14-9-4.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QYPersonTableViewCell2;

//定义一个协议//定义协议名
@protocol QYPersonTableViewCell2CellDelegate  <NSObject>


//这里的协议方法，完全可以一个，但是图偷懒，这里用了两个
-(void)statuesTableViewCell:(QYPersonTableViewCell2 *)cell reloadOthersPublishMessgae:(UIGestureRecognizer *)gesture;

-(void)statuesTableViewCell:(QYPersonTableViewCell2 *)cell reloadOthersReplyMessgae:(UIGestureRecognizer *)gesture;

@end



@interface QYPersonTableViewCell2 : UITableViewCell

@property (nonatomic,retain)NSMutableArray *allCount;

@property (nonatomic,retain)NSMutableArray *chooseState;

@property (nonatomic,retain)UIImageView *publish;

@property (nonatomic,retain)UIImageView *reply;


@property (nonatomic,retain)UILabel *publishLab;

@property (nonatomic,retain)UILabel *replyLab;


//QYPersonChooseTableViewCell对象的代理对象必须遵守QYPersonChooseTableViewCellDelegate协议
//又因为，不确定到底是哪个类做为此cell的代理， 所以代理的类型是id,但是有一点是清楚的， 就是这个类必须遵守代理协议
@property (nonatomic,assign) id<QYPersonTableViewCell2CellDelegate> delegate;


@end
