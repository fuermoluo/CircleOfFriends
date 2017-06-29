//
//  STDynamicTableViewCell.m
//  unizaoMerchant
//
//  Created by 班文政 on 2017/5/8.
//  Copyright © 2017年 NADOLily. All rights reserved.
//


#import "STDynamicTableViewCell.h"
#import "STDynamicGoodsView.h"
#import "SDWeiXinPhotoContainerView.h"
@interface STDynamicTableViewCell ()




/**
 记录最后一个商品链接
 */
@property (nonatomic, strong) STDynamicGoodsView *goodsView;


@property (nonatomic, strong) SDWeiXinPhotoContainerView *picContainerView;

@end

@implementation STDynamicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (UIImageView *)avarImgView
{
    if (!_avarImgView) {
        
        _avarImgView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:_avarImgView];
        
        [_avarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.width.height.mas_equalTo(30);
            make.left.mas_equalTo(kMargin);
            make.top.mas_equalTo(10);
        }];
        
    }
    
    return _avarImgView;
}

- (UILabel *)niceLbl
{
    if (!_niceLbl) {
        
        _niceLbl = [[UILabel alloc] init];
        
        _niceLbl.font = kFont(14);
        
        _niceLbl.textColor = RGBCOLOR(68, 68, 68);
        
        [self.contentView addSubview:_niceLbl];
        
        [_niceLbl mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.mas_equalTo(_avarImgView.mas_right).mas_equalTo(14);
            
            make.top.mas_equalTo(10);
        }];
    }
    
    return _niceLbl;
}

- (UILabel *)timeLbl
{
    
    if (!_timeLbl) {
        
        _timeLbl = [[UILabel alloc] init];
        
        _timeLbl.font = kFont(12);
        
        _timeLbl.textColor = RGBCOLOR(120, 120, 120);
        
        [self.contentView addSubview:_timeLbl];
        
        [_timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.mas_equalTo(_picContainerView.mas_bottom).mas_equalTo(10  );
            make.left.mas_equalTo(_niceLbl.mas_left);
            
        }];
    }
    
    return _timeLbl;
}


- (UILabel *)titleLbl
{
    if (!_titleLbl) {
        
        _titleLbl = [[UILabel alloc] init];
        
        _titleLbl.font = kFont(13);
        
        _titleLbl.textColor = RGBCOLOR(100, 100, 100);
        
        _titleLbl.numberOfLines = 0;
        
        [self.contentView addSubview:_titleLbl];
        
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.mas_equalTo(_niceLbl.mas_left);
            
            make.top.mas_equalTo(_niceLbl.mas_bottom).mas_equalTo(5);
            
            make.right.mas_equalTo(-kMargin);
        }];
    }
    
    return _titleLbl;
}
- (SDWeiXinPhotoContainerView *)picContainerView{
    if (!_picContainerView) {
        _picContainerView = [SDWeiXinPhotoContainerView new];
        [self.contentView addSubview:_picContainerView];
    }
    return _picContainerView;
}

- (void)setPictureArr:(NSArray *)pictureArr
{
    self.picContainerView.picPathStringsArray = pictureArr;
    CGSize viewSize = self.picContainerView.size;
    [self.picContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLbl.mas_bottom).mas_equalTo(10);
        make.left.mas_equalTo(_titleLbl.mas_left).mas_equalTo(0);
        make.size.mas_equalTo(viewSize);
    }];

    
    self.picContainerView.userInteractionEnabled = YES;
    
    //    _pictureArr = pictureArr;
//    
//    CGFloat pictureW = (ScreenWidth - 60 - 14 - 2*kMargin - 7 * 2) / 3;
//    
//    for (int i = 0 ; i < pictureArr.count ; i ++) {
//        
//        NSInteger x = i / 3;
//        
//        NSInteger y = i % 3;
//        
//        UIImageView *imgView = [[UIImageView alloc] init];
//        
//        [imgView sd_setImageWithURL:pictureArr[i]];
//        
//        [self.contentView addSubview:imgView];
//        
//        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
//           
//            make.left.mas_equalTo(self.titleLbl.mas_left).mas_equalTo(y*(pictureW + 7));
//            
//            make.top.mas_equalTo(self.titleLbl.mas_bottom).mas_equalTo(10 + x*(pictureW + 7));
//            
//            make.width.height.mas_equalTo(pictureW);
//            
//        }];
//        
//        self.recordImgView = imgView;
//        imgView.tag = i;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
//        [imgView addGestureRecognizer:tap];
//    }
    
}


