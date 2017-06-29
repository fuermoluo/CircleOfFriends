//
//  YYZUserHomeViewController.m
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/25.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import "YYZUserHomeViewController.h"
#import "YYZFindTableCell.h"
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "SDTimeLineCellModel.h"
#import "YYZFindDetailViewController.h"
#import "YYZCollectShopTableCell.h"
#import "YYZShopViewController.h"
#import "DDVieView.h"

#import "YYZBidDetailViewController.h"
#import "YYZBidUserDetailViewController.h"
#import "YYZBidPlatformDetailViewController.h"
#import "YYZMemberNewTableController.h"
#import "DDPopAlertViewController.h"
#import "PopAnimator.h"

#define kUserBidsCellID @"kUserBidsCellID"
#define kUserFindCellID @"kUserFindCellID"


@interface YYZUserHomeViewController ()<UITableViewDelegate, UITableViewDataSource, SDTimeLineCellModelDelegate>
{
    NSInteger pageNum;
    NSString *_otherID;
    
    NSInteger _selectIndex;//0动态，1需求
    //临时的参数
    NSString *_tempBidID;
}
@property (nonatomic, strong) UIImageView *headImgView;
@property (nonatomic, strong) UIImageView *avatarImgView;
@property (nonatomic, strong) UILabel *nameLbl;
@property (nonatomic, strong) UIButton *shopBtn;
@property (nonatomic, strong) UIButton *attentionBtn;

@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) NSArray *viewsArr;

@property (nonatomic, strong) UITableView *tableView;


@property (nonatomic, strong) PopAnimator *popAnimator;

@property (nonatomic, strong) NSMutableArray *findMulArr;
@property (nonatomic, strong) NSMutableArray *bidsMulArr;

@end

@implementation YYZUserHomeViewController

- (instancetype)initWithOtherID:(NSString *)otherID
{
    if (self = [super init]) {
        
        _otherID = otherID;
        
        _selectIndex = 0;
        
        
        self.popAnimator = [[PopAnimator alloc]init];
        CGFloat height = 4*44;
        CGFloat y = (ScreenHeight-height) / 3.0;
        CGRect coverFrame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        CGRect presentedFrame = CGRectMake(40, y, ScreenWidth-80, height);
        self.popAnimator = [[PopAnimator alloc]initWithCoverFrame:coverFrame presentedFrame:presentedFrame startPoint:CGPointMake(0.5, 0.5) startTransform:CGAffineTransformMakeScale(0.0, 1.0) endTransform:CGAffineTransformMakeScale(0.0001, 1.0)];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = WhiteColor;
    
    [self headImgView];
    [self centerView];
    
    [self tableView];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(clickBack) image:@"white_back" highImage:@"white_back"];
    
    UIButton *contactBtn = [UIButton buttonWithBackgroundImage:@"chat" target:self action:@selector(clickContact) showView:self.view];
    
    [contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(-kMargin);
        make.bottom.mas_equalTo(-kMargin);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        
    }];
    
    
    [self tableViewPullUp];
    
    pageNum = 1;
    
    [self requestHead];
    
    //支付宝通知
    [NZNotificationCenter addObserver:self selector:@selector(zhifubaoPay:) name:kZhiFuBao object:nil];
    
    //微信通知
    [NZNotificationCenter addObserver:self selector:@selector(weiChatSuccess:) name:kWechatSuccess object:nil];
    
    [NZNotificationCenter addObserver:self selector:@selector(weiChatFailure:) name:kWechatFailure object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar lt_reset];
}


#pragma mark - 获取数据

