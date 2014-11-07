//
//  QYCommon.h
//  Hallyu
//
//  Created by jiwei on 14-8-12.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//


#pragma mark - （message组）
//根据不同屏幕的尺寸，获取当前屏幕的高度
#define AutoScreenHeight [UIScreen mainScreen].bounds.size.height
//评论信息文字大小
#define MESS_COMMENT_FONT_SIZE 15.0

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define kForiPhone5(a,b) (iPhone5 ? a : b)

#define SYSTEM_VERSTION_VALUE [[[UIDevice currentDevice] systemVersion] doubleValue]

#define  BASE_URL           @"http://1.hallyu.sinaapp.com"

//登陆
#define  LOGIN             [BASE_URL stringByAppendingString:@"/hlq_api/login/"]
#define  WEIBO_LOGIN       [BASE_URL stringByAppendingString:@"/hlq_api/weibo_login/"]

//资讯
#define  NEWS_LIST         [BASE_URL stringByAppendingString:@"/hlq_api/news/"]
#define  NEWS_ADDCOMMENTS  [BASE_URL stringByAppendingString:@"/hlq_api/addcomment/"]
#define  NEWS_COMMENTS     [BASE_URL stringByAppendingString:@"/hlq_api/comment/"]
#define  NEWS_COLLECT      [BASE_URL stringByAppendingString:@"/hlq_api/collect/"]
#define  NEWS_GETCOLLECT   [BASE_URL stringByAppendingString:@"/hlq_api/getcollect/"]

#define  BBS_LIST [BASE_URL stringByAppendingString:@"/hlq_api/thread/"]

//BBS
#define BBS_COMMENT_URL     [BASE_URL stringByAppendingString:@"/hlq_api/posts/"]
#define  BBS_WRITE          [BASE_URL stringByAppendingString:@"/hlq_api/addthread/"]
#define BBS_ADDANSWER_URL   [BASE_URL stringByAppendingString:@"/hlq_api/addpost/"]
#define BBS_COLLECT_URL     [BASE_URL stringByAppendingString:@"/hlq_api/collect/"]
#define BBS_ZAN_URL         [BASE_URL stringByAppendingString:@"/hlq_api/favor/"]
#define COMMENT_LIST        [BASE_URL stringByAppendingString:@"/hlq_api/comment/"]

//个人信息
#define PERSON_PROFILE               [BASE_URL stringByAppendingString:@"/hlq_api/profile/"]
#define PERSON_SEND                  [BASE_URL stringByAppendingString:@"/hlq_api/send_message/"]
#define PERSON_GET                   [BASE_URL stringByAppendingString:@"/hlq_api/get_message/"]
#define PERSON_DEL                   [BASE_URL stringByAppendingString:@"/hlq_api/del_message/"]
#define PERSON_FANSANDATTENTION_LIST [BASE_URL stringByAppendingString:@"/hlq_api/follower/"]
#define PERSON_ADD_FANS              [BASE_URL stringByAppendingString:@"/hlq_api/add_fans/"]
#define PERSON_READ_MESSAGE          [BASE_URL stringByAppendingString:@"/hlq_api/read_message/"]





