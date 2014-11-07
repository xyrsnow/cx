//
//  UITableViewController+Addtions.h
//  Money Monitor
//
//  Created by YQ006 on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewController (Additions)

- (NSInteger) typeForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *) indexPathForType:(NSInteger)type;

- (void) loadData;

@end
