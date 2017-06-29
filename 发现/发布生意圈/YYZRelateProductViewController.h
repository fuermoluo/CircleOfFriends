//
//  YYZRelateProductViewController.h
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/19.
//  Copyright © 2017年 Nado. All rights reserved.
//添加关联产品

#import <UIKit/UIKit.h>

typedef void(^RelateBlock)(NSArray *productArr);

@interface YYZRelateProductViewController : UIViewController

//返回选中的关联商品
@property (nonatomic, copy) RelateBlock relateBlock;

@end
