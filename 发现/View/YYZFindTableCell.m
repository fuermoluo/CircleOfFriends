//
//  YYZFindTableCell.m
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/9.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import "YYZFindTableCell.h"
#import "SDWeiXinPhotoContainerView.h"
#import "UIView+SDAutoLayout.h"
#import "YYZRelatedProductsView.h"
#import "YYZUserHomeViewController.h"
#import <CoreText/CoreText.h>

const CGFloat contentLabelFontSize = 15;
CGFloat maxContentLabelHeight = 0; // 根据具体font而定

@implementation YYZFindTableCell
{
    UIImageView *_iconView;
    UILabel *_nameLable;
    
    UIButton *_attentionBtn;//关注按钮
    
    UILabel *_contentLabel;
    SDWeiXinPhotoContainerView *_picContainerView;
    YYZRelatedProductsView * _productsView;
    UILabel *_addressLbl;
    UILabel *_timeLabel;
    UIButton *_browserButton;
    UIButton *_commentButton;
    
    UIButton * _deleteBtn;
    UIImageView * _topView;
    
    
    //SDTimeLineCellCommentView *_commentView;
    //SDTimeLineCellOperationMenu *_operationMenu;
}

#pragma mark - 浏览量|访客
- (void)clickBrowser:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(clickBrowser:)]) {
        [self.delegate clickBrowser:self.indexPath];
    }
}

#pragma mark - 点击头像

- (void)clickAvatar:(UIGestureRecognizer *)gesture
{
    NSString *userID = [NSString stringWithFormat:@"%zd", gesture.view.tag];
    [self.supNavigationController pushViewController:[[YYZUserHomeViewController alloc]initWithOtherID:userID] animated:YES];
}

#pragma mark -- 删除
-(void)delete
{
    if ([self.delegate respondsToSelector:@selector(clickDeleteWith:)]) {
        [self.delegate clickDeleteWith:self.indexPath];
    }
}

