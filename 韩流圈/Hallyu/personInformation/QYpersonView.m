//
//  QYpersonView.m
//  Hallyu
//
//  Created by qingyun on 14-8-29.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYpersonView.h"

#import "UIViewExt.h"
#import "QYPersonCommon.h"
#import "UIView+searchResponse.h"

#import "QYFansViewController.h"
#import "QYAttentionViewController.h"
#import "QYPrivateMessageChangeListViewController.h"
#import "QYDetailPrivateMessageViewController.h"
#import "UIImageView+AFNetworking.h"


@implementation QYpersonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        QYUserSingleton *singLeton = [QYUserSingleton sharedUserSingleton];
        self.phone = singLeton.phoneNum;
        self.password = singLeton.passcode;
        self.myDB = [QYMyDBManager shareInstance];
    }
    return self;
}

//从服务器端获取数据
- (void)downLoadDataSource
{
    
    NSArray *array = [self.myDB userInfoQueryFromDB:kPersonSetting withColumns:nil];
    if (array.count != 0) {
        self.personDict = array[0];
        [self setupPersonView];
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *parameters = @{@"phone": _phone, @"passcode": _password};
        
        //    NSDictionary *parameters = @{@"user_id": userID};
        // 设置请求格式
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        // 设置返回格式
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager POST:LOGIN parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSLog(@"%@",[[responseObject objectForKey:@"errors"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
            NSLog(@"%@",operation.responseString);
            if ([[responseObject objectForKey:@"success"] doubleValue]) {
                self.personDict = [NSDictionary dictionaryWithDictionary:[responseObject objectForKey:@"data"]];
                [self setupPersonView];
                
                // 发送通知
                [QYNSDC postNotificationName:@"personViewDidLoad" object:nil userInfo:nil];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

- (void)setupPersonView
{
    CGFloat interWidth = 10.0f;
    
    self.frame = CGRectMake(0, 0, 320, 104.5);
    UIImageView *backgroundImg = [[UIImageView alloc]initWithFrame:self.bounds];
    
    backgroundImg.image = [UIImage imageNamed:@"3.jpg"];
    
    // 类似蒙板使文字清晰
    UIView *view = [[UIView alloc] initWithFrame:backgroundImg.frame];
    view.backgroundColor = [UIColor darkGrayColor];
    view.alpha = 0.7;
    [self addSubview:view];
    
    //  创建用户头像视图并配置相关属性
    _headImage= [[UIImageView alloc]initWithFrame:CGRectMake(10, 10,  84.5,84.5)];

//    [_headImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,[self.personDict objectForKey:@"icon_url"]]]];
    
    NSString *string =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *file = [string stringByAppendingString:@"/image.jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:file];
    if (!image) {
        _headImage.image = [UIImage imageNamed:@"other"];
    } else {
        _headImage.image = image;
    }
    [self addSubview:backgroundImg];
    
    [_headImage.layer setCornerRadius:CGRectGetHeight([_headImage bounds]) / 2];
    _headImage.layer.masksToBounds = YES;
    
    _headName=[[RTLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImage.frame)+interWidth, _headImage.frame.origin.y+10, 120, 20)];
    _headName.text = [self.personDict objectForKey:@"nickname"];
    _headName.textColor = [UIColor whiteColor];
    //  系统默认的加粗类型
    _headName.font = [UIFont boldSystemFontOfSize:kTitleFontSize];
    
    //  性别
    _sex = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headName.frame)+interWidth, _headName.frame.origin.y + 4, 15, 15)];
    
//    _sexIndicate = [NSString stringWithFormat:@"%ld",[[self.personDict objectForKey:@"gender"] longValue]];
    _sexIndicate = [NSString stringWithFormat:@"%@", [self.personDict objectForKeyedSubscript:@"gender"]];
    
    if ([_sexIndicate isEqualToString:@"1"]) {
        _sex.image = [UIImage imageNamed:@"man"];
    } else {
        _sex.image = [UIImage imageNamed:@"woman"];
    }
    
    //  地址
    _headAddress = [[RTLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_sex.frame) + 20, _sex.frame.origin.y , 70, 20)];
    _headAddress.textColor = [UIColor whiteColor];
    _headAddress.font = [UIFont boldSystemFontOfSize:14.0];
    _headAddress.text = [self.personDict objectForKey:@"address"];
    
    //  简介
    _headIntroduce = [[RTLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImage.frame)+interWidth, CGRectGetMaxY(_headName.frame)+7, 200, 14)];
    _headIntroduce.textColor = [UIColor lightGrayColor];
    _headIntroduce.font = [UIFont boldSystemFontOfSize:12.0f];
    _headIntroduce.text = [self.personDict objectForKey:@"description"];
    
    //   粉丝
    UIView *fans = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImage.frame)+interWidth, CGRectGetMaxY(_headIntroduce.frame)+5, 72, 35)];
    [self addSubview:fans];
    
    UITapGestureRecognizer *tapFans =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(retuenFansView:)];
    [fans addGestureRecognizer:tapFans];
    
    UILabel *fansNumber = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 72, 15)];
    fansNumber.textColor =[UIColor whiteColor];
    fansNumber.font =[UIFont boldSystemFontOfSize:14.0f];
    fansNumber.text = [NSString stringWithFormat:@"%ld",[[self.personDict objectForKey:@"followers_count"] longValue]];
    fansNumber.textAlignment = NSTextAlignmentCenter;
    [fans addSubview:fansNumber];
    
    UILabel *fansText = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 72, 10)];
    fansText.textColor =[UIColor lightGrayColor];
    fansText.font =[UIFont boldSystemFontOfSize:10.0f];
    fansText.text =@"粉丝";
    fansText.textAlignment = NSTextAlignmentCenter;
    [fans addSubview:fansText];
    
    
    //  关注
    UIView *attentions = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImage.frame)+interWidth+fans.bounds.size.width, CGRectGetMaxY(_headIntroduce.frame)+5, 72, 35)];
    [self addSubview:attentions];
    UITapGestureRecognizer *tapAttentions =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(retuenAttentionView:)];
    [attentions addGestureRecognizer:tapAttentions];
    
    UILabel *attentionsNumber = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 72, 15)];
    attentionsNumber.textColor =[UIColor whiteColor];
    attentionsNumber.font =[UIFont boldSystemFontOfSize:14.0f];
    attentionsNumber.text = [NSString stringWithFormat:@"%ld",[[self.personDict objectForKey:@"favourites_count"] longValue]];
    attentionsNumber.textAlignment = NSTextAlignmentCenter;
    [attentions addSubview:attentionsNumber];
    
    UILabel *attentionsText = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 72, 10)];
    attentionsText.textColor =[UIColor lightGrayColor];
    attentionsText.font =[UIFont boldSystemFontOfSize:10.0f];
    attentionsText.text =@"关注";
    attentionsText.textAlignment = NSTextAlignmentCenter;
    [attentions addSubview:attentionsText];
    
    if (self.isOtherUserInfo) {
        
        attentions.userInteractionEnabled = NO;
        fans.userInteractionEnabled = NO;
        
        UIView *sendMessage = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImage.frame)+interWidth+attentions.bounds.size.width*2, CGRectGetMaxY(_headIntroduce.frame)+5, 71, 35)];
        [self addSubview:sendMessage];
        
        UITapGestureRecognizer *tapSendMessage =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(retuenPersonList:)];
        [sendMessage addGestureRecognizer:tapSendMessage];
        
        UILabel *personsmessageCount = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 72, 15)];
        personsmessageCount.textColor =[UIColor whiteColor];
        personsmessageCount.font =[UIFont boldSystemFontOfSize:14.0f];
        personsmessageCount.text =@"联系Ta";
        personsmessageCount.textAlignment = NSTextAlignmentCenter;
        [sendMessage addSubview:personsmessageCount];
        
        UILabel *personsmessageText = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 72, 10)];
        personsmessageText.textColor =[UIColor lightGrayColor];
        personsmessageText.font =[UIFont boldSystemFontOfSize:10.0f];
        personsmessageText.text =@"私信箱";
        personsmessageText.textAlignment = NSTextAlignmentCenter;
        [sendMessage addSubview:personsmessageText];
        
    }else{
        UIView *personsmessage = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImage.frame)+interWidth+attentions.bounds.size.width*2, CGRectGetMaxY(_headIntroduce.frame)+5, 71, 35)];
        [self addSubview:personsmessage];
        
        UITapGestureRecognizer *tapPersonsmessage =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(retuenPersonList:)];
        [personsmessage addGestureRecognizer:tapPersonsmessage];
        
        UILabel *personsmessageCount = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 72, 15)];
        personsmessageCount.textColor =[UIColor whiteColor];
        personsmessageCount.font =[UIFont boldSystemFontOfSize:14.0f];
        personsmessageCount.text =@"8,234";
        personsmessageCount.textAlignment = NSTextAlignmentCenter;
        [personsmessage addSubview:personsmessageCount];
        
        UILabel *personsmessageText = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 72, 10)];
        personsmessageText.textColor =[UIColor lightGrayColor];
        personsmessageText.font =[UIFont boldSystemFontOfSize:10.0f];
        personsmessageText.text =@"私信箱";
        personsmessageText.textAlignment = NSTextAlignmentCenter;
        [personsmessage addSubview:personsmessageText];
    }
    [self addSubview:_headImage];
    [self addSubview:_headName];
    [self addSubview:_sex];
    [self addSubview:_headAddress];
    [self addSubview:_headIntroduce];
}

