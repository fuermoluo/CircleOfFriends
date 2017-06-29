//
//  YYZFindViewController.m
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/9.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import "YYZFindViewController.h"
#import "YYZFindTableCell.h"
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "SDTimeLineCellModel.h"
#import "YYZFindDetailViewController.h"
#import "YYZPublishFindViewController.h"
#import "YYZWealthTableController.h"
#import "YYZCollectShopTableCell.h"
#import "YYZUserHomeViewController.h"
#import "YYZBrowserTableController.h"
#import "YYZStoreDetailViewController.h"

#define kAttentionCellID @"kAttentionCellID"

@interface YYZFindViewController ()<UITableViewDelegate,UITableViewDataSource, SDTimeLineCellModelDelegate>
{
    UIView *_divideView;
    UIView *_divideLineView;
    NSMutableArray *btnArr;
    
    NSInteger pageNum;
}
/**菜单栏*/
@property (nonatomic, strong) UIView *nanbaiView;

@property (nonatomic, strong) UITableView *tableView;

//顶部按钮的下标
@property (nonatomic,assign) NSInteger selectedIndex;

//生意圈｜我的动态数据源
@property (nonatomic, strong) NSMutableArray *findMulArr;
//我的关注数据源
@property (nonatomic, strong) NSMutableArray *attentionMulArr;


@end

@implementation YYZFindViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"发现";
    
    /////////////////////
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(clickPublish) image:@"find_publish" highImage:@"find_publish"];
    
    [self nanbaiView];
    [self tableView];
    
    pageNum = 1;
    
    [self tableViewPullUp];
    
    if (_selectedIndex==2) {
        [self requestAttention];
    }
    else
        [self requestData];
    
}

//////////////////////////////
#pragma mark - 发布生意圈
- (void)clickPublish
{
    YYZUser *user = [YYZSave user];
    
    if (user.userID) {
        YYZPublishFindViewController *publishFindVC = [[YYZPublishFindViewController alloc]init];
        
        publishFindVC.publishFindBlock = ^(NSString *money)
        {
            
            [self requestData];
            
            if ([money floatValue] > 0) {
                NSString *title = !([money floatValue] > 0) ? @"发布成功" : [NSString stringWithFormat:@"%@\n并获得%@元红包", @"发布成功", money];
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    YYZWealthTableController *wealthTableVC = [[YYZWealthTableController alloc]initWithStyle:UITableViewStyleGrouped];
                    
                    [self.navigationController pushViewController:wealthTableVC animated:YES];
                    
                }]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else
            {
                [CommonMethod altermethord:@"发布成功" andmessagestr:@"" andconcelstr:@"确定"];
            }
            
        };
        
        [self.navigationController pushViewController:publishFindVC animated:YES];
    }
    else
    {
        [GCService tipLoginFromController:self];
    }
    
}

//////////////////////