- (void)requestHead
{
    YYZUser*user = [YYZSave user];
    
    NSString *userID = user.userID ? user.userID : @"";
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"customer_id=%@&timestamp=%@&user_id=%@&nado", _otherID, userID, timestampstr];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"user_id":userID,
      @"customer_id":_otherID,//被查看的人的ID
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@MyPage",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
    APPDELEGATE.window.userInteractionEnabled = NO;
    
    AFHTTPSessionManager *manager = [GCService sharedManager];
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 0 )
        {
            NSDictionary *dataDict = responseObject[@"data"];
            
            [self.avatarImgView sd_setImageWithURL:[NSURL URLWithString:dataDict[@"user_img"]]];
            
            if ([dataDict[@"has_shop"] boolValue]) {
                [self shopBtn];
            }
            
            self.attentionBtn.selected = [dataDict[@"collects"] boolValue];
            
            self.nameLbl.text = dataDict[@"user_name"];
            
            
            [self requstData];
        }
        else
        {
            [MBProgressHUD showError:[responseObject objectForKey:@"info"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        
        APPDELEGATE.window.userInteractionEnabled = YES;
        
        [CommonMethod altermethord:TipFailure andmessagestr:TipFailureDetail andconcelstr:@"确定"];
        
        APPDELEGATE.window.userInteractionEnabled = YES;
    }];

}

- (void)tableViewPullUp
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        pageNum = 1;
        
        [self requstData];
    }];
    
    
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        pageNum++;
        [self requstData];
        
    }];
    
    self.tableView.mj_footer.hidden = YES;
}

- (void)requstData
{
    if (_selectIndex) {
        [self requestBids];
    }
    else
        [self requestDynamic];
}

- (void)requestDynamic
{
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"page=%@&timestamp=%@&type=2&user_id=%@&nado", @(pageNum), timestampstr, _otherID];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"type":@(1),//1生意圈 2我的动态
      @"user_id": _otherID,
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
                model.name = dict[@"user_name"];
                model.msgContent = dict[@"content"];
                model.proArray = dict[@"products"];
                model.is_top = [dict[@"is_top"] boolValue];//是否置顶
                model.comment_sum = [NSString stringWithFormat:@"%@", dict[@"comment_sum"]];
                model.browse = [NSString stringWithFormat:@"%@", dict[@"browse"]];
                model.dynamic_id = dict[@"dynamic_id"];
                model.user_id = dict[@"user_id"];
                model.create_time = [NSString stringWithFormat:@"%@", dict[@"create_time"]];
                model.isHiddenFoucs = YES;
                model.isDelete = NO;
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

- (void)requestBids
{
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"page=%@&timestamp=%@&type=1&user_id=%@&nado", @(pageNum), timestampstr, _otherID];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"type":@(1),
      @"user_id": _otherID,
      @"page":@(pageNum),
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@GetMyBidList",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
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
                self.bidsMulArr = [[NSMutableArray alloc]initWithArray:dataArr];
            }
            else
            {
                [self.bidsMulArr insertObjects:dataArr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.bidsMulArr count], [dataArr count])]];
            }
            
            self.tableView.tableFooterView.hidden = [self.bidsMulArr count] < 10;
            
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



#pragma mark - 跳转到不同的招标详情页
- (void)jumpToDetail
{
    //发布人id    如果>0 用户发布 0 有意招平台发布 -1 为第三方发布
    YYZBidUserDetailViewController *bidUserDetailVC = [[YYZBidUserDetailViewController alloc]initWithBidID:_tempBidID];
    
    [self.navigationController pushViewController:bidUserDetailVC animated:YES];

    
}

#pragma mark - 判断查看详情是否需要付费
- (void)judgeWithBidID:(NSString *)bidID
{
    
    _tempBidID = bidID;
    
    YYZUser*user = [YYZSave user];
    
    NSString *userID = @"";
    
    if (user.userID) {
        userID = user.userID;
    }
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"bid_id=%@&timestamp=%@&user_id=%@&nado", bidID, timestampstr, userID];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"bid_id":bidID,
      @"user_id":userID,
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@CheckFreeTimes",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
    
    APPDELEGATE.window.userInteractionEnabled = NO;
    
    AFHTTPSessionManager *manager = [GCService sharedManager];
    
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        
        APPDELEGATE.window.userInteractionEnabled = YES;
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 0 )
        {
            [self jumpToDetail];
        }
        else
        {
            [self alertType];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [CommonMethod altermethord:TipFailure andmessagestr:TipFailureDetail andconcelstr:@"确定"];
        
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        
        APPDELEGATE.window.userInteractionEnabled = YES;
    }];
    
}

