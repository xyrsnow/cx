//
//  QYSettingPersonInformationViewController.m
//  Hallyu
//
//  Created by qingyun on 14-8-12.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYSettingPersonInformationViewController.h"
#import "RTLabel.h"
#import "AFNetworking.h"
#import "MBProgressHUD+MJ.h"

@interface QYSettingPersonInformationViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UITextFieldDelegate>

@property (nonatomic, copy) NSString *sexString;

@property (nonatomic, assign) NSInteger selectRow;

@property (nonatomic, retain) NSString *saveStr;

@property (nonatomic, assign) BOOL isLoad;

//数据库
@property (nonatomic, strong) QYMyDBManager *myDB;

@end

@implementation QYSettingPersonInformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.myDB = [QYMyDBManager shareInstance];
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
    
    self.navigationController.navigationBarHidden = NO;
    
//  设置返回按钮
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemTapped:)];
    [leftBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"返回-press"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    //  设置title
    UILabel *TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    TitleLabel.font = [UIFont boldSystemFontOfSize:20];
    TitleLabel.text = @"个人信息";
    TitleLabel.textColor = [UIColor whiteColor];
    TitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    self.navigationItem.titleView = TitleLabel;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000];

    //  设置保存按钮
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"修改-确认"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemOnTapped:)];
    [rightBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"修改-确认"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [rightBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"修改-确认-press"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - 通知事件
- (void)onNotification
{
    [self.SettingPersonInfortation reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _SettingPersonInfortation.delegate = self;
    _SettingPersonInfortation.dataSource = self;
    
    [QYNSDC addObserver:self selector:@selector(onNotification) name:@"personViewDidLoad" object:nil];
    [self creatPersonInformationHeader];
}

- (void)dealloc
{
    [QYNSDC removeObserver:nil name:@"personViewDidLoad" object:nil];
}

//设置个人基本信息
-(void)creatPersonInformationHeader
{
    _personView = [[QYpersonView alloc] initWithFrame:CGRectMake(0, 0, 320, 104.5)];
    _personView.userIDNum = self.userID;
    [_personView downLoadDataSource];
    _SettingPersonInfortation.tableHeaderView = _personView;
    [_SettingPersonInfortation reloadData];    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 2;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 35;
    } else if (indexPath.row == 0) {
        return 58;
    } else {
        return 44;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0;

}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 0;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *section1Cell = @"section1Cell";
    
    static NSString *section2Cell = @"section2Cell";
    
    static NSString *section3Cell = @"section3Cell";
    

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:section1Cell];
    
    UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:section2Cell];
    
    
    if (indexPath.section == 0) {
        
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:section1Cell];
        
        UILabel *personSetting = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 300, 15)];
        personSetting.text = @"个人信息预览";
        personSetting.textColor = [UIColor grayColor];
        personSetting.font = [UIFont boldSystemFontOfSize:12.0f];
        personSetting.textAlignment = NSTextAlignmentCenter;
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:personSetting];
    
        return cell;
    
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        
        cell2 =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:section2Cell];
        
        UILabel *headImageLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 60, 18)];
        headImageLab.textColor = [UIColor grayColor];
        headImageLab.textAlignment = NSTextAlignmentLeft;
        headImageLab.text = @"头像";
        headImageLab.font = [UIFont boldSystemFontOfSize:14.0f];
        cell2.selectionStyle =  UITableViewCellSelectionStyleNone;
        [cell2.contentView addSubview:headImageLab];

        _UsersHeadImage = [[UIImageView alloc]initWithFrame:CGRectMake(245, 10, 38, 38)];
        _UsersHeadImage.image = _personView.headImage.image;
        cell2.accessoryView = _UsersHeadImage;

        return cell2;
   
    } else {
        
        switch (indexPath.row ) {
            case 1:
            {
                UITableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:section3Cell];
                cell3 =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:section3Cell];
                UILabel *backImageLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 18)];
                backImageLab.textColor = [UIColor grayColor];
                backImageLab.textAlignment = NSTextAlignmentLeft;
                backImageLab.text = @"名字";
                backImageLab.font = [UIFont boldSystemFontOfSize:14.0f];
                cell3.selectionStyle =  UITableViewCellSelectionStyleNone;
                [cell3.contentView addSubview:backImageLab];
                

                // 姓名修改
                _nameField = [[UITextField alloc] initWithFrame:CGRectMake(154, 5, 130, 28)];
                _nameField.textColor = [UIColor grayColor];
                _nameField.font = [UIFont systemFontOfSize:14.0f];
                _nameField.textAlignment = NSTextAlignmentRight;
                _nameField.text = _personView.headName.text;
                _nameField.delegate = self;
                cell3.accessoryView = _nameField;
                
                return cell3;
                
            }
                break;
                
            case 2:
            {
                UITableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:section3Cell];
                cell3 =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:section3Cell];
                UILabel *backImageLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 18)];
                backImageLab.textColor = [UIColor grayColor];
                backImageLab.textAlignment = NSTextAlignmentLeft;
                backImageLab.text = @"性别";
                backImageLab.font = [UIFont boldSystemFontOfSize:14.0f];
                cell3.selectionStyle =  UITableViewCellSelectionStyleNone;
                [cell3.contentView addSubview:backImageLab];
                
                
                //性别修改
                _sexButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 8, 40, 20)];
                if ([_personView.sexIndicate isEqualToString:@"1"]) {
                    _sexButton.selected = NO;
                } else {
                    _sexButton.selected = YES;
                }
                _sexButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
                [_sexButton setTitle:@"男" forState:UIControlStateNormal];
                [_sexButton setTitle:@"女" forState:UIControlStateSelected];
                _sexButton.titleLabel.textAlignment = NSTextAlignmentRight;
                [_sexButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                _sexButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
                [_sexButton addTarget:self action:@selector(onTouchSexButton:) forControlEvents:UIControlEventTouchUpInside];
                cell3.accessoryView = _sexButton;
                
                return cell3;
                
            }
                
                break;
            case 3:
            {
                UITableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:section3Cell];
                cell3 =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:section3Cell];
                UILabel *backImageLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 18)];
                backImageLab.textColor = [UIColor grayColor];
                backImageLab.textAlignment = NSTextAlignmentLeft;
                backImageLab.text = @"地址";
                backImageLab.font = [UIFont boldSystemFontOfSize:14.0f];
                cell3.selectionStyle =  UITableViewCellSelectionStyleNone;
                [cell3.contentView addSubview:backImageLab];
                
                // 地址修改
                _addressField = [[UITextField alloc] initWithFrame:CGRectMake(254, 5, 130, 28)];
                _addressField.text = _personView.headAddress.text;
                _addressField.delegate = self;
                _addressField.textAlignment = NSTextAlignmentRight;
                _addressField.font = [UIFont systemFontOfSize:14.0f];
                _addressField.textColor = [UIColor grayColor];
                cell3.accessoryView = _addressField;
                
                return cell3;
                
            }
                
                break;
            case 4:
            {
                UITableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:section3Cell];
                cell3 =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:section3Cell];
                UILabel *backImageLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 18)];
                backImageLab.textColor = [UIColor grayColor];
                backImageLab.textAlignment = NSTextAlignmentLeft;
                backImageLab.text = @"个人签名";
                backImageLab.font = [UIFont boldSystemFontOfSize:14.0f];
                cell3.selectionStyle =  UITableViewCellSelectionStyleNone;
                [cell3.contentView addSubview:backImageLab];
                
                // 个性签名
                _mySignField = [[UITextField alloc] initWithFrame:CGRectMake(154, 5, 180, 28)];
                _mySignField.textColor = [UIColor grayColor];
                _mySignField.font = [UIFont boldSystemFontOfSize:14.0f];
                _mySignField.textAlignment = NSTextAlignmentRight;
                _mySignField.text = _personView.headIntroduce.text;
                _mySignField.delegate = self;
                cell3.accessoryView = _mySignField;
        
                return cell3;
                
            }
                break;
            default:
                break;
        }
    }
    
    if (cell == nil) {
        
     cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:section1Cell];
    
    }
    
    _SettingPersonInfortation.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return cell ;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        _selectRow = indexPath.row;
        [self addImagePicture];
    }
}


