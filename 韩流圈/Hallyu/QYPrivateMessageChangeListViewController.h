//
//  QYPrivateMessageChangeListViewController.h
//  Hallyu
//
//  Created by qingyun on 14-9-21.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYPrivateMessageChangeListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *userID;
@end
