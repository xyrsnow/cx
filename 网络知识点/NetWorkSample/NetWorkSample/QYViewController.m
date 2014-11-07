//
//  QYViewController.m
//  NetWorkSample
//
//  Created by QingYun on 14-7-12.
//  Copyright (c) 2014年 河南青云信息技术有限公司. All rights reserved.
//

#import "QYViewController.h"

#define kSoundURL @"http://tingge.5nd.com/20060919//2014/2014-9-9/64107/1.Mp3"

@interface QYViewController ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate, NSURLSessionDataDelegate>

@property (nonatomic, retain) NSMutableData *recvData;
@end

@implementation QYViewController

- (void)writeData2File:(NSData *)recvData
{
    //    NSLog(@"%@",recvData);
    //    第一个参数：表示你要找的是哪个目录，在这里表示打的沙盒的Documents
    //    第二个参数：表示从哪个目录开始找，从用户主目录开始找
    //    第三个参数：表示是否展开~, 如果设置成yes，表示会用用户目录的绝对路来表示返回的路径， 如果设置成为NO，对于home来说， 依然使用~来表示
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = paths[0];
    NSLog(@"%@",documentPath);
    
//    NSString *musicName = [NSString stringWithFormat:@"%@/xiaopingguo.mp3",doucumentPath];
    NSString *musicName = [documentPath stringByAppendingString:@"/gequ.mp3"];
    [recvData writeToFile:musicName atomically:YES];
}


//==========NSURLConnection===========
- (void)getDataFromNetWorkWithSyn
{
    //    NSString *strUrl = @"http://www.baidu.com";
    
//    NSString *strUrl = kSoundURL;
    NSString *strUrl = [kSoundURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    创建用于访问服务器资源的url
    NSURL *url = [NSURL URLWithString:strUrl];
    //    创那访问服务器的请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //    声明用于接收服务器响应对象
    NSURLResponse *response = nil;
    //    声明用于捕获网络操作错误的对象
    NSError *error = nil;
    
    //    第一个参数是请求对象，
    //    第二个参数是获取返回数据的对象
    //    第三个参数是获取错误信息的对象
    NSData *recvData =  [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil) {
        NSLog(@"<%@>,<%@>",error,response);
    }else
    {
        NSLog(@"%@",response);
    }
    
    [self writeData2File:recvData];
    
    /*
     NSString *filePathName = [NSString stringWithFormat:@"%@/baidu.html",doucumentPath];
     NSLog(@"%@",filePathName);
     
     
     NSString *recveString = [[NSString alloc] initWithData:recvData encoding:NSUTF8StringEncoding];
     
     //    将从服务器获取的数据写到文件里
     //    第一个参数表示写的路径和文件名， 第二个参数表示是否是原子动作， 第三个参数表示写成的文件的编码格式 第四个是错误信息
     [recveString writeToFile:filePathName atomically:YES encoding:NSUTF8StringEncoding error:nil];
     //    NSLog(@"%@",recveString);
     */

}

//============NSURLSession=============
-(void)requestDataWithSession
{
    NSString *londonWeatherUrl =
   @"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/35476132/34787871414375261128.mp3?xcode=f40f9f054b6653422e2b32cffc5db09bf9be23d86f331081&song_id=3478787";
    //request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:londonWeatherUrl]];
    NSURLSession *session = [NSURLSession sharedSession];

  NSURLSessionDataTask *task =  [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",response);
      [self writeData2File:data];
    }];
    
    //开始执行
    [task resume];
    
}
- (void)getDataFromNetWorkWithAsyn
{
    NSString *strUrl = kSoundURL;
    //    创建用于访问服务器资源的url
    NSURL *url = [NSURL URLWithString:strUrl];
    //    创那访问服务器的请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
      
    
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate
//客户端发送请求数据之后， 服务端返回响应头后， 会调用这个方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@",response);
    //初始化接收数据的对象
    self.recvData = [[NSMutableData alloc] initWithCapacity:4000];

}

//当服务器将数据发送一个包之后，客户端收到数据包会调用这个方法。如果请求数据比较大的时候， 此方法， 会被多次调用
//第二个参数就是从网络端返回的具体数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%s",__func__);
    //接收数据
    [self.recvData appendData:data];
}

//当请求的服务器数数据全部返回完成的时候， 这个方法会被调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"%s",__func__);
    [self writeData2File:self.recvData];
}

- (IBAction)doDownloadMusic:(UIButton *)sender
{
    [self getDataFromNetWorkWithSyn];
}


- (IBAction)asynDownloadMusic:(UIButton *)sender
{
    [self getDataFromNetWorkWithAsyn];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    注意， 良好的设计是不应该在这里给recvData申请内存空间的， 应该采用懒加载方式
//    self.recvData = [[NSMutableData alloc] initWithCapacity:400];
    
    [self requestDataWithSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