- (void)alertType
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"每日免费次数已用完" message:[NSString stringWithFormat:@"%@\n%@", @"查看招标信息需要支付费用1元", @"充值会员可无限次免费查看"] preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"充会员" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        YYZMemberNewTableController *memberNewVC = [[YYZMemberNewTableController alloc]initWithIsShopVip:NO];
        
        [self.navigationController pushViewController:memberNewVC animated:YES];
        
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self payAlert];
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)payAlert
{
    DDPopAlertViewController *popAlertVC = [[DDPopAlertViewController alloc]init];
    
    popAlertVC.transitioningDelegate = self.popAnimator;
    
    popAlertVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:popAlertVC animated:YES completion:nil];
    
    popAlertVC.popAlertBlock = ^(NSInteger tag)
    {
        NSInteger balance = 0;
        if (tag == 0) {
            NZLog(@"余额支付");
            balance = 1;
        }
        else if (tag == 1)
        {
            NZLog(@"微信支付");
        }
        else
        {
            NZLog(@"支付宝支付");
        }
        [self submitOrderWithBalance:balance payTag:tag];
        
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    };
}

- (void)submitOrderWithBalance:(NSInteger)balance payTag:(NSInteger)payTag
{
    YYZUser*user = [YYZSave user];
    
    NSString *timestampstr = [GCService GetimeSp];
    
    BOOL isBalance = balance > 0;
    
    NSString *sigstr = [NSString stringWithFormat:@"bid_id=%@&is_balance=%@&timestamp=%@&type=4&user_id=%@&nado", _tempBidID, @(isBalance), timestampstr, user.userID];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"bid_id":_tempBidID,  //type4查看招标 招标id
      @"is_balance":@(isBalance),//是否使用余额 0不用1使用
      @"type":@(4),// 1月度会员充值订单2 年度会员充值订单3 充值订单4 支付查看招标订单
      @"user_id":user.userID,
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@SubmitRechargeOrder88",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
    
    APPDELEGATE.window.userInteractionEnabled = NO;
    
    AFHTTPSessionManager *manager = [GCService sharedManager];
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        
        APPDELEGATE.window.userInteractionEnabled = YES;
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 0 )
        {
            NZLog(@"---%@", responseObject[@"data"]);
            
            if (payTag == 0) {
                //余额支付
                [self jumpToDetail];
            }
            else
            {
                NSString *unid = responseObject[@"data"][@"unid"];
                
                //GetRechargeRepayId微信，GetRechargeSign支付宝
                NSString *payType = payTag==2 ? @"GetRechargeSign" : @"GetRechargeRepayId";
                
                [self payWithPayMethod:payType orderUnid:unid];
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

#pragma mark - 支付宝
- (void)payWithPayMethod:(NSString *)payMethod orderUnid:(NSString *)orderUnid
{
    YYZUser *user = [YYZSave user];
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"order_unid=%@&timestamp=%@&user_id=%@&nado", orderUnid, timestampstr, user.userID];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"user_id":user.userID,
      @"order_unid":orderUnid,
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@%@",UNiZhaoNewURL, payMethod] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
    
    APPDELEGATE.window.userInteractionEnabled = NO;
    
    AFHTTPSessionManager *manager = [GCService sharedManager];
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        
        APPDELEGATE.window.userInteractionEnabled = YES;
        
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 0 )
        {
            
            if ([payMethod isEqualToString:@"GetRechargeSign"]) {
                //支付宝支付
                [self initTestPayWithPayInfo:responseObject[@"data"]];
            }
            else
            {
                //微信支付
                NSDictionary *wechatDict = responseObject[@"data"];
                
                [self wechatPayWithDict:wechatDict];
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

#pragma mark -  支付宝支付&&回调结果
- (void)zhifubaoPay:(NSNotification *)notification
{
    NSDictionary *resultDic = notification.object;
    
    [self zhifuPayWithDict:resultDic];
    
}

- (void)zhifuPayWithDict:(NSDictionary *)resultDic
{
    NSInteger resultNum = [[resultDic valueForKey:@"resultStatus"] integerValue];
    
    if (resultNum == 9000) {
        //支付成功
        [self jumpToDetail];
    }
    else
    {
        [CommonMethod altermethord:@"充值失败" andmessagestr:@"请稍后再试" andconcelstr:@"确定"];
        
        /*
         switch (resultNum) {
         case 8000:
         [MBProgressHUD showError:@"正在处理中"];
         break;
         case 4000:
         [MBProgressHUD showError:@"订单支付失败"];
         break;
         case 5000:
         [MBProgressHUD showError:@"重复请求"];
         break;
         case 6001:
         [MBProgressHUD showError:@"用户中途取消"];
         break;
         case 6002:
         [MBProgressHUD showError:@"网络连接出错"];
         break;
         case 6004:
         [MBProgressHUD showError:@"支付结果未知"];
         break;
         default:
         break;
         }
         */
        
    }
    
    
}

- (void)initTestPayWithPayInfo:(NSString *)payInfo
{
    NSString *appScheme = @"unizhaoAlipay";
    
    // NOTE: 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:payInfo fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        
        NZLog(@"订单页面－－－调用支付结果开始支付");
        [self zhifuPayWithDict:resultDic];
        
        
    }];
    
}



#pragma mark - 微信支付&&回调成功&失败

- (void)wechatPayWithDict:(NSDictionary *)payDict
{
    PayReq *request = [[PayReq alloc] init];
    
    request.partnerId = payDict[@"partnerid"];
    
    request.prepayId= payDict[@"prepayid"];
    
    request.package = payDict[@"package"];
    
    request.nonceStr= payDict[@"noncestr"];
    
    request.timeStamp= [payDict[@"timestamp"] intValue];
    
    request.sign= payDict[@"sign"];
    
    [WXApi sendReq:request];
}

- (void)weiChatSuccess:(NSNotification *)notification
{
    [self jumpToDetail];
}

- (void)weiChatFailure:(NSNotification *)notification
{
    [CommonMethod altermethord:@"充值失败" andmessagestr:@"请稍后再试" andconcelstr:@"确定"];
}



#pragma mark - tableView delegate && datasource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_selectIndex) {
        //需求
        NSDictionary *tenderDict = self.bidsMulArr[indexPath.section];
        
        [self judgeWithBidID:tenderDict[@"bid_id"]];
    }
    else
    {
        SDTimeLineCellModel *model = self.findMulArr[indexPath.section];
        
        YYZFindDetailViewController *findDetailVC = [[YYZFindDetailViewController alloc]initWithDynamicID:model.dynamic_id];
        
        [self.navigationController pushViewController:findDetailVC animated:YES];
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectIndex) {
        //需求
        YYZCollectTenderTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserBidsCellID];
        
        NSDictionary *tenderDict = self.bidsMulArr[indexPath.section];
        
        cell.timeLbl.text = @"";//tenderDict[@"create_time"];
        
        cell.titleLbl.attributedText = [NSString attributeWithTitle:@"" behindText:[NSString stringWithFormat:@" %@", tenderDict[@"bid_name"]] imageName:@"tender_approve_red"];
        
        cell.contentLbl.text = tenderDict[@"simple_introduction"];
        
        cell.addressLbl.text = tenderDict[@"bid_project_city"];
        
        CGFloat addW = [NSString sizeWithText:cell.addressLbl.text font:cell.addressLbl.font maxSize:CGSizeMake(MAXFLOAT, cell.addressLbl.height)].width + kMargin;
        
        [cell.addressLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.width.mas_equalTo(addW);
            
        }];
        
        cell.typeLbl.text = tenderDict[@"bid_project_type"];
        
        CGFloat typeW = [NSString sizeWithText:cell.typeLbl.text font:cell.typeLbl.font maxSize:CGSizeMake(MAXFLOAT, cell.typeLbl.height)].width + kMargin;
        
        [cell.typeLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.width.mas_equalTo(typeW);
            
        }];
        
        BOOL hasAvatar = YES;//[tenderDict[@"uid"] integerValue] > 0;//发布人id    如果>0 用户发布 0 有意招平台发布 -1 为第三方发布
        
        NSString *name = @"";
        
        cell.supNavigationController = self.navigationController;
        
        cell.avatarImgView.tag = [tenderDict[@"uid"] integerValue];
        
        [cell nameLbl];
        
        CGFloat leftM = kMargin;
        
        if (hasAvatar) {
            [cell.avatarImgView sd_setImageWithURL:[NSURL URLWithString:tenderDict[@"user_img"]]];
            
            name = tenderDict[@"bid_sponsor"];
            
            leftM = kMargin+25+kTableMinHeight;
        }
        else
        {
            
            leftM = kMargin;
            name = [tenderDict[@"uid"] integerValue]==0 ? @"有意招平台" : @"第三方平台";
        }
        
        cell.avatarImgView.hidden = !hasAvatar;
        
        [cell.nameLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(leftM);
        }];
        
        cell.nameLbl.attributedText = [NSString attributedStringWithColorTitle:@"发布" normalTitle:@"" frontTitle:[NSString stringWithFormat:@"%@ ", name] normalColor:BlackNameColor diffentColor:OrangeColor normalFont:kFont15 differentFont:kFont13];
        
        
        cell.collectBtn.hidden = YES;
        
        cell.coutdownLbl.text = [NSString stringWithFormat:@"截止时间：%@", tenderDict[@"bid_bm_edate"]];
        
        
        NSDate *date = [GCService getCurrentTimeWithType:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *endDate = [GCService getDateWithString:[NSString stringWithFormat:@"%@ 23:59:59", tenderDict[@"bid_bm_edate"]] type:@"yyyy-MM-dd HH:mm:ss"];
        NSComparisonResult result = [date compare:endDate];
        //result == NSOrderedAscending时间没过期
        cell.outofImgView.hidden = result == NSOrderedAscending;
        /*
        if (result == NSOrderedAscending) {
            cell.timestamp = [endDate timeIntervalSinceNow];
        }
        else
            cell.timestamp = 0;
        */
        return cell;

    }
    else
    {
        YYZFindTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserFindCellID];
        cell.indexPath = indexPath;
        cell.delegate =self;
        cell.model = self.findMulArr[indexPath.section];
        [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
        
        
        return cell;
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _selectIndex ? [self.bidsMulArr count] : self.findMulArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectIndex) {
        return UITableViewAutomaticDimension;
    }
    else
    {
        // >>>>>>>>>>>>>>>>>>>>> * cell自适应 * >>>>>>>>>>>>>>>>>>>>>>>>
        id model = self.findMulArr[indexPath.section];
        return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[YYZFindTableCell class] contentViewWidth:[self cellContentViewWith]];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectIndex) {
        return UITableViewAutomaticDimension;
    }
    else
    {
        // >>>>>>>>>>>>>>>>>>>>> * cell自适应 * >>>>>>>>>>>>>>>>>>>>>>>>
        id model = self.findMulArr[indexPath.section];
        return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[YYZFindTableCell class] contentViewWidth:[self cellContentViewWith]];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableMinHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
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

