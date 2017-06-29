//
//  STDynamicViewController.m
//  unizaoMerchant
//
//  Created by 班文政 on 2017/5/9.
//  Copyright © 2017年 NADOLily. All rights reserved.
//

#import "STDynamicViewController.h"
#import "STDynamicTableViewCell.h"
#import "YYZFindDetailViewController.h"

#import "STDynProducts.h"
#import "STDynImages.h"
#import "STDynamicM.h"

@interface STDynamicViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

/**数据*/
@property (nonatomic, strong) NSMutableArray <STDynamicM *> *dynamicArr;

@end

@implementation STDynamicViewController
{
    
    NSInteger _page;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBCOLOR(230, 230, 230);
    
    self.tableView.backgroundColor = RGBCOLOR(230, 230, 230);

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupRefresh];
}

- (void)setupRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewInfo)];
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreInfo)];

}

- (void)loadNewInfo
{
    _page = 1;
    [self requestGetDynamicListData];
}

- (void)loadMoreInfo
{
    ++ _page;
    [self requestGetDynamicListData];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.dynamicArr.count < _page * 10) {
        
        self.tableView.mj_footer.hidden = YES;
    }else{
        
        self.tableView.mj_footer.hidden = NO;
    }
    
    return self.dynamicArr.count;

}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID =@"STDynamicTableViewCell";
    
    STDynamicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[STDynamicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }else{
        [cell removeFromSuperview];
        cell = [[STDynamicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [cell.avarImgView sd_setImageWithURL:[NSURL URLWithString:self.dynamicArr[indexPath.section].user_img]];
    
    
    cell.niceLbl.text = self.dynamicArr[indexPath.section].user_name;
    
    cell.titleLbl.text = self.dynamicArr[indexPath.section].content;
    
    
    cell.pictureArr = [self.dynamicArr[indexPath.section].images valueForKey:@"link"];
    
        cell.timeLbl.text = @"2017-05-09 16:32";
        
        cell.goodsArr = self.dynamicArr[indexPath.section].products;
        
         [cell.commentBtn setTitle:[NSString stringWithFormat:@" %@",self.dynamicArr[indexPath.section].comment_sum] forState:UIControlStateNormal];
        
        [cell.browsebtn setTitle:[NSString stringWithFormat:@" %@",self.dynamicArr[indexPath.section].browse] forState:UIControlStateNormal];
    
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YYZFindDetailViewController *findDetailVC = [[YYZFindDetailViewController alloc]initWithDynamicID:self.dynamicArr[indexPath.section].dynamic_id];
    
    [self.navigationController pushViewController:findDetailVC animated:YES];
}
#pragma mark - 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.contentInset = UIEdgeInsetsMake(-15, 0, 0, 0);
        [self.view addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(1);
        }];
    }
    
    return _tableView;
}
#pragma mark - 请求数据 - 获取动态列表
- (void)requestGetDynamicListData
{
    YYZUser *user = [YYZSave user];
    
    NSString *userID = @"";
    
    if (user.userID) {
        userID = user.userID;
    }
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"page=%@&timestamp=%@&type=%@&user_id=%@&nado", [NSString stringWithFormat:@"%ld",(long)_page],timestampstr, @"1",self.user_id];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"user_id": self.user_id,
      @"page":[NSString stringWithFormat:@"%ld",(long)_page],
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@GetDynamicList",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
    
   
    
    AFHTTPSessionManager *manager = [GCService sharedManager];

    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        if ([[responseObject objectForKey:@"code"] integerValue] == 0) {
            
            if (_page > 1) {
                
                // 字典数组 -> 模型数组
                NSArray<STDynamicM *> *arr = [STDynamicM mj_objectArrayWithKeyValuesArray:[responseObject valueForKey:@"data"]];
                
                [self.dynamicArr addObjectsFromArray:arr];
                
            }else{
                
                self.dynamicArr = [STDynamicM mj_objectArrayWithKeyValuesArray:[responseObject valueForKey:@"data"]];
            }
            
            [self.tableView reloadData];
            
        }else{
            
            [MBProgressHUD showError:[responseObject objectForKey:@"info"]];
        }


    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        [MBProgressHUD showError:@"未连接到服务器，请检查网络连接后重试"];
    }];
//    NSDictionary *parameters = [[STOtherShopManager sharedInstance] getDynamicListWithUser_id:self.user_id page:[NSString stringWithFormat:@"%ld",(long)_page] type:@"1"];
//    
//    [[ServiceClient sharedClient] POST:GetNewPostUrl(GetDynamicList) parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        
//        [self.tableView.mj_footer endRefreshing];
//        [self.tableView.mj_header endRefreshing];
//        
//        if ([[responseObject objectForKey:@"code"] integerValue] == 0) {
//            
//            if (_page > 1) {
//                
//                // 字典数组 -> 模型数组
//                NSArray<STDynamicM *> *arr = [STDynamicM mj_objectArrayWithKeyValuesArray:[responseObject valueForKey:@"data"]];
//                
//                [self.dynamicArr addObjectsFromArray:arr];
//                
//            }else{
//                
//                self.dynamicArr = [STDynamicM mj_objectArrayWithKeyValuesArray:[responseObject valueForKey:@"data"]];
//            }
//            
//            [self.tableView reloadData];
//            
//        }else{
//            
//            [self showWithParent:self.view text:[responseObject objectForKey:@"info"]];
//        }
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//        [self.tableView.mj_footer endRefreshing];
//        [self.tableView.mj_header endRefreshing];
//        
//        [self altermethord:@"提示" andmessagestr:@"未连接到服务器，请检查网络连接后重试" andconcelstr:@"确定"];
//    }];
}

@end
