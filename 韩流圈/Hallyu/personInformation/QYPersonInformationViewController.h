//
//  QYPersonInformationViewController.h
//  Hallyu
//
//  Created by qingyun on 14-8-12.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYPersonInformationViewController : UIViewController

@property (nonatomic, strong) NSDictionary *userInformationDic;

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, assign) BOOL isOtherUser;



@end