-(void)leftBarButtonItemTapped:(UIButton *)sender
{
    if (self.isFromRegister) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 保存数据
-(void)rightBarButtonItemOnTapped:(UIButton *)sender
{
    [MBProgressHUD showMessage:@"数据保存中..."];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
    });
    
    _personView.headName.text = _nameField.text;
    _personView.headAddress.text = _addressField.text;
    _personView.headIntroduce.text = _mySignField.text;
    _personView.headImage.image = _UsersHeadImage.image;
    if ([_personView.sexIndicate isEqualToString:@"1"]) {
        _personView.sex.image = [UIImage imageNamed:@"man"];
    } else {
        _personView.sex.image = [UIImage imageNamed:@"woman"];
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjects:@[_personView.userIDNum, _personView.sexIndicate] forKeys:@[@"user_id", @"gender"]];
    if (_UsersHeadImage.image != nil) {
//        NSData *data = UIImagePNGRepresentation(_UsersHeadImage.image);
//        NSString *base64 = [data base64Encoding];
//        [dic setObject:base64 forKey:@"profile_image"];
        [dic setObject:_UsersHeadImage.image forKey:@"profile_image"];
    }
    if (_nameField.text != nil) {
        [dic setObject:_nameField.text forKey:@"nickname"];
    }
    if (_addressField.text != nil) {
        [dic setObject:_addressField.text forKey:@"address"];
    }
    if (_mySignField.text != nil) {
        [dic setObject:_mySignField.text forKey:@"description"];
    }

    // 保存数据
    [self.myDB saveUserInfoToDB:kPersonSetting withColumns:dic];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:PERSON_PROFILE parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", dic);
        NSLog(@"JSON: %@", responseObject);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error );
    }];
}


