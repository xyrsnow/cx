//
//  QYStatuesTableViewCell.h
//  Hallyu
//
//  Created by qingyun on 14-8-11.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@interface QYStatuesTableViewCell : UITableViewCell

@property (nonatomic,strong) NSDictionary *messageCellData; //从API获取的cell的信息。
@property (nonatomic,strong) UILabel *titleLable;   //显示文章内容的头部信息，主要是文章的文章名。
@property (nonatomic,strong) UILabel *lableText;    //文章正文。
@property (nonatomic,strong) UIImageView *textImgView;  //文章中附带的图片。
@property (nonatomic,strong) UIImageView *lineView ;    //自定义的分割线
@property (nonatomic,strong) UILabel *timeLable;    //发布文章的时间。
@property (nonatomic,strong) RTLabel *sourceLable;  //发布文章的来源。
@property (nonatomic,strong) RTLabel *kindLable;    //发布文章所属的种类。


- (void)loadCellData:(NSDictionary *)dictionary;
@end
