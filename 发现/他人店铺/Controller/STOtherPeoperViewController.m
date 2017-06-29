//
//  STOtherPeoperViewController.m
//  unizaoMerchant
//
//  Created by 班文政 on 2017/5/8.
//  Copyright © 2017年 NADOLily. All rights reserved.
//

#import "STOtherPeoperViewController.h"
#import "STOtherPeopleView.h"
#import "STDynamicViewController.h"
#import "STDemandViewController.h"
#import "YYZShopViewController.h"

@interface STOtherPeoperViewController ()

/**动态&需求*/
@property (nonatomic, strong) UIView *topBtnView;

@property (nonatomic, strong) STOtherPeopleView *topView;


/**
 动态
 */
@property (nonatomic, strong) UIButton *dynamicBtn;


/**
 需求
 */
@property (nonatomic, strong) UIButton *demandBtn;


/**
 红色指示线条
 */
@property (nonatomic, strong) UIView *redLineView;


/**
 记录选择的按钮
 */
@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic,strong) UIButton *connectionBtn;

@property (nonatomic,strong) NSDictionary *userInfo;

@end

@implementation STOtherPeoperViewController
{
    NSString *_user_id;
}
- (instancetype)initWithUser_id:(NSString *)user_id{
    if (self = [super init]) {
        _user_id = user_id;
         [self getmyShopHeadWithCustomer_id:_user_id];
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupChildViewControllers];
    
    [self addChildVcView];
    
    
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    //状态栏
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
     [self createConnectionBtn];
    
    [self loadUI];
    
   
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    [self.connectionBtn removeFromSuperview];
    //状态栏
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}


- (void)loadUI
{
    [self.dynamicBtn addTarget:self action:@selector(dynamicBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.demandBtn addTarget:self action:@selector(demandBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.dynamicBtn.selected = YES;
    
    self.selectBtn = self.dynamicBtn;
    
    [self redLineView];
    
}


- (void)setupChildViewControllers
{
    STDynamicViewController *dynamic = [[STDynamicViewController alloc] init];
    dynamic.user_id = _user_id;
    [self addChildViewController:dynamic];
    
    STDemandViewController *demand = [[STDemandViewController alloc] init];
    demand.user_id = _user_id;
    [self addChildViewController:demand];

}

#pragma mark - 添加子控制器的view
- (void)addChildVcView
{
    // 取出子控制器
    UIViewController *childVc = self.childViewControllers[0];
//        if ([childVc isViewLoaded]) return;
    
    [self.view addSubview:childVc.view];
    
    [childVc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.topBtnView.mas_bottom);
        make.left.right.bottom.mas_equalTo(0);
        
    }];
}

#pragma mark - 返回
- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 关注
- (void)attentBtnClick:(UIButton *)button
{
    NZLog(@"关注");
    
    YYZUser *user = [YYZSave user];
    
    NSString *userID = @"";
    
    if (user.userID) {
        userID = user.userID;
    }
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"post_id=%@&timestamp=%@&user_id=%@&nado", _user_id,timestampstr, @([userID integerValue])];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"user_id": @([userID integerValue]),
      @"post_id":_user_id,
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@Focus",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
    
    
    
    AFHTTPSessionManager *manager = [GCService sharedManager];
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        if ([responseObject[@"code"] integerValue] == 0) {
            button.selected = !button.selected;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

    
}

#pragma mark - 查看他人店铺
- (void)lookOtherShopBtnClick
{
    YYZShopViewController *shopVC = [[YYZShopViewController alloc]initWithShopID:_user_id];
    
    [self.navigationController pushViewController:shopVC animated:YES];
}

#pragma mark - 动态
- (void)dynamicBtnClick
{
    self.dynamicBtn.selected = YES;
    self.demandBtn.selected = NO;
    
    [self.redLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(ScreenWidth*0.25 - 14);
    }];
    
    
    // 取出子控制器
    UIViewController *childVc = self.childViewControllers[0];
//    if ([childVc isViewLoaded]) return;
    
    [self.view addSubview:childVc.view];
    
    [childVc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.topBtnView.mas_bottom);
        make.left.right.bottom.mas_equalTo(0);
        
    }];
}

#pragma mark - 需求
- (void)demandBtnClick
{
    self.demandBtn.selected = YES;
    self.dynamicBtn.selected = NO;
    
    [self.redLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(ScreenWidth*0.75 - 14);
    }];
    
    
    // 取出子控制器
    UIViewController *childVc = self.childViewControllers[1];
//    if ([childVc isViewLoaded]) return;
    
    [self.view addSubview:childVc.view];
    
    [childVc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.topBtnView.mas_bottom);
        make.left.right.bottom.mas_equalTo(0);
        
    }];

}