#pragma -- mark 生意圈｜我的动态｜我的关注
-(void)clickSegmentButton:(UIButton *)sender
{
    UIButton *oldSelectButton = (UIButton*)[_nanbaiView viewWithTag:(1000 + _selectedIndex)];
    [oldSelectButton setSelected:NO];
    
    [sender setSelected:YES];
    _selectedIndex = sender.tag - 1000;
    
    CGFloat buttonW = ScreenWidth/3;
    
    [UIView animateWithDuration:0.1 animations:^{
        _divideView.frame = CGRectMake(kMargin+ ( buttonW) * _selectedIndex, _divideView.frame.origin.y, _divideView.width, _divideView.frame.size.height);
    }];
    
    pageNum = 1;
    
    YYZUser *user = [YYZSave user];
    
    if (!user.userID && _selectedIndex!= 0) {
        
        [GCService tipLoginFromController:self];
        
        self.findMulArr = [NSMutableArray array];
        self.attentionMulArr = [NSMutableArray array];
        [self.tableView reloadData];
        
        return;
    }
    
    if (_selectedIndex == 2) {
        //我的关注
        [self requestAttention];
    }
    else
        [self requestData];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _selectedIndex==2 ? [self.attentionMulArr count] : [self.findMulArr count];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedIndex==2) {
        return UITableViewAutomaticDimension;
    }
    else
    {
        // >>>>>>>>>>>>>>>>>>>>> * cell自适应 * >>>>>>>>>>>>>>>>>>>>>>>>
        id model = self.findMulArr[indexPath.row];
        return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[YYZFindTableCell class] contentViewWidth:[self cellContentViewWith]];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedIndex==2) {
        return UITableViewAutomaticDimension;
    }
    else
    {
        // >>>>>>>>>>>>>>>>>>>>> * cell自适应 * >>>>>>>>>>>>>>>>>>>>>>>>
        id model = self.findMulArr[indexPath.row];
        return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[YYZFindTableCell class] contentViewWidth:[self cellContentViewWith]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_selectedIndex!=2) {
        
        YYZFindTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYZFindTableCell"];
        cell.indexPath = indexPath;
        cell.delegate =self;
        cell.model = self.findMulArr[indexPath.row];
        [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
        cell.supNavigationController = self.navigationController;
        
        return cell;

    }

    YYZCollectShopTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kAttentionCellID];
    
    NSDictionary *shopDict = self.attentionMulArr[indexPath.row];
    
    [cell.avatarImgView sd_setImageWithURL:[NSURL URLWithString:shopDict[@"user_img"]]];
    
    cell.titleLbl.text = shopDict[@"user_name"];
    
    cell.scoreLbl.text = shopDict[@"create_time"];
    
    tableView.separatorColor = SeparatorCOLOR;
    
    cell.collectBtn.tag = [shopDict[@"user_id"] integerValue];
    
    [cell.collectBtn setTitle:@"取消关注" forState:0];
    
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    cell.collectBlock = ^()
    {
        [self requestAttention];
    };

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableMinHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_selectedIndex == 2) {
        //关注
        NSDictionary *shopDict = self.attentionMulArr[indexPath.row];
    
        [self.navigationController pushViewController:[[YYZUserHomeViewController alloc]initWithOtherID:shopDict[@"user_id"]] animated:YES];
    }
    else
    {
        SDTimeLineCellModel *model = self.findMulArr[indexPath.row];
        
        YYZFindDetailViewController *findDetailVC = [[YYZFindDetailViewController alloc]initWithDynamicID:model.dynamic_id];
        
        [self.navigationController pushViewController:findDetailVC animated:YES];
    }
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



#pragma mark -- 删除
-(void)clickDeleteWith:(NSIndexPath *)index{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定删除此动态？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        SDTimeLineCellModel *model = self.findMulArr[index.row];
        
        YYZUser *user = [YYZSave user];
        
        NSString *userID = user.userID ? user.userID : @"";
        
        NSString *timestampstr = [GCService GetimeSp];
        
        NSString *sigstr = [NSString stringWithFormat:@"dynamic_id=%@&timestamp=%@&user_id=%@&nado", userID, timestampstr, model.dynamic_id];
        
        //传入的参数
        NSDictionary *parameters =
        @{
          @"user_id":userID,
          @"dynamic_id": model.dynamic_id,
          @"timestamp":timestampstr,
          @"sig":[GCService  md5:sigstr],
          };
        
        NSString *url=[[NSString stringWithFormat:@"%@DeleteMyDynamic",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
        
        APPDELEGATE.window.userInteractionEnabled = NO;
        
        AFHTTPSessionManager *manager = [GCService sharedManager];
        
        [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
            
            if ([[responseObject objectForKey:@"code"] integerValue] == 0 )
            {
                [self requestData];
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

        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)clickBrowser:(NSIndexPath *)index
{
    YYZUser *user = [YYZSave user];
    
    if (user.userID) {
        
        SDTimeLineCellModel *model = self.findMulArr[index.row];
        
        YYZBrowserTableController *browserVC = [[YYZBrowserTableController alloc]initWithDynamiciID:model.dynamic_id];
        
        [self.navigationController pushViewController:browserVC animated:YES];
    }
    else
    {
        [GCService tipLoginFromController:self];
    }
    
}

- (void)clickProductWithIndexPath:(NSIndexPath *)indexPath productIndex:(NSInteger)index
{
    SDTimeLineCellModel *model = self.findMulArr[indexPath.row];
    
    YYZStoreDetailViewController *storeDetailVC = [[YYZStoreDetailViewController alloc]init];
    
    storeDetailVC.storeID = model.proArray[index][@"product_id"];
    
    [self.navigationController pushViewController:storeDetailVC animated:YES];
}

- (void)clickFoucsReload
{
    [self requestData];
}

#pragma mark - 获取数据
- (void)tableViewPullUp
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        pageNum = 1;
        
        if (_selectedIndex==2) {
            [self requestAttention];
        }
        else
            [self requestData];
    }];
    
    
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        pageNum++;
        
        if (_selectedIndex==2) {
            [self requestAttention];
        }
        else
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
    
    NSInteger typ = self.selectedIndex==0 ? 2 : 1;
    
    NSString *sigstr = [NSString stringWithFormat:@"page=%@&timestamp=%@&type=%@&user_id=%@&nado", @(pageNum), timestampstr, @(typ), @([userID integerValue])];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"type":@(typ),//2生意圈 1我的动态
      @"user_id": @([userID integerValue]),
      @"page":@(pageNum),
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@GetDynamicList",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
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
            
            NSMutableArray *mulArr = [NSMutableArray array];
            
            [dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dict = dataArr[idx];
                SDTimeLineCellModel *model = [SDTimeLineCellModel new];
                model.iconName = dict[@"user_img"];
                model.name = [dict[@"user_name"] isEqualToString:@""] ? @" " : dict[@"user_name"];
                model.msgContent = dict[@"content"];
                model.proArray = dict[@"products"];
                model.is_top = [dict[@"is_top"] boolValue];//是否置顶
                model.comment_sum = [NSString stringWithFormat:@"%@", dict[@"comment_sum"]];
                model.browse = [NSString stringWithFormat:@"%@", dict[@"browse"]];
                model.dynamic_id = dict[@"dynamic_id"];
                model.user_id = dict[@"user_id"];
                model.create_time = [NSString stringWithFormat:@"%@", dict[@"create_time"]];
                model.is_foucs = [dict[@"is_foucs"] boolValue];//是否关注
                model.isDelete = self.selectedIndex==1;
                model.isShowPart = YES;
                
                model.lat = [dict[@"lat"] floatValue];
                model.lng = [dict[@"lng"] floatValue];
                model.address = dict[@"address"];
                
                
                NSMutableArray *tempMulArr = [[NSMutableArray alloc]initWithArray:@[]];
                for (int j = 0; j < [dict[@"images"] count]; j++) {
                    [tempMulArr addObject:dict[@"images"][j][@"link"]];
                }
                
                model.picNamesArray = tempMulArr;
                [mulArr addObject:model];
                
                
            }];
            

            
            if (pageNum == 1) {
                self.findMulArr = mulArr;
            }
            else
            {
                [self.findMulArr insertObjects:mulArr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.findMulArr count], [mulArr count])]];
            }

            
            self.tableView.mj_footer.hidden = [self.findMulArr count] < 10;
            
            [self.tableView reloadData];
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


