//
//  ViewController.m
//  JH私信
//
//  Created by qingyun on 14-10-26.
//  Copyright (c) 2014年 JH. All rights reserved.
//

#import "ViewController.h"
#import "JHCellMessage.h"
#import "JHCustomCell.h"

@interface ViewController ()

/**
 *  存放JHCellMessage对象
 */
@property (nonatomic, strong) NSMutableArray *messageArray;

@end

@implementation ViewController

#pragma mark - 信息的单条删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除数据
    [self.messageArray removeObjectAtIndex:indexPath.row];
    
    // UI（界面）上删除该行
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView reloadData];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //  跳转到最后一行
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
    if (self.messageArray.count > 2) {
        [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    self.tableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; //去除分割线
    self.tableView.allowsSelection = NO; //不允许选中
}

- (NSMutableArray *)messageArray
{
    if (!_messageArray) {
        NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"message.plist" ofType:nil]];
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSDictionary *dic in array) {
            JHCellMessage *cellMessage = [[JHCellMessage alloc] init];
            JHCellMessage *cellMessageLast = [tempArray lastObject];
            if ([cellMessageLast.messageDict[kTime] isEqualToString:dic[kTime]]) {
                cellMessage.hideTime = YES;
            } else {
                cellMessage.hideTime = NO;
            }
            cellMessage.messageDict = dic;
            [tempArray addObject:cellMessage];
        }
        self.messageArray = tempArray;
    }
    return _messageArray;
}

#pragma mark - tableView datasouce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JHCellMessage *cellMessage = self.messageArray[indexPath.row];
    return cellMessage.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"message";
    JHCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[JHCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.cellMessage = self.messageArray[indexPath.row];
    return cell;
}

@end
