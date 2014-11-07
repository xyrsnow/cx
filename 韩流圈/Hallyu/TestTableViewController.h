//
//  TestTableViewController.h
//  Hallyu
//
//  Created by 张毅 on 14-9-28.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestTableViewController : UITableViewController
- (id)initWithObject:(id)onePerson;
- (void)modify;
@property (nonatomic, strong) id oneObject;
@end
