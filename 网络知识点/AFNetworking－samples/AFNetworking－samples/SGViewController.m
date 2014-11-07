//
//  SGViewController.m
//  AFNetworking－samples
//
//  Created by 泰坦虾米 on 14/8/26.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SGViewController.h"
#import "AFNetworking.h"
@interface SGViewController ()
@property(nonatomic,strong)NSMutableDictionary *userInfo;
@end

@implementation SGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self requestDataWithJSON];
//    [self ceshi];
    [self creatDownload];
//    [self requestDataWithPost2];
//    [self requestDataWithPost];
//    [self deleteStatus];
//    [self requestDataWithGet];
//    [self requestDataWithSyn];
}



//========HTTP请求与操作：===========

//post请求
//发送微博
-(void)requestDataWithPost
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameter = @{
                                @"access_token":@"2.00DQZC3C0IGXsY2f505844b26mVvFC",
                                @"status":@"祖国你好",
                                };
    [manager POST:@"https://api.weibo.com/2/statuses/update.json" parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Json:%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error:%@",error);
    }];
    
}

//get请求
//请求最新微博id
-(void)requestDataWithGet
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameter = @{
                                @"access_token":@"2.00DQZC3C0IGXsY2f505844b26mVvFC",
                                
                                };
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:@"https://api.weibo.com/2/statuses/user_timeline/ids.json" parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"+++++++%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error=====%@",error);
    }];
    
}


//删除微博
-(void)deleteStatus
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameter = @{
                                @"access_token":@"2.00DQZC3C0IGXsY2f505844b26mVvFC",
                                @"id":@"3740325166645852"
                                };
//    manager.requestSerializer
    [manager POST:@"https://api.weibo.com/2/statuses/destroy.json" parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"删除成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];

}

//========post的多部分请求=========
//发送一条微博，并带一张图片
-(void)requestDataWithPost2
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameter = @{
                                 @"access_token":@"2.00DQZC3C0IGXsY2f505844b26mVvFC",
                                  @"status":@"祖国你好",
                                };

    NSData *dataTest = UIImageJPEGRepresentation([UIImage imageNamed:@"1"], 0.3);
    [manager POST:@"https://upload.api.weibo.com/2/statuses/upload.json" parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
       //图片的格式为二进制，所以用NSData
        [formData appendPartWithFileData:dataTest name:@"pic" fileName:@"1.png" mimeType:@"image/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"=====%@",error);
    }];
}

//POST Multi-Part格式的表单文件上传请求:
-(void)requestDataWithPOST2
{
AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
NSDictionary *parameters = @{@"foo": @"bar"};
NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
[manager POST:@"http://example.com/resources.json" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileURL:filePath name:@"image" error:nil];
} success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"Success: %@", responseObject);
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
}];
}
//使用苹果的方法解决
-(void)requestDataWithSyn
{
    NSURL *strUrl = [NSURL URLWithString:@"http://www.raywenderlich.com/downloads/weather_sample/weather.php?format=json"];
    
    NSURLResponse *response = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:strUrl];
    //该方法返回的是NSData二进制数据
    NSData *data =  [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSLog(@"%@",data);
}

-(void)creatUploadTask
{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"https://upload.api.weibo.com/2/statuses/upload.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURL *filePath = [NSURL fileURLWithPath:@"1.png"];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
        }
    }];
    [uploadTask resume];

}


//==========模仿下载搜狗输入法===============
//http://pinyin.sogou.com/mac/softdown.php?r=dl_2_8
-(void)creatDownload
{
    //用于定义和配置 NSURLSession 对象的
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // 生成下载链接
    NSURL *URL = [NSURL URLWithString:@"http://pinyin.sogou.com/mac/softdown.php?r=dl_2_8"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    //下载任务
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    
    [downloadTask resume];
}

-(void)ceshi
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"foo": @"bar"};
    [manager POST:@"http://example.com/resources.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)requestDataWithJSON
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameter = @{
                                @"access_token":@"2.00DQZC3C0IGXsY2f505844b26mVvFC",
                                @"id":@"",
                                };

    [manager POST:@"https://api.weibo.com/2/statuses/home_timeline.json" parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"POST请求完成");
        NSLog(@"%@",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"POST请求失败: %@", error);
    }];
    
//    这是post的，get的类似。
}


//NSURLSession


@end
