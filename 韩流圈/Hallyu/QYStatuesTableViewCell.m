 //
//  QYStatuesTableViewCell.m
//  Hallyu
//
//  Created by qingyun on 14-8-11.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYStatuesTableViewCell.h"
#import "NSString+FrameHeight.h"
#import "UIViewExt.h"
#import "AsyncImageView.h"
#import "unifiedHeaderFile.h"
#import "QYDateSwith.h"
@implementation QYStatuesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10,5,81,81)];
        _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_textImgView.frame)
                                                              + 10,self.textImgView.frame.origin.y,320
                                                               - 10 - 81 -10 - 3,20)];
        _timeLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_textImgView.frame)
                                                              + 10,CGRectGetMaxY(_titleLable.frame),30, 10)];
        _sourceLable = [[RTLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_timeLable.frame),_timeLable.frame.origin.y, 0, 10)];
        _kindLable = [[RTLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_sourceLable.frame)
                                                              + 10, _timeLable.frame.origin.y, 0, 10)];
        _lableText = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_textImgView.frame)
                                                              + 10, CGRectGetMaxY(_kindLable.frame) + 5,320 - 10 - 81 - 10 - 5,50)];
    }
    return self;
}

//添加cell内部数据
- (void)loadCellData:(NSDictionary *)dictionary
{
    //self.messageCellData = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    //初始化图片。
    _textImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10,5,81,81)];
    _textImgView.userInteractionEnabled = YES;
    _textImgView.multipleTouchEnabled = YES;
    
    //初始化标题
    NSUInteger wordsPerLine = floor(CGRectGetWidth(_titleLable.frame) / 12.0f);
    if ([dictionary[kTitle] length] > wordsPerLine) {
        self.titleLable.text = [dictionary[kTitle] substringToIndex:wordsPerLine];
        NSUInteger p = 0;
        for (int i = 0;i < [self.titleLable.text length];i++) {
            NSString *charFromString = [self.titleLable.text substringWithRange:NSMakeRange(i, 1)];
            NSString *condation =@"^[A-Za-z0-9].*";
            NSPredicate *presicate = [NSPredicate predicateWithFormat:@"self MATCHES %@",condation];
            if ([presicate evaluateWithObject:charFromString]) {
                p++;
            }
        }
        self.titleLable.text = [dictionary[kTitle] substringToIndex:wordsPerLine + floor(p/2) - 1];
    }else{
        self.titleLable.text = dictionary[kTitle];
    }
    [self.titleLable setTextColor:[UIColor darkGrayColor]];
    self.titleLable.font = [UIFont boldSystemFontOfSize:12];
    [self.contentView addSubview:_titleLable];
    
    //初始化微博的发布时间
    QYDateSwith *date = [[QYDateSwith alloc]initWithDate:dictionary[kDate]];
    [_timeLable setText:[NSString stringWithFormat:@"%d.%d",date.month,date.day]];
    _timeLable.font = [UIFont systemFontOfSize:11.0];
    [_timeLable setTextColor:[UIColor colorWithRed:0.118 green:0.843 blue:0.450 alpha:1.000]];
    [self.contentView addSubview:_timeLable];
    
    //初始化文章来源
    _sourceLable.frame = CGRectMake(CGRectGetMaxX(_timeLable.frame) + 5,_timeLable.frame.origin.y, 0, 10);
    _sourceLable.text = dictionary[kAuthor];
    _sourceLable.textColor = [UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:1.000];
    _sourceLable.font = [UIFont systemFontOfSize:11];
    _sourceLable.width = _sourceLable.optimumSize.width;
    _sourceLable.height = _sourceLable.optimumSize.height;
    [self.contentView addSubview:_sourceLable];
    
    //初始化文章种类
    _kindLable.frame = CGRectMake(CGRectGetMaxX(_sourceLable.frame) + 5, _timeLable.frame.origin.y, 0, 10);
    _kindLable.text = dictionary[kTheme];
    _kindLable.textColor = [UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:1.000];
    _kindLable.font = [UIFont systemFontOfSize:11];
    _kindLable.width = _kindLable.optimumSize.width;
    _kindLable.height = _kindLable.optimumSize.height;
    [self.contentView addSubview:_kindLable];
    
    
    //初始化正文
    self.lableText.text = dictionary[kContent];
    NSDictionary *attributs = @{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]};
    CGSize size = [self.lableText.text sizeWithAttributes:attributs];
    NSUInteger wordsPerLineForText = floor(214.0f / 13.0f);
    CGFloat widthPerLine = 13.0f * wordsPerLineForText;
    NSUInteger nLines = ceil( size.width / widthPerLine );
    self.lableText.numberOfLines = nLines;
    self.lableText.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.000];
    self.lableText.font = [UIFont systemFontOfSize:13.0];
    UIEdgeInsetsMake(3.5, 0, 3.5, 0);
    [self.contentView addSubview:_lineView];
    [self.contentView addSubview:_lableText];
    [self.contentView addSubview:_textImgView];
    
}

@end
