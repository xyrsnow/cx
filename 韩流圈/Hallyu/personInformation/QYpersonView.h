//
//  QYpersonView.h
//  Hallyu
//
//  Created by qingyun on 14-8-29.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@interface QYpersonView : UIView

@property (nonatomic,strong)NSDictionary *userInformationDic;

@property (nonatomic,assign)BOOL isOtherUserInfo;

@property (nonatomic,retain)UIImageView *headImage;

@property (nonatomic,retain)RTLabel *headName;

@property (nonatomic, retain)RTLabel *headAddress;

@property (nonatomic, retain)RTLabel *headIntroduce;

@property (nonatomic, retain)UIImageView *sex;

@property (nonatomic, copy)NSString *sexIndicate;

@property (nonatomic, strong)NSDictionary *personDict; //数据字典

//数据库
@property (nonatomic, strong) QYMyDBManager *myDB;

@property (nonatomic, strong)NSString *userIDNum;      //用户ID
@property (nonatomic, strong)NSString *phone;
@property (nonatomic, strong)NSString *password;

- (void)downLoadDataSource;
- (void)setupPersonView;

@end
