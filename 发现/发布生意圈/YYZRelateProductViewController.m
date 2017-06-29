//
//  YYZRelateProductViewController.m
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/19.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import "YYZRelateProductViewController.h"
#import "YYZRelateProductTableCell.h"

#define kRelateCellID @"relateCellID"

@interface YYZRelateProductViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger pageNum;
}
@property (nonatomic, strong) UIView *defaultView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *productMulArr;

@end

@implementation YYZRelateProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = TableColor;
    
    self.navigationItem.title = @"添加关联产品";
    
    [self defaultView];
    [self tableView];
    
    pageNum = 1;
    
    [self tableViewPullUp];
    
    [self requestData];
}

#pragma mark - 确定
- (void)clickFinish
{
    NSMutableArray *mulArr = [[NSMutableArray alloc]initWithArray:@[]];
    
    for (NSDictionary *dict in self.productMulArr) {
        if ([dict[@"selectImage"] isEqualToString:@"set_remember_red"]) {
            [mulArr addObject:dict];
        }
    }
    
    if (_relateBlock) {
        _relateBlock(mulArr);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableView delegate && datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *mulDict = [[NSMutableDictionary alloc]initWithDictionary:self.productMulArr[indexPath.row]];
    
    if ([self.productMulArr[indexPath.row][@"selectImage"] isEqualToString:@"set_remember_gray"]) {
        [mulDict setValue:@"set_remember_red" forKey:@"selectImage"];
    }
    else
        [mulDict setValue:@"set_remember_gray" forKey:@"selectImage"];
    
    [self.productMulArr replaceObjectAtIndex:indexPath.row withObject:mulDict];
    
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YYZRelateProductTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kRelateCellID];
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.separatorInset = UIEdgeInsetsMake(0, kMargin, 0, kMargin);
    
    NSDictionary *cellDict = self.productMulArr[indexPath.row];
    
    [cell.productImgView sd_setImageWithURL:[NSURL URLWithString:cellDict[@"product_image"]]];
    
    cell.selectImgView.image = [UIImage imageNamed:cellDict[@"selectImage"]];
    
    cell.titleLbl.text = cellDict[@"product_title"];
    
    cell.priceLbl.text = [NSString stringWithFormat:@"¥%@", cellDict[@"product_price"]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.productMulArr count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark - 获取数据
- (void)tableViewPullUp
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        pageNum = 1;
        
        [self requestData];
    }];
    
    
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        pageNum++;
        
        [self requestData];
    }];
    
    self.tableView.mj_footer.hidden = YES;
}


- (void)requestData
{
    YYZUser *user = [YYZSave user];
    
    NSString *userID = @"";
    
    if (user.userID) {
        userID = user.userID;
    }
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"page=%@&timestamp=%@&user_id=%@&nado", @(pageNum), timestampstr, @([userID integerValue])];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"user_id": @([userID integerValue]),
      @"page":@(pageNum),
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@GetMyProductList",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
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
            NSArray *dataArr = [responseObject valueForKey:@"data"];
            
            NSMutableArray *mulArr = [[NSMutableArray alloc]initWithArray:@[]];
            
            for (int i = 0; i < [dataArr count]; i++) {
                
                NSDictionary *dict = dataArr[i];
                NSMutableDictionary *mulDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
                
                [mulDict setValue:@"set_remember_gray" forKey:@"selectImage"];
                
                
                [mulArr addObject:mulDict];
                
                
            }
            
            if (pageNum == 1) {
                self.productMulArr = mulArr;
            }
            else
            {
                [self.productMulArr insertObjects:mulArr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.productMulArr count], [mulArr count])]];
            }

            
            self.tableView.mj_footer.hidden = self.productMulArr.count < 10;
            
            [self.tableView reloadData];
            
            self.tableView.hidden = self.productMulArr.count==0;
            self.defaultView.hidden = self.productMulArr.count>0;
            
            if ([self.productMulArr count] > 0) {
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem itemWithTarget:self action:@selector(clickFinish) leftImage:nil selectImage:nil title:@"确定" titleColor:BlackColor isRightItem:YES titleFont:kFont15 createdButton:nil];
            }
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
        
        UIView *view = [UIView viewWithBackgroundColor:TableColor superView:self.view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(KActualH(60));
            make.top.mas_equalTo(kNavigationH);
        }];
        
        UILabel *label = [UILabel labelWithText:@"在这里点击你想要关联的商品" font:kFont12 textColor:GrayTipColor backGroundColor:ClearColor superView:view];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(kMargin);
            make.centerY.mas_equalTo(0);
            
        }];

        _tableView = [[UITableView alloc]init];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.backgroundColor = WhiteColor;
        
        _tableView.tableFooterView = [UIView new];
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        [self.view addSubview:_tableView];
        
        [_tableView registerClass:[YYZRelateProductTableCell class] forCellReuseIdentifier:kRelateCellID];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.mas_equalTo(view.mas_bottom);
            make.left.right.bottom.mas_equalTo(0);
            
        }];
        
    }
    return _tableView;
}

- (UIView *)defaultView
{
    if (!_defaultView) {
        
        _defaultView = [UIView viewWithBackgroundColor:TableColor superView:self.view];
        
        [_defaultView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(kNavigationH);
            
        }];
        
        
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"find_productDefault"]];
        
        [_defaultView addSubview:imgView];
        
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(kTopH);
        }];
        
        UILabel *tipLbl = [UILabel labelWithText:[NSString stringWithFormat:@"%@\n%@", @"您还没有发布过商品", @"快去发布一个..."] font:kFont17 textColor:GrayBlackColor backGroundColor:ClearColor superView:_defaultView];
        
        [tipLbl mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(imgView.mas_bottom).mas_equalTo(20);
            
        }];
    }
    return _defaultView;
}


@end
