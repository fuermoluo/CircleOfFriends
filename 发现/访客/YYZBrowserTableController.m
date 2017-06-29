//
//  YYZBrowserTableController.m
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/19.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import "YYZBrowserTableController.h"
#import "YYZBrowserTableCell.h"

#define kBrowserCellID @"BrowserCellID"

@interface YYZBrowserTableController ()
{
    NSString *_dynamic_id;
}
@property (nonatomic, strong) NSArray *browserArr;

@end

@implementation YYZBrowserTableController

- (instancetype)initWithDynamiciID:(NSString *)dynamic_id
{
    if (self = [super init]) {
        _dynamic_id = dynamic_id;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.navigationItem.title = @"最近访客";
    
    self.tableView.backgroundColor = WhiteColor;
    
    [self.tableView registerClass:[YYZBrowserTableCell class] forCellReuseIdentifier:kBrowserCellID];
    
    self.tableView.allowsSelection = NO;
    
    self.tableView.tableFooterView = [UIView new];
    
    [self requestData];
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YYZBrowserTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kBrowserCellID];
    
    NSDictionary *cellDict = self.browserArr[indexPath.row];
    
    [cell.avatarImgView sd_setImageWithURL:[NSURL URLWithString:cellDict[@"user_img"]]];
    
    cell.nameLbl.text = cellDict[@"user_name"];
    
    cell.timeLbl.text = cellDict[@"create_time"];
    
    cell.avatarImgView.tag = [cellDict[@"user_id"] integerValue];
    
    cell.supNavigationController = self.navigationController;
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.browserArr count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}


#pragma mark - 获取数据
- (void)requestData
{
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"dynamic_id=%@&timestamp=%@&nado", timestampstr, _dynamic_id];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"dynamic_id": _dynamic_id,
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@GetRecentGuest",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
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
            self.browserArr = [responseObject valueForKey:@"data"];
            
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


@end
