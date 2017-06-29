//
//  YYZRelatedProductsView.m
//  Youyizhao
//
//  Created by 罗浩 on 2017/5/11.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import "YYZRelatedProductsView.h"
#import "YYZGuanLianProtuctModel.h"
#import "UIView+SDAutoLayout.h"

const CGFloat margin = 5;

@interface YYZRelatedProductsView()
@property (nonatomic, strong) UIView *singleView;

@property (nonatomic, strong) NSArray *ProductArray;
@end

@implementation YYZRelatedProductsView


#pragma mark - 点击商品
- (void)clickProduct:(UIGestureRecognizer *)gesture
{
    if (_relateBlock) {
        _relateBlock(gesture.view.tag);
    }
}

-(void)setProArr:(NSArray *)proArr
{
    _proArr = proArr;
    
//    self.width_sd = ScreenWidth - 100;
//    self.height_sd = 50 +margin * proArr.count;
//    
//    self.fixedHeight = @(ScreenWidth - 100);
//    self.fixedWidth = @(50 +margin * proArr.count);
    self.userInteractionEnabled = YES;
    
    self.hidden = proArr.count ? NO : YES;
    
    [proArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *proDict = proArr[idx];
        
        UIView * bgView = [UIView viewWithBackgroundColor:TableColor superView:self];
        
        bgView.tag = idx;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickProduct:)];
        [bgView addGestureRecognizer:tap];
        
        bgView.frame = CGRectMake(0, margin  + (KActualH(100)+5)  * idx, ScreenWidth-50-kMargin*2,KActualH(100));
        
        UIImageView * imgView = [[UIImageView alloc]init];
        [bgView addSubview:imgView];
        [imgView sd_setImageWithURL:[NSURL URLWithString:proDict[@"product_image"]]];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(KActualH(100));
        }];
        
        UILabel * title = [UILabel labelWithText:proDict[@"product_title"] font:kFont12 textColor:BlackGrayColor backGroundColor:ClearColor superView:bgView];
        title.numberOfLines = 1;
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(imgView.mas_right).mas_equalTo(margin);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(margin);
        }];
        
        
        UILabel * price = [UILabel labelWithText:proDict[@"product_price"] font:kFont12 textColor:BlackGrayColor backGroundColor:ClearColor superView:bgView];
        [price mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(title.mas_left);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-margin);
        }];
    
    }];
    
    
}



@end
