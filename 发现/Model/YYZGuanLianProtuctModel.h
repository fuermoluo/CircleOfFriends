//
//  YYZGuanLianProtuctModel.h
//  Youyizhao
//
//  Created by 罗浩 on 2017/5/11.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYZGuanLianProtuctModel : NSObject

@property (nonatomic, strong) NSString *imgUrl;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *price;

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)GuanLianWithDict:(NSDictionary *)dict;

@end
