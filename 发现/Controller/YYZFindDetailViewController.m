//
//  YYZFindDetailViewController.m
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/20.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import "YYZFindDetailViewController.h"
#import "YYZFindTableCell.h"
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "SDTimeLineCellModel.h"
#import "YYZStoreDetailViewController.h"

#define kDetailCommentID @"kDetailCommentID"
#define kFindDetailCellID @"kFindDetailCellID"

@interface YYZFindDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SDTimeLineCellModelDelegate>
{
    NSString *_dynamic_id;
}
@property (nonatomic, strong) UIView *commentView;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SDTimeLineCellModel *findModel;

@property (nonatomic, strong) NSArray *commentArr;

@end

@implementation YYZFindDetailViewController

- (instancetype)initWithDynamicID:(NSString *)dynamic_id
{
    if (self = [super init]) {
        _dynamic_id = dynamic_id;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"评论";
    
    self.view.backgroundColor = WhiteColor;
    
    [self commentView];
    
    [self textField];
    
    [self tableView];
    
    [self requestData];
}

#pragma mark - textField
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    YYZUser *user = [YYZSave user];
    
    if (!user.userID) {
        [textField resignFirstResponder];
        [GCService tipLoginFromController:self];
        return;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
 
    if (textField.text.length == 0) {
        return;
    }
    
    YYZUser *user = [YYZSave user];
    
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"content=%@&dynamic_id=%@&timestamp=%@&to_user_id=%@&user_id=%@&nado", textField.text, _dynamic_id,  timestampstr, @(textField.tag), @([user.userID integerValue])];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"content":textField.text,
      @"to_user_id":@(textField.tag),
      @"dynamic_id":_dynamic_id,
      @"user_id": @([user.userID integerValue]),
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@AddDynamic_Comment",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
    
    APPDELEGATE.window.userInteractionEnabled = NO;
    
    AFHTTPSessionManager *manager = [GCService sharedManager];
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        APPDELEGATE.window.userInteractionEnabled = YES;
        
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 0 )
        {
            [self requestData];
            
            self.textField.text = @"";
            
            [MBProgressHUD showSuccess:[responseObject objectForKey:@"info"]];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - tableView delegate&&datasource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        
        NSDictionary *cellDict = self.commentArr[indexPath.row];
        
        [self.textField becomeFirstResponder];
        
        self.textField.tag = [cellDict[@"user"][@"user_id"] integerValue];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        YYZFindTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kFindDetailCellID];
        cell.indexPath = indexPath;
        cell.model = self.findModel;
        [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.supNavigationController = self.navigationController;
        cell.delegate = self;
        return cell;
    }
    
    YYZFindDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailCommentID];
    
    NSDictionary *cellDict = self.commentArr[indexPath.row];
    
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.supNavigationController = self.navigationController;
    
    cell.nameLbl.text = cellDict[@"user"][@"user_name"];
    cell.nameLbl.tag = [cellDict[@"user"][@"user_id"] integerValue];
    
    CGFloat width = [NSString sizeWithText:cell.nameLbl.text font:cell.nameLbl.font maxSize:CGSizeMake(MAXFLOAT, 15)].width+5;
    [cell.nameLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
    
    //YYZUser *user = [YYZSave user];
    
    if (![cellDict[@"to_user"][@"user_name"] isEqualToString:@""] && ![cellDict[@"to_user"][@"user_id"] isEqual:cellDict[@"user"][@"user_id"]]) {
        
        cell.tipLbl.hidden = NO;
        cell.otherNameLbl.hidden = NO;
        
        cell.tipLbl.text = @"回复";
        cell.otherNameLbl.text = cellDict[@"to_user"][@"user_name"];
        cell.otherNameLbl.tag = [cellDict[@"to_user"][@"user_id"] integerValue];

        CGFloat width = [NSString sizeWithText:cell.otherNameLbl.text font:cell.otherNameLbl.font maxSize:CGSizeMake(MAXFLOAT, 15)].width+5;
        
        [cell.otherNameLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
    }
    else
    {
        cell.tipLbl.hidden = YES;
        cell.otherNameLbl.hidden = YES;
        //cell.otherNameLbl.text = @"";
    }
    
    NSString *frontStr = cell.nameLbl.text;
    
    if (!cell.otherNameLbl.hidden) {
        frontStr = [NSString stringWithFormat:@"%@回复%@", cell.nameLbl.text, cell.otherNameLbl.text];
    }
    
    CGFloat contentWidth = [NSString sizeWithText:frontStr font:kFont12 maxSize:CGSizeMake(MAXFLOAT, 15)].width+kMargin;
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc]init];
    
    paraStyle.firstLineHeadIndent = contentWidth;
    
    cell.contentLbl.text = [NSString stringWithFormat:@"：%@", cellDict[@"content"]];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cell.contentLbl.text];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, [cell.contentLbl.text length])];
    
    cell.contentLbl.attributedText = attributedString;
    [cell.contentLbl sizeToFit];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return UITableViewAutomaticDimension;
    }
    else
    {
        // >>>>>>>>>>>>>>>>>>>>> * cell自适应 * >>>>>>>>>>>>>>>>>>>>>>>>
        return [self.tableView cellHeightForIndexPath:indexPath model:self.findModel keyPath:@"model" cellClass:[YYZFindTableCell class] contentViewWidth:[self cellContentViewWith]];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return UITableViewAutomaticDimension;
    }
    else
    {
        // >>>>>>>>>>>>>>>>>>>>> * cell自适应 * >>>>>>>>>>>>>>>>>>>>>>>>
        return [self.tableView cellHeightForIndexPath:indexPath model:self.findModel keyPath:@"model" cellClass:[YYZFindTableCell class] contentViewWidth:[self cellContentViewWith]];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.findModel ? 2 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section==0 ? 1 : [self.commentArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return self.commentArr.count>0 ? kMargin : 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView viewWithBackgroundColor:WhiteColor superView:nil];
    view.height = kMargin;
    
    UIView *line = [UIView viewWithBackgroundColor:SeparatorCOLOR superView:view];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.mas_equalTo(0);
        make.left.mas_equalTo(kMargin);
    }];
    
    return  self.commentArr.count>0 ? view : nil;
}


