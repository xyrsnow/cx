//
//  QYSettingPersonInformationViewController.h
//  Hallyu
//
//  Created by qingyun on 14-8-12.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYpersonView.h"

@interface QYSettingPersonInformationViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITableView *SettingPersonInfortation;

@property (nonatomic,retain)QYpersonView *personView;

@property (nonatomic,retain)UIImageView *UsersHeadImage;


@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UIButton *sexButton;
@property (nonatomic, strong) UITextField *addressField;
@property (nonatomic, strong) UITextField *mySignField;

@property (nonatomic, assign) BOOL isFromRegister;  // 是否从登录界面跳进

@property (nonatomic, strong) NSString *userID;


@end
