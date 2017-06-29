//
//  YYZPublishFindViewController.h
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/19.
//  Copyright © 2017年 Nado. All rights reserved.
//发布生意圈

#import <UIKit/UIKit.h>

typedef void(^PublishFindBlock)(NSString *);

@interface YYZPublishFindViewController : UIViewController

//发布成功之后在发现页面弹出提示框
@property (nonatomic, copy) PublishFindBlock publishFindBlock;

@end