#pragma mark - 关注
- (void)clickAttention:(UIButton *)sender
{
    YYZUser*user = [YYZSave user];
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"post_id=%@&post_table=user&timestamp=%@&user_id=%@&nado", @(sender.tag), timestampstr, user.userID];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"post_id":@(sender.tag),
      @"user_id":user.userID,
      @"post_table":@"user",
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@Focus",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
    
    APPDELEGATE.window.userInteractionEnabled = NO;
    
    AFHTTPSessionManager *manager = [GCService sharedManager];
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        
        APPDELEGATE.window.userInteractionEnabled = YES;
        
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 0 )
        {
            sender.selected = !sender.selected;
            [MBProgressHUD showSuccess:[responseObject objectForKey:@"info"]];
            
            if ([self.delegate respondsToSelector:@selector(clickFoucsReload)]) {
                [self.delegate clickFoucsReload];
            }
        }
        else
        {
            [MBProgressHUD showError:[responseObject objectForKey:@"info"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
        [CommonMethod altermethord:TipFailure andmessagestr:TipFailureDetail andconcelstr:@"确定"];
        
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        
        APPDELEGATE.window.userInteractionEnabled = YES;
    }];
    

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initSubviews];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)initSubviews
{
    _iconView = [UIImageView new];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickAvatar:)];
    _iconView.userInteractionEnabled = YES;
    [_iconView addGestureRecognizer:tap];
    
    
    _topView = [UIImageView new];
    
    _nameLable = [UILabel labelWithText:@"" font:kFont14 textColor:BlackColor backGroundColor:ClearColor superView:self.contentView];
    
    _attentionBtn = [UIButton buttonWithTitle:@"关注" font:kFont12 normalColor:ThemeColor selectedColor:ThemeColor buttonTag:0 backGroundColor:WhiteColor target:self action:@selector(clickAttention:) showView:self.contentView];
    
    [_attentionBtn setTitle:@"已关注" forState:UIControlStateSelected];
    
    _attentionBtn.layer.borderColor = ThemeColor.CGColor;
    _attentionBtn.layer.borderWidth = 0.5;
    _attentionBtn.layer.masksToBounds = YES;
    _attentionBtn.layer.cornerRadius = 13;
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
    _contentLabel.numberOfLines = 0;
    if (maxContentLabelHeight == 0) {
        maxContentLabelHeight = _contentLabel.font.lineHeight * 3;
    }
    _picContainerView = [SDWeiXinPhotoContainerView new];
    
    _productsView = [[YYZRelatedProductsView alloc]init];;
    //_productsView.backgroundColor = [UIColor blueColor];
    
    _addressLbl = [UILabel labelWithText:@"" font:kFont12 textColor:BlackGrayColor backGroundColor:ClearColor superView:self.contentView];
    
    _timeLabel = [UILabel labelWithText:@"" font:kFont12 textColor:BlackGrayColor backGroundColor:ClearColor superView:self.contentView];

    
    //浏览量
    _browserButton = [UIButton buttonWithLeftImage:@"find_look" title:@"" font:kFont12 titleColor:GrayBlackColor backGroundColor:ClearColor target:self action:@selector(clickBrowser:) showView:self.contentView];
    [_browserButton setBackgroundImage:[UIImage imageNamed:@"find_circle"] forState:0];
    
    //评论
    _commentButton = [UIButton buttonWithLeftImage:@"find_comment" title:@"" font:kFont12 titleColor:GrayBlackColor backGroundColor:ClearColor target:self action:nil showView:self.contentView];
    _commentButton.userInteractionEnabled = NO;
    [_commentButton setBackgroundImage:[UIImage imageNamed:@"find_circle"] forState:0];
    
    _deleteBtn =[UIButton buttonWithLeftImage:@"find_delete" title:@"" font:kFont12 titleColor:GrayBlackColor backGroundColor:ClearColor target:self action:@selector(delete) showView:self.contentView];
    //_deleteBtn.userInteractionEnabled = NO;
    //[_deleteBtn setBackgroundImage:[UIImage imageNamed:@"find_circle"] forState:0];
    
    NSArray *views = @[_iconView, _nameLable, _attentionBtn, _contentLabel, _picContainerView,_productsView, _addressLbl, _timeLabel,_deleteBtn,_topView];//, _browserButton, _commentButton];
    
    [self.contentView sd_addSubviews:views];
    
    
    UIView *contentView = self.contentView;
    CGFloat margin = 10;

    _iconView.sd_layout
    .leftSpaceToView(contentView, margin)
    .topSpaceToView(contentView, margin + 5)
    .widthIs(40)
    .heightIs(40);
    
    _nameLable.sd_layout
    .leftSpaceToView(_iconView, margin)
    .topEqualToView(_iconView)
    .heightIs(18);
    [_nameLable setSingleLineAutoResizeWithMaxWidth:200];
    
    
    _attentionBtn.sd_layout
    .rightSpaceToView(contentView, margin)
    .topEqualToView(_iconView)
    .heightIs(26)
    .widthIs(55);
    
    _contentLabel.sd_layout
    .leftEqualToView(_nameLable)
    .topSpaceToView(_nameLable, margin)
    .rightSpaceToView(contentView, margin)
    .autoHeightRatio(0);
    
    _deleteBtn.sd_layout.
    rightEqualToView(_contentLabel)
    .topEqualToView(_iconView)
    .widthIs(40)
    .heightIs(40);
    
    _topView.sd_layout
    .rightEqualToView(_contentLabel)
    .topEqualToView(_iconView)
    .widthIs(20)
    .heightIs(36);

    
    _picContainerView.sd_layout
    .leftEqualToView(_contentLabel); // 已经在内部实现宽度和高度自适应所以不需要再设置宽度高度，top值是具体有无图片在setModel方法中设置
    
    _productsView.sd_layout
    .leftEqualToView(_picContainerView)
    .rightSpaceToView(self.contentView, kMargin);