#pragma mark - 查看店铺
- (void)clickShop
{
    YYZShopViewController *shopVC = [[YYZShopViewController alloc]initWithShopID:_otherID];
    
    [self.navigationController pushViewController:shopVC animated:YES];
}

#pragma mark - 关注
- (void)clickAttention:(UIButton *)sender
{
    YYZUser*user = [YYZSave user];
    
    if (!user.userID) {
        [GCService tipLoginFromController:self];
        return;
    }
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"post_id=%@&post_table=user&timestamp=%@&user_id=%@&nado", _otherID, timestampstr, user.userID];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"post_id":_otherID,
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

#pragma mark - 聊天
- (void)clickContact
{
    YYZUser *user = [YYZSave user];
    
    if (user.userID) {
        
        if (![[EMClient sharedClient] isLoggedIn])
        {
            EMError *error = [[EMClient sharedClient] loginWithUsername:user.userID password:user.userPass];
            if (!error) {
                NZLog(@"被退出，登录之后聊天");
                [self requestChatWithIds];
            }
        }
        else
        {
            NZLog(@"在线，直接聊天");
            
            [self requestChatWithIds];
        }
    }
    else
    {
        [GCService tipLoginFromController:self];
        
    }
    
}
#pragma mark - 获取客户头像昵称
- (void)requestChatWithIds
{
    YYZUser *user = [YYZSave user];
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"timestamp=%@&user_id=%@&user_ids=%@&nado", timestampstr, user.userID, _otherID];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"user_ids":_otherID,
      @"user_id":user.userID,
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@GetCustomers",UNiZhaoURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
    
    APPDELEGATE.window.userInteractionEnabled = NO;
    
    AFHTTPSessionManager *manager = [GCService sharedManager];
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#warning ...........修改消息聊天页面模型
        
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        
        APPDELEGATE.window.userInteractionEnabled = YES;
        
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 0 )
        {
            NSArray *arr = [responseObject valueForKey:@"data"];
            /**
             {
             "user_id" = 144;
             "user_img" = "http://unizao.com/uploads/user/20160913/smeta_2016091310051100.png";
             "user_nicename" = "\U6709\U610f\U62db\U8d85\U7ea7VIP";
             "user_phone" = 18015562958;
             }
             */
            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:_otherID type:EMConversationTypeChat createIfNotExist:YES];
            
            EaseConversationModel *model = [[EaseConversationModel alloc] initWithConversation:conversation];
            
            model.title = arr[0][@"user_nicename"];
            
            model.avatarURLPath = arr[0][@"user_img"];
            
            NSString *storeChatID = [NSString stringWithFormat:@"%@", _otherID];
            
            ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:storeChatID conversationType:EMConversationTypeChat];
            
            chatController.conversationModel = model;
            
            chatController.title = model.title;
            
            [self.navigationController pushViewController:chatController animated:YES];
            
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


