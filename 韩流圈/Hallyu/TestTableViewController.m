//
//  TestTableViewController.m
//  Hallyu
//
//  Created by 张毅 on 14-9-28.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "TestTableViewController.h"

@interface TestTableViewController ()

@end

@implementation TestTableViewController



- (id)initWithObject:(id)onePerson
{
    self = [super init];
    if (self) {
        _oneObject = onePerson;
    }
    return self;
}


- (void)modify
{
    [self.oneObject setValue:@"liudehua" forKey:@"name"];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 0;
}


@end