- (void)requestAttention
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
    
    NSString *url=[[NSString stringWithFormat:@"%@GetMyPersonFocus",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
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
            
            
            if (pageNum == 1) {
                self.attentionMulArr = [[NSMutableArray alloc]initWithArray:dataArr];
            }
            else
            {
                [self.attentionMulArr insertObjects:dataArr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.attentionMulArr count], [dataArr count])]];
            }
            
            
            self.tableView.mj_footer.hidden = [self.attentionMulArr count] < 10;
            
            [self.tableView reloadData];
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
-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellAccessoryNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = TableColor;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        [_tableView registerClass:[YYZCollectShopTableCell class] forCellReuseIdentifier:kAttentionCellID];
        
        [self.view addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.nanbaiView.mas_bottom);
            make.bottom.left.right.mas_equalTo(0);
        }];
    }
    return  _tableView;
}

/**
 * 加载菜单栏
 */
-(UIView *)nanbaiView
{
    if (!_nanbaiView) {
        _nanbaiView = [UIView viewWithBackgroundColor:WhiteColor superView:self.view];
        
        [_nanbaiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(kNavigationH);
            make.height.mas_equalTo(kTopH);
        }];
        
        CGFloat buttonW = ScreenWidth/3;
        
        _divideView = [[UIView alloc]init];
        _divideView.frame = CGRectMake(kMargin, kTopH - 5, buttonW - kMargin*2, 2);
        _divideView.backgroundColor = [UIColor redColor];
        [_nanbaiView addSubview:_divideView];
        
        NSArray * titleArr = @[@"生意圈",@"我的动态",@"我的关注"];
        for (int i = 0; i < 3; i ++) {
            
            UIButton * button = [UIButton buttonWithTitle:titleArr[i] font:kFont14 normalColor:BlackGrayColor selectedColor:ThemeColor buttonTag:(1000 + i) backGroundColor:ClearColor target:self action:@selector(clickSegmentButton:) showView:_nanbaiView];
            button.frame = CGRectMake(buttonW * i, 0, buttonW, kTopH - 0.5);
            
            if(i == 0)
            {
                [button setSelected:YES];
                _selectedIndex = 0;
            }
        }
    }
    return _nanbaiView;
}


@end
