//
//  QYImageManager.h
//  Hallyu
//
//  Created by qingyun~sg on 14-10-13.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYImageManager : NSObject

- (void) saveImage:(UIImage *)image ImageURL:(NSURL *)imageURL;
- (void) saveImage:(UIImage *)image ImageName:(NSString *)imageName;

- (UIImage *)getImage:(NSString *)imageName;
@end
