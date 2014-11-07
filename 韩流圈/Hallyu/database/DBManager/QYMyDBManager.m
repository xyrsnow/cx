//
//  QYMyDBManager.m
//  Hallyu
//
//  Created by qingyun~sg on 14-10-7.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYMyDBManager.h"
#import "unifiedHeaderFile.h"

static QYMyDBManager *myDBManager;

@interface QYMyDBManager ()

//@property (nonatomic, strong) NSMutableArray  *array;
@property (nonatomic, strong) NSMutableDictionary *dict4Data;

@end

@implementation QYMyDBManager
//通过单例，创建数据库管理
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    //当第一个参数如果没有被初始过 则第二个参数(block)块将会被调用一次，反之，则代码将不会被调用
    dispatch_once(&onceToken, ^{
        myDBManager = [[QYMyDBManager alloc]init];
    });
    return myDBManager;
}

- (id)init
{
    self = [super init];
    //初始化数据库
    if (self) {
        
        NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *myDocument = [documents objectAtIndex:0];
        
        _name = [myDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.sqlite",kDataBaseName]];
        NSLog(@">>>>>>>>>>filePath:%@",_name);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL exit = [fileManager fileExistsAtPath:_name];
        if (!exit) {
            // 本地无此文件，则将此文件拷贝到本地目录。
            NSString *myDBFilePath = [[NSBundle mainBundle] pathForResource:kDataBaseName ofType:@"sqlite"];
            NSError *err;
            // 将Bundle中的文件拷贝至沙盒目录下
            [fileManager copyItemAtPath:myDBFilePath toPath:_name error:&err];
        }
        self.myDB = [FMDatabase databaseWithPath:_name];
    }
    [self.myDB open];
    return self;
}


- (void)saveMessageAndBBSListToDB:(NSString*)tableName withColumns:(NSDictionary *)dictionary
{
    NSMutableString *insertSQL = [[NSMutableString alloc]initWithString:@"INSERT INTO "];
    [insertSQL appendString:tableName];
    if ([tableName isEqualToString:kMessageListTable]) {
        [insertSQL appendString:@"(id,author,content,date,image,theme,title) VALUES (?,?,?,?,?,?,?)"];
        BOOL isOK = [self.myDB executeUpdate:insertSQL,
                     [dictionary objectForKey:@"id"],
                     [dictionary objectForKey:@"author"],
                     [dictionary objectForKey:@"content"],
                     [dictionary objectForKey:@"date"],
                     [[NSURL URLWithString:[dictionary objectForKey:@"image"]]lastPathComponent],
                     [dictionary objectForKey:@"theme"],
                      [dictionary objectForKey:@"titile"]
                      ];
        if (!isOK) {
            NSLog(@"保存失败,原因:%@",[self.myDB lastErrorMessage]);
        }else{
            NSLog(@"保存成功");
        }
    }else if([tableName isEqualToString:kBBSListTable]){
        [insertSQL appendString:@" (id,author,content,date,image,title) values(?,?,?,?,?,?)"];
        BOOL isOK = [self.myDB executeUpdate:insertSQL,
                     [dictionary objectForKey:@"id"],
                     [dictionary objectForKey:@"author"],
                     [dictionary objectForKey:@"content"],
                     [dictionary objectForKey:@"date"],
                     [[NSURL URLWithString:[dictionary objectForKey:@"image"]]lastPathComponent],
                     [dictionary objectForKey:@"titile"]];
        if (!isOK) {
            NSLog(@"保存失败,原因:%@",[self.myDB lastErrorMessage]);
        }else{
            NSLog(@"保存成功");
        }
    }else{
        NSLog(@"输入的表名有错");
    }
}

- (void)saveMessageAndBBSMainInfoToDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary
{
    [self.myDB open];
    NSMutableString *insertSQL = [[NSMutableString alloc]initWithString:@"INSERT INTO "];
    [insertSQL appendString:tableName];
    if ([tableName isEqualToString:kMessageMainTable]) {
    }else if([tableName isEqualToString:kBBSThreadTable]){
        [insertSQL appendString:@" (id,author,content,date,image,title) values(?,?,?,?,?,?)"];
        BOOL isOK = [self.myDB executeUpdate:insertSQL,
                     [dictionary objectForKey:@"bbs_id"],
                     [dictionary objectForKey:@"author"],
                     [dictionary objectForKey:@"content"],
                     [dictionary objectForKey:@"date"],
                     [[NSURL URLWithString:[dictionary objectForKey:@"image"]]lastPathComponent],
                     [dictionary objectForKey:@"title"]];
        if (!isOK) {
            NSLog(@"保存失败,原因:%@",[self.myDB lastErrorMessage]);
        }else{
            NSLog(@"保存成功");
        }
    }else{
        NSLog(@"输入的表名有错");
    }

}

- (void)saveMessageAndBBSCommentToDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary
{
    [self.myDB open];
    NSMutableString *insertSQL = [[NSMutableString alloc]initWithString:@"INSERT INTO "];
    [insertSQL appendString:tableName];
    if ([tableName isEqualToString:kMessageComment]) {
        [insertSQL appendString:@" (attitude_count,avatar_img,content_text,date,floor_num,message_id,user_id,user_name) values(?,?,?,?,?,?,?,?)"];
        BOOL isOK = [self.myDB executeUpdate:insertSQL,
                     [dictionary objectForKey:@"attitude_count"],
                     [[NSURL URLWithString:[dictionary objectForKey:@"avatar_img"]]lastPathComponent],
                     [dictionary objectForKey:@"content_text"],
                     [dictionary objectForKey:@"date"],
                     [dictionary objectForKey:@"floor_num"],
                     [dictionary objectForKey:@"message_id"],
                     [dictionary objectForKey:@"usr_id"],
                     [dictionary objectForKey:@"usr_name"]
                     ];
        if (!isOK) {
            NSLog(@"保存失败,原因:%@",[self.myDB lastErrorMessage]);
        }else{
            NSLog(@"保存成功");
        }
    }else if([tableName isEqualToString:kBBSComment]){
        [insertSQL appendString:@" (attitude_count,avatar_img,content_text,date,floor_num,iamge_url,sound_url,usr_id,usr_name,bbs_id,others) values(?,?,?,?,?,?,?,?,?,?,?)"];
        BOOL isOK = [self.myDB executeUpdate:insertSQL,
                     [dictionary objectForKey:@"attitude_count"],
                     [[NSURL URLWithString:[dictionary objectForKey:@"avatar_img"]]lastPathComponent],
                     [dictionary objectForKey:@"content_text"],
                     [dictionary objectForKey:@"date"],
                     [dictionary objectForKey:@"floor_num"],
                     [[NSURL URLWithString:[dictionary objectForKey:@"image_url"]]lastPathComponent],
                     [dictionary objectForKey:@"sound_url"],
                     [dictionary objectForKey:@"usr_id"],
                     [dictionary objectForKey:@"usr_name"],
                     [dictionary objectForKey:@"bbs_id"],
                     [dictionary objectForKey:@"others"]
                     ];
        if (!isOK) {
            NSLog(@"保存失败,原因:%@",[self.myDB lastErrorMessage]);
        }else{
            NSLog(@"保存成功");
        }
    }else{
        NSLog(@"输入的表名有错");
    }
}

- (void)saveMessageAndBBSCollectToDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary
{
    [self.myDB open];
    NSMutableString *insertSQL = [[NSMutableString alloc]initWithString:@"INSERT INTO "];
    [insertSQL appendString:tableName];
    if ([tableName isEqualToString:kMessageCollect]) {
        
        [insertSQL appendString:@" (user_id,message_id,iscollect) values(?,?,?)"];
        BOOL isOK = [self.myDB executeUpdate:insertSQL,
                     [dictionary objectForKey:@"user_id"],
                     [dictionary objectForKey:@"message_id"],
                     [dictionary objectForKey:@"iscollect"]
                     ];
        if (!isOK) {
            NSLog(@"保存失败,原因:%@",[self.myDB lastErrorMessage]);
        }else{
            NSLog(@"保存成功");
        }

    }else if ([tableName isEqualToString:@"BBS_collest"]){
    
    }else{
        NSLog(@"输入的表名有错");
    }
}


- (void)saveUserInfoToDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary
{
    [self.myDB open];

    NSMutableString *insertSQL = [[NSMutableString alloc]initWithString:@"INSERT INTO "];
    [insertSQL appendString:tableName];
    if ([tableName isEqualToString:kUserListTable]) {
        [insertSQL  appendString:@" (user_id,isSina,nickname,age,gender,address,description,icon,fav_count,follows_count,phoneNum,passcode,comment,collection,publish,isLogin) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"];
        BOOL isOk = [self.myDB executeUpdate:insertSQL,
                     [dictionary objectForKey:@"user_id"],
                     [dictionary objectForKey:@"isSina"],
                     [dictionary objectForKey:@"nickname"],
                     [dictionary objectForKey:@"age"],
                     [dictionary objectForKey:@"gender"],
                     [dictionary objectForKey:@"address"],
                     [dictionary objectForKey:@"description"],
                     [[NSURL URLWithString:[dictionary objectForKey:@"icon"]]lastPathComponent],
                     [dictionary objectForKey:@"fav_count"],
                     [dictionary objectForKey:@"follows_count"],
                     [dictionary objectForKey:@"phoneNum"],
                     [dictionary objectForKey:@"passcode"],
                     [dictionary objectForKey:@"comment"],
                     [dictionary objectForKey:@"collection"],
                     [dictionary objectForKey:@"publish"],
                     [dictionary objectForKey:@"isLogin"]
                     ];
        if (isOk) {
            NSLog(@"保存成功");
        }else{
            NSLog(@"保存失败，原因：%@",[self.myDB lastErrorMessage]);
        }
    }else{
        NSLog(@"输入表明有错！");
    }
            
    if ([tableName isEqualToString:kPersonSetting]) {
        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@", kPersonSetting];
        [self.myDB executeUpdate:deleteSQL];
        [insertSQL appendString:@" (user_id,gender,profile_image,nickname,address,description) values(?,?,?,?,?,?)"];
        BOOL isOK = [self.myDB executeUpdate:insertSQL,
                     [dictionary objectForKey:@"user_id"],
                     [dictionary objectForKey:@"gender"],
//                     [[NSURL URLWithString:[dictionary objectForKey:@"profile_image"]]lastPathComponent],
                     [dictionary objectForKey:@"profile_image"],
                     [dictionary objectForKey:@"nickname"],
                     [dictionary objectForKey:@"address"],
                     [dictionary objectForKey:@"description"]
                     ];
        if (!isOK) {
            NSLog(@"保存失败,原因:%@",[self.myDB lastErrorMessage]);
        }else{
            NSLog(@"保存成功");
        }
    }else if([tableName isEqualToString:kBBSComment]){

    }else{
        NSLog(@"输入的表名有错");
    }
}

- (NSArray *)messageQueryFromDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSMutableString *selectSQL = [[NSMutableString alloc]initWithString:@"SELECT * FROM "];
    [selectSQL appendString:tableName];
    if ([tableName isEqualToString:kMessageListTable]) {
        if (dictionary) {
            [selectSQL appendString:[NSString stringWithFormat:@" WHERE THEME = \"%@\" ORDER BY \"id\" DESC",dictionary[kTheme]]];
        }
        FMResultSet *set = [self.myDB executeQuery:selectSQL];
        while ([set next]) {
            NSDictionary *dict = @{kId: [NSNumber numberWithInt:[set intForColumn:@"id"]],
                                   kAuthor: [set stringForColumn:@"author"],
                                   kContent:  [set stringForColumn:@"content"],
                                   kDate: [set stringForColumn:@"date"],
                                   kImage: [set stringForColumn:@"image"],
                                   kTitle: [set stringForColumn:@"title"],
                                   kTheme: [set stringForColumn:@"theme"]

                                   };
            [array addObject:dict];
        }
    }else if ([tableName isEqualToString:kMessageComment]){
            [selectSQL appendString:[NSString stringWithFormat:@" WHERE MESSAGE_ID = %@",dictionary[kId]]];
        FMResultSet *set = [self.myDB executeQuery:selectSQL];
        while ([set next]) {
            NSDictionary *dict = @{kAttitude_count: [set intForColumn:@"attitude_count"] ? [NSNumber numberWithInt:[set intForColumn:@"attitude_count"]] : @0,
                                   kAvatarImg: [set stringForColumn:@"avatar_img"],
                                   kContentText:  [set stringForColumn:@"content_text"] ? [set stringForColumn:@"content_text"] : @"",
                                   kDate: [set stringForColumn:@"date"],
                                   kFloorNum:[NSNumber numberWithInt:[set intForColumn:@"floor_num"]],
                                   kId: [NSNumber numberWithInt:[set intForColumn:@"message_id"]],
                                   kUserID: [NSNumber numberWithInt:[set intForColumn:@"user_id"]],
                                  kUserName: [set stringForColumn:@"user_name"]
                                   };
            [array addObject:dict];
        }
    }else if([tableName isEqualToString:kMessageCollect]){
        [selectSQL appendString:[NSString stringWithFormat:@" WHERE USER_ID = \"%@\" and MESSAGE_ID = \"%@\"",dictionary[kUserID],dictionary[kId]]];
    FMResultSet *set = [self.myDB executeQuery:selectSQL];
    while ([set next]) {
        NSDictionary *dict = @{kUserID: [NSNumber numberWithInteger:[set intForColumn:@"user_id"]],
                               kId: [NSNumber numberWithInteger:[set intForColumn:@"message_id"]],
                               kIsCollect: [NSNumber numberWithInteger:[set intForColumn:@"iscollect"]]
                               };
        [array addObject:dict];
    }
}
    return array;
}
- (NSArray *)userInfoQueryFromDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary
{
    [self.myDB open];
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    NSMutableString *selectSQL = [[NSMutableString alloc]initWithString:@"SELECT * FROM "];
    
    [selectSQL appendString:tableName];
    
    FMResultSet *set = [self.myDB executeQuery:selectSQL];
    
    while ([set next]) {
        NSDictionary *dict = @{@"user_id": [NSNumber numberWithInt:[set intForColumn:@"user_id"]],
                               @"gender": [NSNumber numberWithInt:[set intForColumn:@"gender"]],
                               @"nickname": [set stringForColumn:@"nickname"],
                               @"profile_image": [set dataForColumn:@"profile_image"],
                               @"address": [set stringForColumn:@"address"],
                               @"description": [set stringForColumn:@"description"]
                               };
        [array addObject:dict];
    }
    
    
    return array;
}
- (NSArray *)bbsQueryFromDB:(NSString *)tableName
{
    [self.myDB open];
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    NSMutableString *selectSQL = [[NSMutableString alloc]initWithString:@"SELECT * FROM "];
    
    [selectSQL appendString:tableName];
    
    FMResultSet *set = [self.myDB executeQuery:selectSQL];
    
    while ([set next]) {
        NSString *strReplace = nil;
        if ([set stringForColumn:@"author"]) {
            strReplace = [set stringForColumn:@"author"];
        }else{
            strReplace = @"";
        }
        NSDictionary *dict = @{@"bbs_id": [NSNumber numberWithInt:[set intForColumn:@"id"]],
                               @"date": [set stringForColumn:@"date"],
                               @"author": strReplace,
                               @"image":  [set stringForColumn:@"image"],
                               @"content": [set stringForColumn:@"content"],
                               @"title": [set stringForColumn:@"title"]
                               };
        [array addObject:dict];
    }
    
    return array;
}

