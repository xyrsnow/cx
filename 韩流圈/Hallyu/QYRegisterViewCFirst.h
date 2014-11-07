//
//  QYRegisterViewCFirst.h
//  Hallyu
//
//  Created by qingyun on 14-9-3.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYRegisterViewC.h"
@class QYUserSingleton;
typedef void (^phoneBlc)(NSString*) ;
@interface QYRegisterViewCFirst : QYRegisterViewC
@property (nonatomic,copy)phoneBlc pBloc;
@property (nonatomic,strong)QYUserSingleton *user;
@end
