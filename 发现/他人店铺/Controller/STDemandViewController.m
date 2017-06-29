//
//  STDemandViewController.m
//  unizaoMerchant
//
//  Created by 班文政 on 2017/5/9.
//  Copyright © 2017年 NADOLily. All rights reserved.
//

#import "STDemandViewController.h"
#import "STTenderTableViewCell.h"
#import "STMyBidListM.h"
@interface STDemandViewController ()<UITableViewDelegate,UITableViewDataSource,STTenderTableViewCellDelegate>
{
    NSInteger _indexTag;
    NSInteger _page;
}

@property (nonatomic, strong) UITableView *tableView;

/**我发布的需求列表数据*/
@property (nonatomic, strong) NSMutableArray <STMyBidListM *> *myNeedArr;

@end

@implementation STDemandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    
    
    self.view.backgroundColor = RGBCOLOR(230, 230, 230);
    self.tableView.backgroundColor = RGBCOLOR(230, 230, 230);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _indexTag = 0;
    
    [self setupRefresh];
}

- (void)setupRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewInfo)];
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreInfo)];
    self.tableView.mj_footer.hidden = YES;
}

- (void)loadNewInfo
{
    _page = 1;
    [self requestGetMyBidListData];
}

- (void)loadMoreInfo
{
    ++ _page;
    [self requestGetMyBidListData];
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.myNeedArr.count < _page * 10) {
        
        self.tableView.mj_footer.hidden = YES;
    }else{
        
        self.tableView.mj_footer.hidden = NO;
    }
    
    return self.myNeedArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID =@"affordCell";
    
    STTenderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[STTenderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }else{
        [cell removeFromSuperview];
        cell = [[STTenderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.delegate = self;
    if ([self.myNeedArr[indexPath.section].checked integerValue] == 1) {
        cell.imgView.image = [UIImage imageNamed:@"excuse"];
    }
    else{
        [cell.titleLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
        }];
    }
    
    cell.titleLbl.text = self.myNeedArr[indexPath.section].bid_name;//@"青岛金科星辰项目招标公告";
    
    cell.tagArr = @[self.myNeedArr[indexPath.section].bid_project_city,self.myNeedArr[indexPath.section].bid_project_type];
    
    cell.descLbl.text = self.myNeedArr[indexPath.section].simple_introduction;//@"1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告";
    
    [cell.avarImgView sd_setImageWithURL:[NSURL URLWithString:self.myNeedArr[indexPath.section].user_img]];
    
    
    cell.niceLbl.attributedText = [NSString attributedStringWithColorTitle:[NSString stringWithFormat:@"%@ ",self.myNeedArr[indexPath.section].bid_sponsor] normalTitle:@"发布" frontTitle:@"" diffentColor:[UIColor blackColor]];
    
    cell.pushStr = @"个人发布";
    cell.interval = [self.myNeedArr[indexPath.section].bid_bm_edate integerValue];
    
    cell.pushTimeLbl.text = self.myNeedArr[indexPath.section].create_time;
//    if (indexPath.section == 1) {
//        
//        cell.delegate = self;
//        cell.titleLbl.text = @"青岛金科星辰项目招标公告";
//        
//        cell.tagArr = @[@"苏州",@"建筑工程"];
//        
//        cell.descLbl.text = @"1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告";
//        
//        [cell.avarImgView sd_setImageWithURL:[NSURL URLWithString:@"https://store.storeimages.cdn-apple.com/8749/as-images.apple.com/is/image/AppleInc/aos/published/images/i/ph/iphone7/select/iphone7-select-2016_GEO_CN?wid=211&hei=305&fmt=png-alpha&qlt=95&.v=1472146439173"]];
//        
//        
//        cell.niceLbl.attributedText = [NSString attributedStringWithColorTitle:@"jack " normalTitle:@"发布" frontTitle:@"" diffentColor:RGBCOLOR(43,165,242)];
//        
//        cell.pushStr = @"个人发布";
//        cell.interval = -10;
//        
//    }else{
//        
//        
//        cell.titleLbl.text = @"青岛金科星辰项目招标公告";
//        
//        cell.tagArr = @[@"苏州",@"建筑工程"];
//        
//        cell.descLbl.text = @"1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告1111111青岛金科星辰项目招标公告";
//        
//        //        [cell.avarImgView sd_setImageWithURL:[NSURL URLWithString:@"https://store.storeimages.cdn-apple.com/8749/as-images.apple.com/is/image/AppleInc/aos/published/images/i/ph/iphone7/select/iphone7-select-2016_GEO_CN?wid=211&hei=305&fmt=png-alpha&qlt=95&.v=1472146439173"]];
//        //
//        
//        if (indexPath.section == 0) {
//            
//            cell.platformLbl.attributedText = [NSString attributedStringWithColorTitle:@"第三方平台 " normalTitle:@"发布" frontTitle:@"" diffentColor:RGBCOLOR(43,165,242)];
//        }else
//        {
//            
//            cell.platformLbl.attributedText = [NSString attributedStringWithColorTitle:@"有意招平台 " normalTitle:@"发布" frontTitle:@"" diffentColor:RGBCOLOR(43,165,242)];
//        }
//        
//        cell.pushStr = @"平台发布";
//        
//        cell.interval = 1500;
//        
//        cell.pushTimeLbl.text = @"2017-5-9";
//    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView viewWithBackgroundColor:RGBCOLOR(230, 230, 230) superView:nil];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

#pragma mark - STTenderTableViewCellDelegate
- (void)tenderTableViewCellDidClickPerson:(NSInteger)tag
{
  
    
}

#pragma mark - 请求数据 - 获取我发布的需求
- (void)requestGetMyBidListData
{
    YYZUser *user = [YYZSave user];
    
    NSString *userID = @"";
    
    if (user.userID) {
        userID = user.userID;
    }
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"page=%@&timestamp=%@&user_id=%@&nado", [NSString stringWithFormat:@"%ld",(long)_page],timestampstr, self.user_id];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"user_id": self.user_id,
      @"page":[NSString stringWithFormat:@"%ld",(long)_page],
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@GetMyBidList",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    
    
    AFHTTPSessionManager *manager = [GCService sharedManager];
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 0) {
            
            
            if (_page > 1) {
                
                // 字典数组 -> 模型数组
                NSArray<STMyBidListM *> *arr = [STMyBidListM mj_objectArrayWithKeyValuesArray:[responseObject valueForKey:@"data"]];
                
                [self.myNeedArr addObjectsFromArray:arr];
                
            }else{
                
                self.myNeedArr = [STMyBidListM mj_objectArrayWithKeyValuesArray:[responseObject valueForKey:@"data"]];
            }
            
            [self.tableView reloadData];
            
        }else{
            
            
            [MBProgressHUD showError:[responseObject objectForKey:@"info"]];
        }

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        [MBProgressHUD showError:@"未连接到服务器，请检查网络连接后重试"];
    }];

}


#pragma mark - 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.mas_equalTo(0);
            
        }];
        
    }return _tableView;
}

@end