- (void)deletePersonMessageFromDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary
{
    NSMutableString *deleteSQL = [[NSMutableString alloc]initWithString:@"DELETE FROM "];
    [deleteSQL appendString:tableName];
    [deleteSQL appendString:@"WHERE ?"];
    BOOL isOK = [_myDB executeUpdate:deleteSQL,
                  [dictionary objectForKey:@""]];
    if (!isOK) {
        NSLog(@"执行删除操作失败:%@",[_myDB lastErrorMessage]);
    }else{
        NSLog(@"执行删除成功");
    }
}

- (void)deleteCacheFromDB
{
    NSMutableString *deleteSQL = [[NSMutableString alloc]init];
    NSArray *array4Table = @[kMessageListTable,kMessageComment,kMessageCollect,kBBSComment,kBBSListTable,kBBSThreadTable,kPersonSetting,kPersonMessageList];
    for (NSString *tableName in array4Table)
    {
        [deleteSQL appendString:@"DELETE FROM "];
        [deleteSQL appendString:tableName];
        BOOL isOK = [_myDB executeUpdate:deleteSQL];
        if (!isOK) {
            NSLog(@"删除失败:%@",[_myDB lastErrorMessage]);
        }else{
            NSLog(@"删除执行操作成功");
        }
        [deleteSQL deleteCharactersInRange:NSMakeRange(0, deleteSQL.length)];
        
    }
}

- (void)close
{
    [_myDB close];
    myDBManager = nil;
}

@end
