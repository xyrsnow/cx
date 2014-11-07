//
//  QYImageManager.m
//  Hallyu
//
//  Created by qingyun~sg on 14-10-13.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYImageManager.h"

@interface QYImageManager ()

@property (strong, nonatomic) NSString *imageFilePath;
@property (strong, nonatomic) NSString *imageFileName;


@end

@implementation QYImageManager

- (id)init
{
    self = [super init];
    if (self) {
        //获取沙盒中document路径
        NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        //添加Image存储路径
        self.imageFileName = [documentFilePath stringByAppendingPathComponent:@"Image"];
        self.imageFilePath = [NSString stringWithString:self.imageFileName];

    }
    return self;
}

- (void) saveImage:(UIImage *)image ImageURL:(NSURL *)imageURL{
    [self saveImage:image ImageName:[imageURL lastPathComponent]];
}

- (void) saveImage:(UIImage *)image ImageName:(NSString *)imageName{
    //创建文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.imageFileName]) {
        NSLog(@"文件已经存在");
    }else{
    BOOL isOK = [fileManager createDirectoryAtPath:self.imageFileName withIntermediateDirectories:YES attributes:nil error:NULL];
    if (!isOK) {
        NSLog(@"创建文件失败");
    }else{
        NSLog(@"创建文件成功，filePath：%@",self.imageFileName);
    }
    }
    
    NSString *filePath = [self.imageFileName stringByAppendingPathComponent:imageName];
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:filePath atomically:YES];

    
}

- (UIImage *)getImage:(NSString *)imageName{
    NSString *imageFile = [self.imageFilePath stringByAppendingPathComponent:imageName];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFile];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

//保存照片到本地
- (void)saveImageToDocument:(UIImage *)image{
    //png
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSDate *date = [NSDate date];
    NSString *imageName = [self.imageFilePath stringByAppendingFormat:@"%@",date];
    if (data) {
        [data writeToFile:imageName atomically:YES];
    }else{
        NSData *data = UIImagePNGRepresentation(image);
        if (data) {
            [data writeToFile:imageName atomically:YES];
        }
    }
}

@end