#pragma mark -
#pragma mark -  选择图片
-(void)addImagePicture
{
    [self.view endEditing:YES];
    if (self.view.frame.origin.y == - 180) {
        CGRect rect = self.view.frame;
        rect.origin.y += 180;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = rect;
        }];
    }
    UIActionSheet *picture = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照" ,@"从手机相册选择", nil];
    [picture showInView:self.view];
}
    
#pragma mark - actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //性别的选择
    if (actionSheet.tag == 101) {
        if (buttonIndex == 0) {
             _personView.sexIndicate = @"1";
        } else if (buttonIndex == 1) {
             _personView.sexIndicate = @"2";
        }
        [_SettingPersonInfortation reloadData];
        return;
    }

    if (buttonIndex == 0) {
        
        UIImagePickerController  *picker = [[UIImagePickerController alloc]init];
        //        对于UIImagePickerController来说必须遵守两个协议
        //  UIImagePickerControllerDelegate,UINavigationControllerDelegate
        picker.delegate = self;
        
        picker.allowsEditing = YES;
        
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        //        sourceType决定了，当前调出的是照相机还是图片库
        picker.sourceType =UIImagePickerControllerSourceTypeCamera;
        //        必须以模态的形式来弹出界面
        [self presentViewController:picker animated:YES completion:NULL];
        
        
    }else if(buttonIndex == 1){
        
        UIImagePickerController  *picker = [[UIImagePickerController alloc]init];
        //        对于UIImagePickerController来说必须遵守两个协议
        //  UIImagePickerControllerDelegate,UINavigationControllerDelegate
        picker.delegate = self;
        
        picker.allowsEditing = YES;
        
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        //        sourceType决定了，当前调出的是照相机还是图片库
        picker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
        //        必须以模态的形式来弹出界面
        [self presentViewController:picker animated:YES completion:NULL];
    } else {
        return;
    }
}


// UIImagePicker Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    _UsersHeadImage.image = nil;
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    _UsersHeadImage.image = image;
    
    // 将图片写入沙盒
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myDocument = [documents objectAtIndex:0];
    NSData *data = UIImageJPEGRepresentation(image, 1);
    [data writeToFile:[NSString stringWithFormat:@"%@/image.jpg", myDocument] atomically:YES];

    NSLog(@"%@", [NSString stringWithFormat:@"%@/image.jpg", myDocument]);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//点击性别按钮的事件
- (void)onTouchSexButton:(UIButton *)sender
{
    [self.view endEditing:YES];
    if (self.view.frame.origin.y == - 180) {
        CGRect rect = self.view.frame;
        rect.origin.y += 180;
        [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = rect;
        }];
    }
    UIActionSheet *sexActionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男", @"女", nil];
    sexActionSheet.tag = 101;
    [sexActionSheet showInView:self.view];
}

// textField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.view.frame.origin.y == -180) {
        return;
    }
    CGRect rect = self.view.frame;
    rect.origin.y -= 180;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = rect;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.view.frame.origin.y == -180) {
        CGRect rect = self.view.frame;
        rect.origin.y += 180;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = rect;
        }];
    }
    [textField resignFirstResponder];
    return YES;
}

@end