//    .widthIs(ScreenWidth - 50 - kMargin);

    _addressLbl.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_productsView, margin)
    .widthIs(300)
    .autoHeightRatio(0);
    //[_addressLbl setSingleLineAutoResizeWithMaxWidth:300];
    
    
    _timeLabel.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_addressLbl, margin)
    .widthIs(100)
    .heightIs(18);
    //[_timeLabel setSingleLineAutoResizeWithMaxWidth:350];
    

    _commentButton.sd_layout
    .rightEqualToView(self.contentView)
    .rightSpaceToView(self.contentView, margin)
    .topSpaceToView(_addressLbl, margin)
    .widthIs(60)
    .heightIs(20);
    
    _browserButton.sd_layout
    .rightEqualToView(_commentButton)
    .rightSpaceToView(_commentButton, margin)
    .topSpaceToView(_addressLbl, margin)
    .widthIs(60)
    .heightIs(20);
    
    
    
}


- (NSArray *)getLinesArrayOfStringInLabel:(UILabel *)label{
    
    NSString *text = [label text];
    UIFont *font = [label font];
    CGRect rect = CGRectMake(0, 0, ScreenWidth-40, MAXFLOAT);//[label frame];
    
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge  id)myFont range:NSMakeRange(0, attStr.length)];
    CFRelease(myFont);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0.0]));
        //NSLog(@"''''''''''''''''''%@",lineString);
        [linesArray addObject:lineString];
    }
    
    CGPathRelease(path);
    CFRelease( frame );
    CFRelease(frameSetter);
    return (NSArray *)linesArray;
}

- (void)setModel:(SDTimeLineCellModel *)model
{
    _model = model;
    
     _topView.hidden = !model.is_top;
    
    _deleteBtn.hidden = !model.isDelete;
    
    YYZUser *user = [YYZSave user];
    
    _attentionBtn.tag = [model.user_id integerValue];
    
    if (!user.userID || [model.user_id isEqual:@"0"] || [user.userID isEqual:model.user_id]) {
        _attentionBtn.hidden = YES;
    }
    else
    {
        _attentionBtn.hidden = model.isHiddenFoucs;//[user.userID isEqual:model.user_id] ||
        
        _attentionBtn.selected = model.is_foucs;
    }
    
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:model.iconName] placeholderImage:[UIImage imageNamed:AvatarDefault]];
    _iconView.tag = [model.user_id integerValue];
    
    
    _iconView.userInteractionEnabled = ![model.user_id isEqual:@"0"];
    
    _nameLable.text = model.name;
    
    _contentLabel.text = model.msgContent;
    
    if (model.isShowPart) {
        
        NSArray *arr = [self getLinesArrayOfStringInLabel:_contentLabel];
        
        if (arr.count > 6) {
            NSString *content = [NSString stringWithFormat:@"%@%@%@%@%@%@...", arr[0], arr[1], arr[2], arr[3], arr[4], arr[5]];
            _contentLabel.attributedText = [NSString attributedStringWithColorTitle:@"全文" normalTitle:@"" frontTitle:content diffentColor:ThemeColor];
        }
        
    }
    _picContainerView.picPathStringsArray = model.picNamesArray;
    
    CGFloat picContainerTopMargin = 0;
    if (model.picNamesArray.count) {
        picContainerTopMargin = 10;
    }
    _picContainerView.sd_layout.topSpaceToView(_contentLabel, picContainerTopMargin);
    
    _productsView.proArr = model.proArray;
  
    _productsView.sd_layout
    .topSpaceToView(_picContainerView, 0);
    
    if (model.proArray.count != 0) {
        _productsView.sd_layout.heightIs((KActualH(100) + 5)*model.proArray.count + 5);
    }else{
        _productsView.sd_layout.heightIs(0);
    }
    
    __weak typeof(self) weakSelf = self;
    _productsView.relateBlock = ^(NSInteger tag)
    {
        if ([weakSelf.delegate respondsToSelector:@selector(clickProductWithIndexPath:productIndex:)]) {
            [weakSelf.delegate clickProductWithIndexPath:weakSelf.indexPath productIndex:tag];
        }
    };
    
    if (![model.address isEqualToString:@""]) {
        _addressLbl.attributedText = [NSString attributeWithTitle:@"" behindText:[NSString stringWithFormat:@" %@", model.address] imageName:@"place"];
    }
    
    
    UIView *bottomView = _browserButton;

    [self setupAutoHeightWithBottomView:bottomView bottomMargin:15];
    
    _timeLabel.text = model.create_time;
    
    [_browserButton setTitle:model.browse forState:0];
    
    [_commentButton setTitle:model.comment_sum forState:0];
    
    
    _browserButton.hidden = model.isHiddenBrowser;
    _commentButton.hidden = _browserButton.hidden;
}
@end