#pragma mark - 返回
- (void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 懒加载

- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        
        _tableView.backgroundColor = TableColor;
        
        _tableView.separatorColor = ClearColor;
        
        _tableView.delegate = self;
        
        _tableView.dataSource = self;
        
        [_tableView registerClass:[YYZCollectTenderTableCell class] forCellReuseIdentifier:kUserBidsCellID];
        [_tableView registerClass:[YYZFindTableCell class] forCellReuseIdentifier:kUserFindCellID];
        
        [CustomViewMehod customViewHiddenExtraCellLine:_tableView];
         
        [self.view addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(self.centerView.mas_bottom);
        }];
    }
    return _tableView;
}


- (UIImageView *)headImgView
{
    if (!_headImgView) {
        
        _headImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_city"]];
        
        _headImgView.userInteractionEnabled = YES;
        
        [self.view addSubview:_headImgView];
        
        [_headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(20);
            make.height.mas_equalTo(KActualH(240));
        }];
        
        [self avatarImgView];
        [self attentionBtn];
        [self nameLbl];
        
        YYZUser *user = [YYZSave user];
        if ([user.userID isEqual:_otherID]) {
            self.attentionBtn.hidden = YES;
        }
    }
    return _headImgView;
}

- (UIImageView *)avatarImgView
{
    if (!_avatarImgView) {
        
        _avatarImgView = [[UIImageView alloc]init];
        
        [self.headImgView addSubview:_avatarImgView];
        
        [_avatarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(kMargin);
            make.bottom.mas_equalTo(-kMargin);
            make.size.mas_equalTo(CGSizeMake(KActualH(100), KActualH(100)));
        }];

        _avatarImgView.layer.cornerRadius = 8;
        _avatarImgView.clipsToBounds = YES;
    }
    return _avatarImgView;
}

