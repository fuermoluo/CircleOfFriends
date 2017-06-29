//
//  YYZRelateProductTableCell.m
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/19.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import "YYZRelateProductTableCell.h"

@implementation YYZRelateProductTableCell

- (UIImageView *)productImgView
{
    if (!_productImgView) {
        
        _productImgView = [[UIImageView alloc]init];
        
        [self addSubview:_productImgView];
        
        [_productImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-kMargin);
            make.top.left.mas_equalTo(kMargin);
            make.size.mas_equalTo(CGSizeMake(KActualH(80), KActualH(80)));
        }];
        
    }
    return _productImgView;
}

- (UIImageView *)selectImgView
{
    if (!_selectImgView) {
        
        _selectImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"set_remember_gray"]];
        
        [self addSubview:_selectImgView];
        
        [_selectImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-kMargin);
            make.size.mas_equalTo(_selectImgView.image.size);
        }];

    }
    return _selectImgView;
}

- (UILabel *)titleLbl
{
    if (!_titleLbl) {
        
        _titleLbl = [UILabel labelWithText:@"" font:kFont15 textColor:BlackColor backGroundColor:ClearColor superView:self];
        
        _titleLbl.numberOfLines = 1;
        
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(self.productImgView.mas_right).mas_equalTo(kMargin);
            make.top.mas_equalTo(self.productImgView.mas_top);
            make.right.mas_equalTo(self.selectImgView.mas_left).mas_equalTo(-5);
            
        }];
        
    }
    return _titleLbl;
}

- (UILabel *)priceLbl
{
    if (!_priceLbl) {
        
        _priceLbl = [UILabel labelWithText:@"" font:kFont13 textColor:BlackGrayColor backGroundColor:ClearColor superView:self];
        
        [_priceLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(self.titleLbl.mas_left);
            make.bottom.mas_equalTo(self.productImgView.mas_bottom);
            make.right.mas_equalTo(self.titleLbl.mas_right);
            
        }];

    }
    return _priceLbl;
}

@end




@implementation YYZSelectProductTableCell

- (UIImageView *)productImgView
{
    if (!_productImgView) {
        
        _productImgView = [[UIImageView alloc]init];
        
        [self addSubview:_productImgView];
        
        [_productImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-kMargin);
            make.top.left.mas_equalTo(kMargin);
            make.size.mas_equalTo(CGSizeMake(KActualH(80), KActualH(80)));
        }];
        
    }
    return _productImgView;
}


- (UILabel *)titleLbl
{
    if (!_titleLbl) {
        
        _titleLbl = [UILabel labelWithText:@"" font:kFont14 textColor:BlackColor backGroundColor:ClearColor superView:self];
        
        _titleLbl.numberOfLines = 1;
        
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(self.productImgView.mas_right).mas_equalTo(kMargin);
            make.top.mas_equalTo(self.productImgView.mas_top);
            make.right.mas_equalTo(-kMargin);
            
        }];
        
    }
    return _titleLbl;
}

- (UILabel *)priceLbl
{
    if (!_priceLbl) {
        
        _priceLbl = [UILabel labelWithText:@"" font:kFont12 textColor:BlackGrayColor backGroundColor:ClearColor superView:self];
        
        [_priceLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(self.titleLbl.mas_left);
            make.bottom.mas_equalTo(self.productImgView.mas_bottom);
            make.right.mas_equalTo(self.titleLbl.mas_right);
            
        }];
        
    }
    return _priceLbl;
}

@end