#import "YYZUserHomeViewController.h"

@implementation YYZFindDetailTableCell

#pragma mark - 查看用户主页
- (void)clickUser:(UIGestureRecognizer *)gesture
{
    [self.supNavigationController pushViewController:[[YYZUserHomeViewController alloc]initWithOtherID:[NSString stringWithFormat:@"%zd", gesture.view.tag]] animated:YES];
}

- (UIView *)bgView
{
    if (!_bgView) {
        
        _bgView = [UIView viewWithBackgroundColor:TableColor superView:self];
        
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(50);
            make.right.top.bottom.mas_equalTo(0);
            
        }];
        
        _bgView.hidden = YES;
    }
    return _bgView;
}

- (UILabel *)nameLbl
{
    if (!_nameLbl) {
        
        _nameLbl = [UILabel labelWithText:@"" font:kFont12 textColor:RGBCOLOR(108, 124, 191) backGroundColor:ClearColor superView:self];
        
        CGFloat leftM = self.bgView.hidden ? 50 : 58;
        
        [_nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        
            make.left.mas_equalTo(leftM);
            make.top.mas_equalTo(8);
            make.width.mas_equalTo(20);
        }];
        
        
        _nameLbl.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickUser:)];
        [_nameLbl addGestureRecognizer:tap];
        
    }
    return _nameLbl;
}

- (UILabel *)tipLbl
{
    if (!_tipLbl) {
        
        _tipLbl = [UILabel labelWithText:@"回复" font:kFont12 textColor:BlackColor backGroundColor:ClearColor superView:self];
        
        CGFloat width = [NSString sizeWithText:_tipLbl.text font:_tipLbl.font maxSize:CGSizeMake(MAXFLOAT, 15)].width+5;
        
        [_tipLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.mas_equalTo(width);
            make.left.mas_equalTo(self.nameLbl.mas_right);
            make.top.mas_equalTo(8);
        }];
        
    }
    return _tipLbl;
}

- (UILabel *)otherNameLbl
{//计算宽度
    if (!_otherNameLbl) {
        
        _otherNameLbl = [UILabel labelWithText:@"" font:kFont12 textColor:RGBCOLOR(108, 124, 191) backGroundColor:ClearColor superView:self];
        
        [_otherNameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(self.tipLbl.mas_right);
            make.top.mas_equalTo(8);
            make.width.mas_equalTo(20);
        }];
        
        _otherNameLbl.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickUser:)];
        [_otherNameLbl addGestureRecognizer:tap];
    }
    return _otherNameLbl;
}


- (UILabel *)contentLbl
{
    if (!_contentLbl) {
        
        _contentLbl = [UILabel labelWithText:@"" font:kFont12 textColor:BlackColor backGroundColor:ClearColor superView:self];
    
        
        [_contentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(self.nameLbl.mas_left);
            make.right.mas_equalTo(-kMargin);
            make.top.mas_equalTo(self.nameLbl.mas_top);
            make.bottom.mas_equalTo(-8);
        }];

        
    }
    return _contentLbl;
}

@end
