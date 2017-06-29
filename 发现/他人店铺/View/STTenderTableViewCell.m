//
//  STTenderTableViewCell.m
//  unizaoMerchant
//
//  Created by 班文政 on 2017/5/3.
//  Copyright © 2017年 NADOLily. All rights reserved.
//

#import "STTenderTableViewCell.h"

@interface STTenderTableViewCell ()

@property (nonatomic, strong) UILabel  *tagLabel;

/**线条*/
@property (nonatomic, strong) UIView  *lineView;


/**状态是否过期*/
@property (nonatomic, strong) UILabel *stautsLbl;




@end

@implementation STTenderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel *)titleLbl
{
    if (!_titleLbl) {
        
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = kFont(15);
        _titleLbl.textColor = [UIColor blackColor];
        [self.contentView addSubview:_titleLbl];
        
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.mas_equalTo(self.imgView.mas_right).mas_equalTo(15);
            make.top.mas_equalTo(10);
        }];
        
    }
    return _titleLbl;
}
- (UIImageView *)outTimeImg{
    if (!_outTimeImg) {
        _outTimeImg = [UIImageView new];
        [self.contentView addSubview:_outTimeImg];
        [_outTimeImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(35, 35));
        }];
        _outTimeImg.image = [UIImage imageNamed:@"jiaobiao"];
    }
    return _outTimeImg;
}
//已认证
- (UIImageView *)imgView
{
    if (!_imgView) {
        
        _imgView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imgView];
        
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.top.mas_equalTo(12);
            make.width.mas_equalTo(13.5);
            make.height.mas_equalTo(13.5);
            
        }];
    }
    
    return _imgView;
}

- (void)setTagArr:(NSArray *)tagArr
{
    _tagArr = tagArr;
    
    for (int i = 0 ; i < tagArr.count; i ++) {
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = ThemeColor;
        label.font = kFont(8);
        label.text = tagArr[i];
        
        label.layer.borderColor = ThemeColor.CGColor;
        label.layer.borderWidth = 0.5;
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 2;
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:label];
        
        CGFloat margin = i == 0 ? 0 : 5;
        CGFloat W = [self sizeWithText:tagArr[i] font:kFont(8) maxSize:CGSizeMake(MAXFLOAT, 15)].width + 6;
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(self.tagLabel.mas_right).mas_equalTo(margin);
            make.top.mas_equalTo(self.descLbl.mas_bottom).mas_equalTo(8);
            make.height.mas_equalTo(15);
            make.width.mas_equalTo(W);
            
        }];
        
        self.tagLabel = label;
        
    }
    
}

- (UILabel *)tagLabel
{
    if (!_tagLabel) {
        
        _tagLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_tagLabel];
        
        [_tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(self.descLbl.mas_bottom).mas_equalTo(8);
        }];
    }
    return _tagLabel;
}

- (UILabel *)pushTimeLbl
{
    if (!_pushTimeLbl) {
        
        _pushTimeLbl = [[UILabel alloc] init];
        _pushTimeLbl.font = kFont(10);
        _pushTimeLbl.textColor = RGBCOLOR(150, 150, 150);
        [self.contentView addSubview:_pushTimeLbl];
        
        [_pushTimeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.right.mas_equalTo(-30);
            make.bottomMargin.mas_equalTo(self.titleLbl.mas_bottomMargin);
        }];
    }
    return _pushTimeLbl;
}

- (UILabel *)descLbl
{
    if (!_descLbl) {
        
        _descLbl = [[UILabel alloc] init];
        _descLbl.font = kFont(12);
        _descLbl.textColor = RGBCOLOR(176, 176, 176);
        _descLbl.numberOfLines = 0;
        _descLbl.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_descLbl];
        
        [_descLbl mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(self.titleLbl.mas_bottom).mas_equalTo(8);
            make.right.mas_equalTo(-15);
            
        }];
    }
    
    return _descLbl;
}

- (UIView *)lineView
{
    if (!_lineView) {
        
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = RGBCOLOR(230, 230, 230);
        [self.contentView addSubview:_lineView];
        
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.top.mas_equalTo(self.tagLabel.mas_bottom).mas_equalTo(8);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    return _lineView;
}

- (void)setPushStr:(NSString *)pushStr
{
    _pushStr = pushStr;
    
    if ([_pushStr isEqualToString:@"个人发布"]) {
        
        UIButton *button = [[UIButton alloc] init];
        [self.contentView addSubview:button];
        
        [button addSubview:self.avarImgView];
        [button addSubview:self.niceLbl];
        
        [button addTarget:self action:@selector(didPersonClick) forControlEvents:UIControlEventTouchUpInside];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(self.lineView.mas_bottom);
            make.height.mas_equalTo(30);
            
            make.right.mas_equalTo(-105);
            make.bottom.mas_equalTo(0);
        }];
        
        
        [self.avarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
            make.centerY.mas_equalTo(0);
            
        }];
        
        
        [self.niceLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(self.avarImgView.mas_right).mas_equalTo(5);
            make.centerY.mas_equalTo(0);
            
        }];
        
        [button mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.right.mas_equalTo(self.niceLbl.mas_right).mas_equalTo(5);
        }];
        
    }else
    {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:view];
        
        [view addSubview:self.platformLbl];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            
            
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(self.lineView.mas_bottom);
            make.height.mas_equalTo(30);
            
            make.right.mas_equalTo(-105);
            make.bottom.mas_equalTo(0);
        }];
        
        [self.platformLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
        }];
        
        
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.right.mas_equalTo(self.platformLbl.mas_right).mas_equalTo(5);
        }];
    }
}

- (UIImageView *)avarImgView
{
    if (!_avarImgView) {
        
        _avarImgView = [[UIImageView alloc] init];
        _avarImgView.layer.masksToBounds = YES;
        _avarImgView.layer.cornerRadius = 10;
    }
    return _avarImgView;
}

- (UILabel *)niceLbl
{
    if (!_niceLbl) {
        
        _niceLbl = [[UILabel alloc] init];
        _niceLbl.font = kFont(12);
        
        _niceLbl.textColor = [UIColor orangeColor];
    }
    return _niceLbl;
}


- (UILabel *)platformLbl
{
    if (!_platformLbl) {
        
        _platformLbl = [[UILabel alloc] init];
        _platformLbl.textColor = RGBCOLOR(176, 176, 176);
        _platformLbl.font = kFont(12);
        
        
    }
    return _platformLbl;
}

- (void)setInterval:(NSTimeInterval)interval
{
    _interval = interval;
    
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.height.mas_equalTo(30);
        
        make.left.mas_equalTo(105);
        make.bottom.mas_equalTo(0);
    }];
    
    
    if (interval > 0) {
        
       
        
        
        
    }else
    {
        [self outTimeImg];
    }
    
}



- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (void)didPersonClick
{
    NZLog(@"个人中心");
    
    if ([self.delegate performSelector:@selector(tenderTableViewCellDidClickPerson:)]) {
        
        [self.delegate tenderTableViewCellDidClickPerson:10];
    }
}

@end