#pragma mark - 懒加载
- (STOtherPeopleView *)topView
{
    if (!_topView) {
        
        _topView = [[STOtherPeopleView alloc] init];
        
        [_topView.backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_topView];
        
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.right.left.mas_equalTo(0);
            make.height.mas_equalTo(130);
        }];
        
        
        
        [_topView.attentBtn addTarget:self action:@selector(attentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_topView.lookOtherShopBtn addTarget:self action:@selector(lookOtherShopBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _topView;
}


- (UIView *)topBtnView
{
    if (!_topBtnView) {
        
        _topBtnView = [UIView viewWithBackgroundColor:[UIColor whiteColor] superView:self.view];
        
        [_topBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.height.mas_equalTo(31);
            
            make.top.mas_equalTo(self.topView.mas_bottom);
            
            make.left.right.mas_equalTo(0);
        }];
        
        
        UIView *lineView = [UIView viewWithBackgroundColor:RGBCOLOR(231, 231, 231) superView:_topBtnView];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerX.mas_equalTo(0);
            
            make.height.mas_equalTo(15);
            
            make.centerY.mas_equalTo(0);
            
            make.width.mas_equalTo(1);
        }];
    }
    
    return _topBtnView;
}


- (UIButton *)dynamicBtn
{
    
    if (!_dynamicBtn) {
        
        _dynamicBtn = [[UIButton alloc] init];
        
        _dynamicBtn.titleLabel.font = kFont(14);
        
        [_dynamicBtn setTitle:@"动态" forState:UIControlStateNormal];
        
        [_dynamicBtn setTitleColor:ThemeColor forState:UIControlStateSelected];
        
        [_dynamicBtn setTitleColor:RGBCOLOR(110, 110, 110) forState:UIControlStateNormal];
        
        [self.topBtnView addSubview:_dynamicBtn];
        
        [_dynamicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.bottom.left.mas_equalTo(0);
            
            make.width.mas_equalTo(ScreenWidth*0.5 - 0.5);
            
        }];
    }
    
    return _dynamicBtn;
}


- (UIButton *)demandBtn
{
    if (!_demandBtn) {
        
        _demandBtn = [[UIButton alloc] init];
        
        _demandBtn.titleLabel.font = kFont(14);
        
        [_demandBtn setTitle:@"需求" forState:UIControlStateNormal];
        
        [_demandBtn setTitleColor:ThemeColor forState:UIControlStateSelected];
        
        [_demandBtn setTitleColor:RGBCOLOR(110, 110, 110) forState:UIControlStateNormal];
        
        [self.topBtnView addSubview:_demandBtn];
        
        [_demandBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.right.bottom.mas_equalTo(0);
            
            make.width.mas_equalTo(ScreenWidth*0.5 - 0.5);
        }];
        
    }
    
    return _demandBtn;
}

- (UIView *)redLineView
{
    if (!_redLineView) {
        
        _redLineView = [UIView viewWithBackgroundColor:ThemeColor superView:self.topBtnView];
        
        [_redLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.mas_equalTo(-1.5);
            make.height.mas_equalTo(1.5);
            make.width.mas_equalTo(28);
            make.left.mas_equalTo(ScreenWidth*0.25 - 14);
            
        }];
    }
    return _redLineView;
}
- (void)createConnectionBtn{
    self.connectionBtn = [UIButton new];
    [APPDELEGATE.window addSubview:self.connectionBtn];
    [self.connectionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-80);
        make.size.mas_equalTo(CGSizeMake(65, 65));
    }];
    [self.connectionBtn setBackgroundImage:[UIImage imageNamed:@"chat"] forState:0];
    [self.connectionBtn addTarget:self action:@selector(didConnectionBtn) forControlEvents:UIControlEventTouchUpInside];
}
- (void)didConnectionBtn{
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
    
    NSString *sigstr = [NSString stringWithFormat:@"timestamp=%@&user_id=%@&user_ids=%@&nado", timestampstr, user.userID, _user_id];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"user_ids":_user_id,
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
            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:_user_id type:EMConversationTypeChat createIfNotExist:YES];
            
            EaseConversationModel *model = [[EaseConversationModel alloc] initWithConversation:conversation];
            
            model.title = arr[0][@"user_nicename"];
            
            model.avatarURLPath = arr[0][@"user_img"];
            
            NSString *storeChatID = [NSString stringWithFormat:@"%@", _user_id];
            
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

- (void)getmyShopHeadWithCustomer_id:(NSString *)customer_id{
    YYZUser *user = [YYZSave user];
    
    NSString *userID = @"";
    
    if (user.userID) {
        userID = user.userID;
    }
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *sigstr = [NSString stringWithFormat:@"customer_id=%@&timestamp=%@&user_id=%@&nado", customer_id,timestampstr, @([userID integerValue])];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"user_id": @([userID integerValue]),
      @"customer_id":customer_id,
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@MyPage",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [MBProgressHUD showMessage:Tip toView:APPDELEGATE.window];
    

    
    AFHTTPSessionManager *manager = [GCService sharedManager];
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideAllHUDsForView:APPDELEGATE.window animated:YES];
        if ([responseObject[@"code"] integerValue] == 0) {
            self.userInfo = responseObject[@"data"];
            [self.topView.avarImgView sd_setImageWithURL:[NSURL URLWithString:self.userInfo[@"user_img"]]];
            self.topView.niceLbl.text = self.userInfo[@"user_name"];
            self.topView.lookOtherShopBtn.hidden = [self.userInfo[@"has_shop"] integerValue];
            self.topView.attentBtn.selected = [self.userInfo[@"collects"] integerValue];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}
@end