- (void)setGoodsArr:(NSArray *)goodsArr
{
    _goodsArr = goodsArr;
    
    for (int i = 0 ; i < goodsArr.count; i ++) {
        
        
        [self.commentBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(_picContainerView.mas_bottom).mas_equalTo(0);
            
            make.right.mas_equalTo(-kMargin);
            
            make.size.mas_equalTo(CGSizeMake(50, 20));
            
        }];
        
        //可以放在添加在button上
        
        STDynamicGoodsView *view = [[STDynamicGoodsView alloc] init];
        
        [view.imgView sd_setImageWithURL:[goodsArr[i] valueForKey:@"product_image"]];
        
        view.titleLbl.text = [goodsArr[i] valueForKey:@"product_title"];
        
        view.priceLbl.text = [NSString stringWithFormat:@"￥%@",[goodsArr[i] valueForKey:@"product_price"]];//@"￥150.00";

        
        view.backgroundColor = RGBCOLOR(238, 238, 238);
        
        [self.contentView addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.mas_equalTo(_titleLbl.mas_left);
            make.top.mas_equalTo(_timeLbl.mas_bottom).mas_equalTo(5 + i * (42 + 5 ));
            make.right.mas_equalTo(-kMargin);
            make.height.mas_equalTo(42);
            if (i == goodsArr.count - 1) {
                make.bottom.mas_equalTo(-kMargin);
            }
            
        }];
        
        self.goodsView = view;
    }
}


- (STDynamicGoodsView *)goodsView
{
    if (!_goodsView) {
        
        _goodsView = [[STDynamicGoodsView alloc] init];
        
        [self.contentView addSubview:_goodsView];
        
        [_goodsView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            
            make.left.mas_equalTo(_titleLbl.mas_left);
            make.top.mas_equalTo(_timeLbl.mas_bottom).mas_equalTo(0);
            make.right.mas_equalTo(-kMargin);
            make.height.mas_equalTo(1);
        }];
    }
    
    return _goodsView;
}

- (UIButton *)commentBtn
{
    if (!_commentBtn) {
        
        _commentBtn = [[UIButton alloc] init];
        
        [_commentBtn setImage:[UIImage imageNamed:@"find_comment"] forState:UIControlStateNormal];
        
        [_commentBtn setTitleColor:RGBCOLOR(200, 200, 200) forState:UIControlStateNormal];
        
        _commentBtn.titleLabel.font = kFont(12);
        
        [self.contentView addSubview:_commentBtn];
        
        [_commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(_picContainerView.mas_bottom).mas_equalTo(5);
            
            make.right.mas_equalTo(-kMargin);
            
            make.size.mas_equalTo(CGSizeMake(50, 20));
            
            if (!_goodsArr.count) {
              make.bottom.mas_equalTo(-10);
            }
            
     
        }];
        _commentBtn.layer.cornerRadius = 10;
        _commentBtn.layer.borderWidth = 1;
        _commentBtn.layer.borderColor = RGBCOLOR(200, 200, 200).CGColor;
    }
    
    return _commentBtn;
}


- (UIButton *)browsebtn
{
    if (!_browsebtn) {
        
        _browsebtn = [[UIButton alloc] init];
        
        [_browsebtn setImage:[UIImage imageNamed:@"look"] forState:UIControlStateNormal];
        
        [_browsebtn setTitleColor:RGBCOLOR(200, 200, 200) forState:UIControlStateNormal];
        
        _browsebtn.titleLabel.font = kFont(12);
        
        [self.contentView addSubview:_browsebtn];
        
        [_browsebtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(_commentBtn.mas_top);
            
            make.right.mas_equalTo(_commentBtn.mas_left).mas_equalTo(-10);
            
            make.size.mas_equalTo(CGSizeMake(50, 20));
            
        }];
        _browsebtn.layer.cornerRadius = 10;
        _browsebtn.layer.borderWidth = 1;
        _browsebtn.layer.borderColor = RGBCOLOR(200, 200, 200).CGColor;
    }
    
    return _browsebtn;
}

@end
