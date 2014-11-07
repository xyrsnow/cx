//
//  UITableViewController+Addtions.m
//  Money Monitor
//
//  Created by YQ006 on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewControllerAdditions.h"

@implementation UITableViewController (Additions)

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) typeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger type = 0;
    
    for (int i = 0; i < indexPath.section; ++i) {
        type += [self tableView:nil numberOfRowsInSection:i];
    }
    return type + row;
}

- (NSIndexPath *) indexPathForType:(NSInteger)type
{
    NSInteger sec = 0, row = type;
    while (row > 0) {
        NSInteger n = [self tableView:nil numberOfRowsInSection:sec];
        if (row >= n) {
            ++sec;
            row -= n;
        } else {
            break;
        }
    }
    return [NSIndexPath indexPathForRow:row inSection:sec];
}


- (void) setTableView:(UITableView *)tableView {
    [self.tableView removeFromSuperview];
    [self.view addSubview:tableView];
}

- (UITableView *) tableView {
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UITableView class]]) {
            return (UITableView *)v;
        }
    }
    return nil;
}


- (void) loadData { }

- (void) viewDidLoad {
    [super viewDidLoad];
    
	UITableView *t = (UITableView *)self.view;
    self.view = [[UIView alloc] init];

    t.frame = self.view.frame;
    self.tableView = t;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    
}

- (void) subViewShouldMoveWithOffset:(CGFloat)offset {
    CGRect frame = self.tableView.frame;
    frame.origin.y += offset;
    frame.size.height -= offset;
    self.tableView.frame = frame;
}


@end
