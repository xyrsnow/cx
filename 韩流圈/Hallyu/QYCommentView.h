//
//  QYCommentView.h
//  Hallyu
//
//  Created by qingyun on 14-9-1.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(BOOL, loginMes) {
    doLogin = YES,
    doRegister = NO
};

@protocol commentDelegate <NSObject>

- (void)loginOrRegisterWith:(loginMes)state;

@end

@interface QYCommentView : UIView
@property (nonatomic, strong) NSMutableArray *comInfo;
@property (nonatomic) BOOL loginState;
@property (nonatomic, weak) id<commentDelegate>delegate;
@property (nonatomic, strong) UITableView *comTableView;
@property (nonatomic, strong) UITextField *commentField;
- (id)initWithFrame:(CGRect)frame andComInfoArr:(NSArray *)infoArr;
- (void)keyboardDismiss;
@end