-(void)retuenFansView:(UIButton *)sender
{
    NSLog(@"粉丝");
    QYFansViewController *fans = [[QYFansViewController alloc]init];
    fans.hidesBottomBarWhenPushed = YES;
    
    
    UILabel *TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    TitleLabel.font = [UIFont systemFontOfSize:17];
    TitleLabel.text = @"粉丝名单";
    TitleLabel.textColor = [UIColor whiteColor];
    TitleLabel.textAlignment = NSTextAlignmentCenter;
    fans.navigationItem.titleView = TitleLabel;
    
    [self.viewContreller.navigationController pushViewController:fans animated:YES];
}

-(void)retuenAttentionView:(UIButton *)sender
{
    QYAttentionViewController *attention = [[QYAttentionViewController alloc]init];
    attention.hidesBottomBarWhenPushed = YES;
    
    UILabel *TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    TitleLabel.font = [UIFont systemFontOfSize:17];
    TitleLabel.text = @"关注名单";
    TitleLabel.textColor = [UIColor whiteColor];
    TitleLabel.textAlignment = NSTextAlignmentCenter;
    attention.navigationItem.titleView = TitleLabel;

    [self.viewContreller.navigationController pushViewController:attention animated:YES];
}
-(void)retuenPersonList:(UIButton *)sender
{
    if (self.isOtherUserInfo) {
        
        QYDetailPrivateMessageViewController *sendPritateMessage = [[QYDetailPrivateMessageViewController alloc]init];
        sendPritateMessage.hidesBottomBarWhenPushed = YES;
        sendPritateMessage.linkmanID = self.userIDNum;
        //  设置title
        UILabel *TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        TitleLabel.font = [UIFont systemFontOfSize:17];
        TitleLabel.text = _headName.text;
        TitleLabel.textColor = [UIColor whiteColor];
        TitleLabel.textAlignment = NSTextAlignmentCenter;
        sendPritateMessage.navigationItem.titleView = TitleLabel;
        [self.viewContreller.navigationController pushViewController:sendPritateMessage animated:YES];
    
    } else {
        
        QYPrivateMessageChangeListViewController *personMessageList = [[QYPrivateMessageChangeListViewController alloc]init];
        personMessageList.hidesBottomBarWhenPushed = YES;

        UILabel *TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        TitleLabel.font = [UIFont systemFontOfSize:17];
        TitleLabel.text = @"私信箱";
        TitleLabel.textColor = [UIColor whiteColor];
        TitleLabel.textAlignment = NSTextAlignmentCenter;
        personMessageList.navigationItem.titleView = TitleLabel;
        
        [self.viewContreller.navigationController pushViewController:personMessageList animated:YES];
    }
}

@end