- (CGFloat)cellContentViewWith
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // 适配ios7横屏
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait && [[UIDevice currentDevice].systemVersion floatValue] < 8) {
        width = [UIScreen mainScreen].bounds.size.height;
    }
    return width;
}

#pragma mark - 查看关联产品
- (void)clickProductWithIndexPath:(NSIndexPath *)indexPath productIndex:(NSInteger)index
{
    YYZStoreDetailViewController *storeDetailVC = [[YYZStoreDetailViewController alloc]init];
    
    storeDetailVC.storeID = self.findModel.proArray[index][@"product_id"];
    
    [self.navigationController pushViewController:storeDetailVC animated:YES];
}

#pragma mark - 获取数据

- (void)requestData
{
    YYZUser *user = [YYZSave user];
    
    NSString *userID = @"";
    
    if (user.userID) {
        userID = user.userID;
    }
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"dynamic_id=%@&timestamp=%@&user_id=%@&nado", _dynamic_id,  timestampstr, @([userID integerValue])];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"dynamic_id":_dynamic_id,
      @"user_id": @([userID integerValue]),
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@GetDynamicDetail",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
    
    APPDELEGATE.window.userInteractionEnabled = NO;
    
    AFHTTPSessionManager *manager = [GCService sharedManager];
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.tableView.mj_footer endRefreshing];
        
        [self.tableView.mj_header endRefreshing];
        
        
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        APPDELEGATE.window.userInteractionEnabled = YES;
        
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 0 )
        {
            NSDictionary *dataDict = [responseObject valueForKey:@"data"];
            
            self.findModel = [SDTimeLineCellModel new];
            self.findModel.iconName = dataDict[@"user_img"];
            self.findModel.name = dataDict[@"user_name"];
            self.findModel.msgContent = dataDict[@"content"];
            self.findModel.proArray = dataDict[@"products"];
            self.findModel.is_top = NO;
            self.findModel.is_foucs = [dataDict[@"is_foucs"] boolValue];//是否关注
            self.findModel.comment_sum = [NSString stringWithFormat:@"%@", dataDict[@"comment_sum"]];
            self.findModel.browse = [NSString stringWithFormat:@"%@", dataDict[@"browse"]];
            self.findModel.dynamic_id = dataDict[@"dynamic_id"];
            self.findModel.user_id = dataDict[@"user_id"];
            self.findModel.create_time = [NSString stringWithFormat:@"%@", dataDict[@"create_time"]];
            
            self.findModel.isDelete = NO;
            self.findModel.isHiddenBrowser = YES;
            self.findModel.isShowPart = NO;
            
            self.findModel.lat = [dataDict[@"lat"] floatValue];
            self.findModel.lng = [dataDict[@"lng"] floatValue];
            self.findModel.address = dataDict[@"address"];
            
            NSMutableArray *tempMulArr = [[NSMutableArray alloc]initWithArray:@[]];
            for (int j = 0; j < [dataDict[@"images"] count]; j++) {
                [tempMulArr addObject:dataDict[@"images"][j][@"link"]];
            }
            
            self.findModel.picNamesArray = tempMulArr;
            
            
            self.commentArr = dataDict[@"comments"];
            
            [self.tableView reloadData];
            
            
            self.textField.tag = [dataDict[@"user_id"] integerValue];
        }
        else
        {
            [MBProgressHUD showError:[responseObject objectForKey:@"info"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.tableView.mj_footer endRefreshing];
        
        [self.tableView.mj_header endRefreshing];
        
        [CommonMethod altermethord:TipFailure andmessagestr:TipFailureDetail andconcelstr:@"确定"];
        
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        
        APPDELEGATE.window.userInteractionEnabled = YES;
    }];
    
}