- (UIButton *)attentionBtn
{
    if (!_attentionBtn) {
        
        _attentionBtn = [UIButton buttonWithTitle:@"关注" font:kFont12 normalColor:ThemeColor selectedColor:ThemeColor buttonTag:0 backGroundColor:WhiteColor target:self action:@selector(clickAttention:) showView:self.headImgView];
        
        [_attentionBtn setTitle:@"已关注" forState:UIControlStateSelected];
        
        _attentionBtn.layer.masksToBounds = YES;
        _attentionBtn.layer.cornerRadius = 13;
        
        [_attentionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(-kMargin);
            make.size.mas_equalTo(CGSizeMake(55, 26));
        }];
        
    }
    return _attentionBtn;
}

- (UILabel *)nameLbl
{
    if (!_nameLbl) {
        
        _nameLbl = [UILabel labelWithText:@"" font:kFont14 textColor:WhiteColor backGroundColor:ClearColor superView:self.headImgView];
        
        [_nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.avatarImgView.mas_top);
            make.left.mas_equalTo(self.avatarImgView.mas_right).mas_equalTo(8);
            make.height.mas_equalTo(self.avatarImgView.mas_height);
            //make.right.mas_equalTo(self.qrcodeImgView.mas_left).mas_equalTo(-8);
        }];

        
    }
    return _nameLbl;
}

