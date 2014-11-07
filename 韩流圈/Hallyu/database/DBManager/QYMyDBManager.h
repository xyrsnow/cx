//
//  QYMyDBManager.h
//  Hallyu
//
//  Created by qingyun~sg on 14-10-7.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

#define kDataBaseName       @"Hallyu" //DB名字
#define kMessageMainTable   @"Message_main"
#define kMessageListTable   @"Message_List"//咨询列表
#define kMessageComment     @"Message_comment"//咨询评论
#define kMessageCollect     @"Message_collect"//资讯收藏
#define kBBSListTable       @"BBS_List"//BBS主页
#define kBBSThreadTable     @"thread"//BBS详情页
#define kBBSComment         @"BBS_Comment"//BBS评论
#define kPersonSetting      @"Person_Setting"//个人信息修改
#define kPersonMessageList  @"Person_Message_List"//聊天界面
#define kUserListTable      @"User_List"//用户信息

@interface QYMyDBManager : NSObject
{
    NSString *_name;
}

@property (nonatomic, strong)FMDatabase *myDB;
//通过单例创建数据库
+ (instancetype)shareInstance;

//保存咨询主页的信息
//保存BBS主页信息
- (void)saveMessageAndBBSListToDB:(NSString*)tableName withColumns:(NSDictionary *)dictionary;
//保存咨询详情页的信息
//保存BBS详情页信息
- (void)saveMessageAndBBSMainInfoToDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary;
//保存咨询评论信息
//保存BBS所有评论
- (void)saveMessageAndBBSCommentToDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary;
//保存资讯收藏信息
//保存BBS收藏信息
- (void)saveMessageAndBBSCollectToDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary;
//保存用户普通登录后返回的数据
//保存用户微博登录后返回的数据
- (void)saveUserInfoToDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary;
//从数据库中取出用户信息
- (NSArray *)messageQueryFromDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary;
- (NSArray *)userInfoQueryFromDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary;
- (NSArray *)bbsQueryFromDB:(NSString *)tableName;

//

//删除聊天
- (void)deletePersonMessageFromDB:(NSString *)tableName withColumns:(NSDictionary *)dictionary;
//删除缓存
- (void)deleteCacheFromDB;
//关闭数据库
- (void)close;

@end
