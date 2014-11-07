//
//  QYFansAndAttentionTableViewCell.m
//  Hallyu
//
//  Created by qingyun on 14-9-3.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYFansAndAttentionTableViewCell.h"
#import "QYFansAndAttention.h"
#import "personConstDefine.h" 

@interface QYFansAndAttentionTableViewCell()<UIAlertViewDelegate>

@end

@implementation QYFansAndAttentionTableViewCell

+ (instancetype)cellWithTableView:(UITableView*)tableView
{
    static NSString *ID = @"fansAndAttionCell";
    QYFansAndAttentionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
//        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"QYFansAndAttentionTableViewCell" owner:self options:nil];
//        cell = views[0];
//       xib中获取自定义cell
        cell = [[[NSBundle mainBundle]loadNibNamed:@"QYFansAndAttentionTableViewCell" owner:nil options:nil]lastObject];
    }
    return cell;
}

- (void)setFansAndAttention:(QYFansAndAttention *)fansAndAttention
{
    [self initImgAndLabel];
    _fansAndAttention = fansAndAttention;
    //头像
    self.userImage.layer.cornerRadius = 22.5f;
    self.userImage.layer.masksToBounds = YES;
    self.userImage.image = [UIImage imageNamed:fansAndAttention.userImage];
    //用户名
    self.userName.text = fansAndAttention.userName;
    //个性签名
    self.userDescription.text = fansAndAttention.userDescription;
    //用户关注状态
    [self.userStatusImg setImage:nil forState:UIControlStateNormal];//初始化时，将它置为nil

    [self.userStatusImg setImage:[UIImage imageNamed:self.fansAndAttention.userStatusImg] forState:UIControlStateNormal];
}

- (void)addFans
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *parameters = @{@"user_id":@2,@"follow_id":@94,@"action":@1};
    [manager POST:PERSON_ADD_FANS parameters:parameters success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSLog(@">>>>>>>>>>>>JSON:%@",responseObject);
        //        self.dictArray = [NSMutableArray arrayWithObject:[responseObject objectForKey:@"data"]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"error:%@",error);
    }];

}

- (void)initImgAndLabel
{
    self.userImage.image = nil;
    self.userName.text = nil;
    self.userDescription.text = nil;
    self.userStatusImg.imageView.image = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onClicked:(UIButton *)sender
{
//    NSString *str4Img = self.fansAndAttention.userStatusImg;
//    if ([str4Img isEqualToString:@"粉丝列表-关注"]) {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"确定要关注此人吗" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView show];
//    }else if([str4Img isEqualToString:@"粉丝列表-相互"]){
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"确定要取消关注吗" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView show];
//    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        NSString *str4Img = self.fansAndAttention.userStatusImg;
        if ([str4Img isEqualToString:@"粉丝列表-关注"]) {
            [self addFans];
            [self.userStatusImg setImage:[UIImage imageNamed:@"粉丝列表-相互"] forState:UIControlStateNormal];
        }else if ([str4Img isEqualToString:@"粉丝列表-相互"]){
            [self.userStatusImg setImage:[UIImage imageNamed:@"粉丝列表-关注"] forState:UIControlStateNormal];
        }
}
}

@end
