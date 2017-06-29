//
//  YYZRelatedProductsView.h
//  Youyizhao
//
//  Created by 罗浩 on 2017/5/11.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYZProductModel.h"

//商品所属的下标
typedef void(^RelateBlock)(NSInteger index);

@interface YYZRelatedProductsView : UIView

@property (nonatomic, strong) NSArray *proArr;
//点击商品的事件
@property (nonatomic, copy) RelateBlock relateBlock;

@end
