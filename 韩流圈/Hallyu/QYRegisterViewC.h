//
//  QYRegisterViewC.h
//  Hallyu
//
//  Created by qingyun on 14-9-3.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYRegisterViewC : UIViewController

@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *makeSureBtn;

- (void)doMakerSuerAction:(UIButton *)sender;
- (void)hideKeyBoard;
@end