#pragma mark - 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.backgroundColor = WhiteColor;
        
        _tableView.separatorColor = ClearColor;
        
        _tableView.tableFooterView = [UIView new];
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        [self.view addSubview:_tableView];
        
        [_tableView registerClass:[YYZFindDetailTableCell class] forCellReuseIdentifier:kDetailCommentID];
        
        [_tableView registerClass:[YYZFindTableCell class] forCellReuseIdentifier:kFindDetailCellID];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(kNavigationH);
            make.bottom.mas_equalTo(self.commentView.mas_top);
            make.left.right.mas_equalTo(0);
            
        }];
        
    }
    return _tableView;
}


- (UIView *)commentView
{
    if (!_commentView) {
        
        _commentView = [UIView viewWithBackgroundColor:TableColor superView:self.view];
        
        [_commentView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(50);
            
        }];
        
    }
    return _commentView;
    
}

- (UITextField *)textField
{
    if (!_textField) {
        
        _textField = [[UITextField alloc]init];
        
        _textField.backgroundColor = WhiteColor;
        
        _textField.placeholder = @"评论";
        
        [_textField setValue:kFont12 forKeyPath:@"_placeholderLabel.font"];
        [_textField setValue:GrayTipColor forKeyPath:@"_placeholderLabel.textColor"];
        
        _textField.layer.borderWidth = 1;
        _textField.layer.borderColor = SeparatorCOLOR.CGColor;
        
        _textField.layer.cornerRadius = 2;
        _textField.clipsToBounds = YES;
        
        UIView *line = [UIView viewWithBackgroundColor:WhiteColor superView:nil];
        line.width = kMargin;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.leftView = line;
        
        _textField.delegate = self;
        
        [_textField setReturnKeyType:UIReturnKeyDone];
        
        [self.commentView addSubview:_textField];
        
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.mas_equalTo(0);
            make.left.top.mas_equalTo(kTableMinHeight);
        }];
    }
    return _textField;
}

@end
