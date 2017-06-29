//
//  STOtherPeopleView.m
//  unizaoMerchant
//
//  Created by 班文政 on 2017/5/8.
//  Copyright © 2017年 NADOLily. All rights reserved.
//

#import "STOtherPeopleView.h"

@interface STOtherPeopleView ()

/**查看他人店铺*/
@property (nonatomic, strong) UILabel *otherShop;


@end

@implementation STOtherPeopleView

- (UIImageView *)topBgView
{
    if (!_topBgView) {
        
        _topBgView = [[UIImageView alloc] init];
        
        _topBgView.image = [UIImage imageNamed:@"bg_city"];
        
        _topBgView.userInteractionEnabled = YES;
        
        [self addSubview:_topBgView];
        
        [_topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.right.left.mas_equalTo(0);
            
            make.height.mas_equalTo(130);
        }];
    }
    
    return _topBgView;
}



- (UIButton *)backBtn
{
    if (!_backBtn ) {
        
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"store_back"] forState:UIControlStateNormal];
        _backBtn.contentHorizontalAlignment  = UIControlContentHorizontalAlignmentLeft;
        [self.topBgView addSubview:_backBtn];
        
        [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            //            make.right.mas_equalTo(self.searchTextField.mas_left).mas_equalTo(-10);
            make.left.mas_equalTo(kMargin);
            make.top.mas_equalTo(23);
            
            make.width.height.mas_equalTo(30);
        }];
    }
    
    return _backBtn;
}



- (UIImageView *)avarImgView
{
    if (!_avarImgView) {
        
        _avarImgView = [[UIImageView alloc] init];
        
        _avarImgView.layer.masksToBounds = YES;
        
        _avarImgView.layer.cornerRadius = 5;
        
        [self.topBgView addSubview:_avarImgView];
        
        [_avarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.backBtn.mas_bottom).mas_equalTo(kMargin);
            
            make.left.mas_equalTo(kMargin);
            
            make.width.height.mas_equalTo(50);
        }];
    }
    
    return _avarImgView;
}


- (UILabel *)niceLbl
{
    if (!_niceLbl) {
        
        _niceLbl = [[UILabel alloc] init];
        
        _niceLbl.font = kFont(15);
        
        _niceLbl.textColor = [UIColor whiteColor];
        
        [self.topBgView addSubview:_niceLbl];
        
        [_niceLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.avarImgView.mas_top).mas_equalTo(9);
            
            make.left.mas_equalTo(self.avarImgView.mas_right).mas_equalTo(kMargin);
        }];
    }
    return _niceLbl;
}


- (UIButton *)attentBtn
{
    if (!_attentBtn) {
        
        _attentBtn = [[UIButton alloc] init];
        
        [_attentBtn setTitle:@"关注" forState:UIControlStateNormal];
        
         [_attentBtn setTitle:@"已关注" forState:UIControlStateSelected];
        
        [_attentBtn setTitleColor:ThemeColor forState:UIControlStateNormal];
        
//        [_attentBtn setBackgroundColor:ThemeColor forState:UIControlStateNormal];
        [_attentBtn setBackgroundColor:[UIColor whiteColor]];
        
        _attentBtn.titleLabel.font = kFont(15);
        
        [self.topBgView addSubview:_attentBtn];
        
        [_attentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerY.mas_equalTo(self.avarImgView);
            
            make.right.mas_equalTo(-kMargin);
            
            make.width.mas_equalTo(50);
            
            make.height.mas_equalTo(20);
        }];
        
        _attentBtn.layer.masksToBounds = YES;
        
        _attentBtn.layer.cornerRadius = 4;
    }
    
    return _attentBtn;
}


- (UILabel *)otherShop
{
    if (!_otherShop) {
        
        _otherShop = [[UILabel alloc] init];
        
        _otherShop.font = kFont(12);
        
        _otherShop.textColor = [UIColor whiteColor];
        
        _otherShop.text = @"查看他的店铺";
        
        [self.topBgView addSubview:_otherShop];
        
        [_otherShop mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.niceLbl.mas_bottom).mas_equalTo(7);
            
            make.left.mas_equalTo(self.avarImgView.mas_right).mas_equalTo(kMargin);
            
        }];
    }
    
    return _otherShop;
}


- (UIButton *)lookOtherShopBtn
{
    
    if (!_lookOtherShopBtn) {
        
        _lookOtherShopBtn = [[UIButton alloc] init];
        
        
        [_lookOtherShopBtn setImage:[UIImage imageNamed:@"返回-拷贝-72"] forState:UIControlStateNormal];
        
        _lookOtherShopBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        [_lookOtherShopBtn.imageView sizeToFit];
        
        [self.topBgView addSubview:_lookOtherShopBtn];
        
        [_lookOtherShopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
//            make.width.mas_equalTo(25);
            
            make.right.mas_equalTo(self.otherShop.mas_right).mas_equalTo(10);
            
            make.height.mas_equalTo(25);
            
            make.centerY.mas_equalTo(self.otherShop);
            
            make.left.mas_equalTo(self.otherShop.mas_left).mas_equalTo(5);
        }];
    }
    
    return _lookOtherShopBtn;
}
@end
