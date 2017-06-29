//
//  YYZGuanLianProtuctModel.m
//  Youyizhao
//
//  Created by 罗浩 on 2017/5/11.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import "YYZGuanLianProtuctModel.h"

@implementation YYZGuanLianProtuctModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        
        self.imgUrl = @"http://img06.tooopen.com/images/20160712/tooopen_sy_170083325566.jpg";
        
        self.title =  @"面膜面膜面膜面膜面膜面膜面膜面膜面膜面膜面膜面膜";
        
        self.price =  @"￥69.99";
      
    }
    return self;
}

+ (instancetype)GuanLianWithDict:(NSDictionary *)dict
{
    return [[self alloc]initWithDict:dict];
}

@end
