//
//  QYArticleTableViewController.h
//  Hallyu
//
//  Created by qingyun on 14-8-11.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"
#import "QYBBSHomeViewController.h"
@interface QYArticleTableViewController : UITableViewController
/*RTLabel *postTitle

//帖子图片 （大小暂定）

//录音位置
//帖子正文


*/
/*
 * BUGG 增加发布模块
 */
@property (nonatomic, strong) RTLabel *postTitle;
@property (nonatomic, strong) RTLabel *creat_at;
@property (nonatomic, strong) RTLabel *postText;
@property (nonatomic, strong) UIScrollView *postImage;
@property (nonatomic, strong) NSMutableDictionary *headViewOfData;
@property (nonatomic) int indexOfBBS;
@property (nonatomic, strong) NSMutableArray *collctOfArrForArticle;
@property (nonatomic, weak) QYBBSHomeViewController *QYBBS;
@property (nonatomic, strong) QYMyDBManager *dbBBS_comment;
@property (nonatomic, strong) NSMutableArray *arrOfDataForArticle;


@end
