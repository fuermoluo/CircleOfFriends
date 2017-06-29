//
//  YYZBrowserTableCell.m
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/19.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import "YYZBrowserTableCell.h"
#import "YYZUserHomeViewController.h"

@implementation YYZBrowserTableCell


#pragma mark - 点击头像

- (void)clickAvatar:(UIGestureRecognizer *)gesture
{
    NSString *userID = [NSString stringWithFormat:@"%zd", gesture.view.tag];
    [self.supNavigationController pushViewController:[[YYZUserHomeViewController alloc]initWithOtherID:userID] animated:YES];
}


- (UIImageView *)avatarImgView
{
    if (!_avatarImgView) {
        
        _avatarImgView = [[UIImageView alloc]init];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickAvatar:)];
        _avatarImgView.userInteractionEnabled = YES;
        [_avatarImgView addGestureRecognizer:tap];
        
        [self addSubview:_avatarImgView];
        
        [_avatarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.top.mas_equalTo(kMargin);
            make.bottom.mas_equalTo(-kMargin);
            make.size.mas_equalTo(CGSizeMake(KActualH(80), KActualH(80)));
            
        }];
        
    }
    return _avatarImgView;
}

- (UILabel *)nameLbl
{
    if (!_nameLbl) {
        
        _nameLbl = [UILabel labelWithText:@"" font:kFont15 textColor:BlackColor backGroundColor:ClearColor superView:self];
        
        _nameLbl.textAlignment = NSTextAlignmentRight;
        
        [_nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(self.avatarImgView.mas_right).mas_equalTo(kMargin);
            make.top.mas_equalTo(self.avatarImgView.mas_top);
            
        }];

        
    }
    return _nameLbl;
}

- (UILabel *)timeLbl
{
    if (!_timeLbl) {
        
        _timeLbl = [UILabel labelWithText:@"" font:kFont13 textColor:GrayBlackColor backGroundColor:ClearColor superView:self];
        
        _timeLbl.textAlignment = NSTextAlignmentRight;
        
        [_timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(self.nameLbl.mas_left);
            make.bottom.mas_equalTo(self.avatarImgView.mas_bottom);
            
        }];
        
    }
    return _timeLbl;
}


@end
