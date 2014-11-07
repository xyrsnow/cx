//
//  QYPersonChooseTableViewCell.h
//  Hallyu
//
//  Created by qingyun on 14-8-29.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QYPersonChooseTableViewCell;

//定义一个协议//定义协议名
@protocol QYPersonChooseTableViewCellCellDelegate  <NSObject>


//这里的协议方法，完全可以一个，但是图偷懒，这里用了三个
-(void)statuesTableViewCell:(QYPersonChooseTableViewCell *)cell reloadPublishMessgae:(UIGestureRecognizer *)gesture;

-(void)statuesTableViewCell:(QYPersonChooseTableViewCell *)cell  reloadReplyMessgae:(UIGestureRecognizer *)gesture;

-(void)statuesTableViewCell:(QYPersonChooseTableViewCell *)cell reloadCollectMessgae:(UIGestureRecognizer *)gesture;
@end


@interface QYPersonChooseTableViewCell : UITableViewCell

@property (nonatomic,retain)NSMutableArray *allCount;

@property (nonatomic,retain)NSMutableArray *chooseState;

@property (nonatomic,retain)UIImageView *publish;

@property (nonatomic,retain)UIImageView *reply;

@property (nonatomic,retain)UIImageView *collect;

@property (nonatomic,retain)UILabel *publishLab;

@property (nonatomic,retain)UILabel *replyLab;

@property (nonatomic,retain)UILabel *collectLab;

//QYPersonChooseTableViewCell对象的代理对象必须遵守QYPersonChooseTableViewCellDelegate协议
//又因为，不确定到底是哪个类做为此cell的代理， 所以代理的类型是id,但是有一点是清楚的， 就是这个类必须遵守代理协议
@property (nonatomic,assign) id<QYPersonChooseTableViewCellCellDelegate> delegate;



@end