- (UIButton *)shopBtn
{
    if (!_shopBtn) {
        
        _shopBtn = [UIButton buttonWithTitle:@"查看TA的店铺" font:kFont14 titleColor:WhiteColor backGroundColor:ClearColor buttonTag:0 target:self action:@selector(clickShop) showView:self.headImgView];
        
        _shopBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [self.nameLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.avatarImgView.mas_top);
            make.left.mas_equalTo(self.avatarImgView.mas_right).mas_equalTo(8);
            //make.right.mas_equalTo(self.qrcodeImgView.mas_left).mas_equalTo(-8);
        }];

        
        [_shopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLbl.mas_left);
            make.bottom.mas_equalTo(self.avatarImgView.mas_bottom);
        }];
        
    }
    return _shopBtn;
}

- (UIView *)centerView
{
    if (!_centerView) {
        
        _centerView = [UIView viewWithBackgroundColor:WhiteColor superView:self.view];
        
        [_centerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(self.headImgView.mas_bottom);
            make.height.mas_equalTo(kTopH);
        }];
        
        
        CGFloat width = ScreenWidth / 2.0;
        
        NSArray *titleArr = @[@"动态", @"需求"];
        
        NSMutableArray *mulArr = [NSMutableArray array];
        
        for (int i = 0; i < [titleArr count]; i++) {
            
            BOOL isRead = YES;
            
            BOOL isSelect = i==0;
            
            DDVieView *view = [[DDVieView alloc]initWithTitle:titleArr[i] titleFont:kFont14 lineColor:ThemeColor titleColor:RGBCOLOR(120, 120, 120) selectColor:ThemeColor showView:_centerView frame:CGRectMake(width*i, 0, width, kTopH) index:i statusRead:isRead statusSelect:isSelect vieDelegate:self];
            
            [mulArr addObject:view];
        }
        
        self.viewsArr = mulArr;
    
    }
    return _centerView;
}


#pragma mark - 顶部的点击事件 代理

- (void)vieViewTap:(NSInteger)index
{
    for (DDVieView *view in self.viewsArr) {
        
        [UIView animateWithDuration:kShowDisTime animations:^{
            view.isSelect = view.tag==index;
        }];
        
    }
    pageNum = 1;
    
    _selectIndex = index;
    
    [self requstData];
}


@end
