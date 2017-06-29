//
//  YYZPublishFindViewController.m
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/19.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import "YYZPublishFindViewController.h"
#import "NDAddPictureCollectionView.h"
#import "NDTextView.h"
#import "YYZRelateProductTableCell.h"
#import "YYZRelateProductViewController.h"

#define kSelectProductID @"SelectProductCellID"

@interface YYZPublishFindViewController ()<UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>
{
    NSString *_textViewText;
    NSMutableArray *_imgArr;
    
    BOOL _isShowAddress;//默认不显示
    BOOL _isAllowLocation;//是否允许定位
    
    CLLocationCoordinate2D _coordinate;
    
}
@property (nonatomic,strong) UIView *bgView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UITableView *tableView;


@property (nonatomic, strong) NSArray *productArr;

@property (nonatomic, strong) YYZRelateProductViewController *relateProductVC;

//定位获取的信息
@property (nonatomic, strong) CLPlacemark *placemark;

//如果不设置为属性，软件开启时提示定位的提示出现一瞬间就消失了
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation YYZPublishFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"发布生意圈";
    
    self.view.backgroundColor = WhiteColor;
    
    self.navigationItem.leftBarButtonItems = [UIBarButtonItem itemWithTarget:self action:@selector(clickCancle) leftImage:nil selectImage:nil title:@"取消" titleColor:BlackColor isRightItem:NO titleFont:kFont15 createdButton:nil];
    
    self.navigationItem.rightBarButtonItems = [UIBarButtonItem itemWithTarget:self action:@selector(clickFinish) leftImage:nil selectImage:nil title:@"发布" titleColor:BlackColor isRightItem:YES titleFont:kFont15 createdButton:^(CustomButton *button) {
        [button setTitleColor:ThemeColor forState:0];
    }];

    /////////定位////////
    
    [self locationManager];
    
    
    self.relateProductVC = [[YYZRelateProductViewController alloc]init];
    
    _textViewText = @"";
    
    _imgArr = [[NSMutableArray alloc]initWithArray:@[]];
    
    [self bgView];
}


#pragma mark - 地图定位
- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        
        // 判断定位操作是否被允许
        if([CLLocationManager locationServicesEnabled]) {
            
            self.locationManager = [[CLLocationManager alloc] init];
            
            self.locationManager.delegate = self;
            
            //控制定位精度,越高耗电量越
            self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            
            [self.locationManager requestAlwaysAuthorization];
            self.locationManager.distanceFilter = 10.0f;
            // 开始定位
            [self.locationManager startUpdatingLocation];
            
        }else {
            //提示用户无法进行定位操作
        }
        
    }
    return _locationManager;
}

#pragma mark - 定位
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *newLocation = locations[0];
    
    _coordinate = newLocation.coordinate;
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error){
        if (array.count > 0){
            
            _isAllowLocation = YES;
            
            self.placemark = [array objectAtIndex:0];
        }
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"定位－－－No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"定位－－－An error occurred = %@", error);
        }
    }];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
    
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
    _isAllowLocation = NO;
    NSLog(@"定位出错");
    if ([error code] == kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}


#pragma mark - 取消
- (void)clickCancle
{
    if ([_textViewText isEqualToString:@""] && [_imgArr count]==0 && [self.productArr count]==0) {
        [self.navigationController popViewControllerAnimated:YES];
        
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"退出此次编辑？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 关联产品
- (void)clickAddProduct
{
    
    YYZUser *user = [YYZSave user];
    
    if (![user.userVipInfo[@"is_vip"] boolValue]) {
        //不是商城会员
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@\n%@", @"您还不是认证商家", @"请前往商户版申请认证"] message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString  *str = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id1160646386"];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [self.navigationController pushViewController:self.relateProductVC animated:YES];
        
        __weak typeof(self) weakSelf = self;
        self.relateProductVC.relateBlock = ^(NSArray *relateArr)
        {
            weakSelf.productArr = relateArr;
            
            [weakSelf.tableView reloadData];
        };
    }
}

#pragma mark - 发布
- (void)clickFinish
{
    YYZUser *user = [YYZSave user];
    
    NSString *userID = user.userID;
    
    
    if ([[_textViewText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [CommonMethod altermethord:TipFinish andmessagestr:@"" andconcelstr:@"确定"];
        return;
    }
    
    for (int i = 0; i < _imgArr.count; i++) {
        
        if ([_imgArr[i] isKindOfClass:[UIImage class]]) {
            UIImage *img = _imgArr[i];
            
            NSData *_data = UIImageJPEGRepresentation(img, 1.0f);
            
            NSString *_encodedImageStr = [_data base64EncodedStringWithOptions:0];
            
            [_imgArr replaceObjectAtIndex:i withObject:_encodedImageStr];
        }
        
    }
    NSString *imgStr = _imgArr.count>0 ? [_imgArr componentsJoinedByString:@","] : @"";
    
    NSMutableString *productMulID = [[NSMutableString alloc]initWithString:@""];
    
    for (int i = 0; i < [self.productArr count]; i++) {
        if (i==0) {
            [productMulID appendString:self.productArr[i][@"product_id"]];
        }
        else
            [productMulID appendFormat:@",%@", self.productArr[i][@"product_id"]];
    }
    
    NSString *timestampstr = [GCService GetimeSp];
    
    NSString *lat = _isAllowLocation ? [NSString stringWithFormat:@"%f", _coordinate.latitude] : @"";
    NSString *lng = _isAllowLocation ? [NSString stringWithFormat:@"%f", _coordinate.longitude] : @"";
    
    NSString *thoroughfare = self.placemark.thoroughfare;
    if ([thoroughfare isEqualToString:@"(null)"] || !thoroughfare) {
        thoroughfare = @"";
    }
    
    NSString *subThoroughfare = self.placemark.subThoroughfare;
    if ([subThoroughfare isEqualToString:@"(null)"] || !subThoroughfare) {
        subThoroughfare = @"";
    }
    
    NSString *address = _isAllowLocation ? [NSString stringWithFormat:@"%@%@%@%@", self.placemark.locality, self.placemark.subLocality, thoroughfare, subThoroughfare] : @"";
    
    NSString *sigstr = [NSString stringWithFormat:@"address=%@&content=%@&images=%@&lat=%@&lng=%@&product_id=%@&timestamp=%@&user_id=%@&nado", address, _textViewText, imgStr, lat, lng, productMulID, timestampstr, @([userID integerValue])];
    
    //传入的参数
    NSDictionary *parameters =
    @{
      @"lat":lat,
      @"lng":lng,
      @"address":address,
      @"product_id":productMulID,
      @"images":imgStr,
      @"user_id": @([userID integerValue]),
      @"content":_textViewText,
      @"timestamp":timestampstr,
      @"sig":[GCService  md5:sigstr],
      };
    
    NSString *url=[[NSString stringWithFormat:@"%@AddDynamic",UNiZhaoNewURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
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
            //[MBProgressHUD showSuccess:[responseObject objectForKey:@"info"]];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            if (_publishFindBlock) {
                _publishFindBlock(responseObject[@"data"][@"balance"]);
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


#pragma mark - tableView delegate && datasource 


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YYZSelectProductTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kSelectProductID];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.separatorInset = UIEdgeInsetsMake(0, kMargin, 0, kMargin);
    
    NSDictionary *cellDict = self.productArr[indexPath.row];
    
    [cell.productImgView sd_setImageWithURL:[NSURL URLWithString:cellDict[@"product_image"]]];
    cell.titleLbl.text = cellDict[@"product_title"];
    cell.priceLbl.text = [NSString stringWithFormat:@"¥%@", cellDict[@"product_price"]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.productArr count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension + kMargin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTopH*2+kTableMinHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView viewWithBackgroundColor:WhiteColor superView:nil];
    
    view.height = kTopH*2+kTableMinHeight;
    
    UIView *addressView = [UIView viewWithBackgroundColor:WhiteColor superView:view];
    [addressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(kTopH);
    }];
    
    UILabel *addressLbl = [UILabel labelWithText:@"" font:kFont12 textColor:BlackGrayColor backGroundColor:ClearColor superView:addressView];
    [addressLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.centerX.centerY.mas_equalTo(0);
    }];
    
    if (_isShowAddress) {
        
        NSString *thoroughfare = self.placemark.thoroughfare;
        if ([thoroughfare isEqualToString:@"(null)"] || !thoroughfare) {
            thoroughfare = @"";
        }
        
        NSString *subThoroughfare = self.placemark.subThoroughfare;
        if ([subThoroughfare isEqualToString:@"(null)"] || !subThoroughfare) {
            subThoroughfare = @"";
        }
        
        addressLbl.attributedText = [NSString attributeWithTitle:@"" behindText:[NSString stringWithFormat:@"  %@%@%@%@", self.placemark.locality, self.placemark.subLocality, thoroughfare, subThoroughfare] imageName:@"place"];
    }
    
    CustomButton *btn = [CustomButton buttonWithRightImage:@"gou" title:@"点击显示位置" font:kFont12 titleColor:BlackGrayColor bgColor:ClearColor target:self action:@selector(clickShow:) buttonH:kTopH showView:addressView];
    [btn setImage:[UIImage imageNamed:@"eye_close"] forState:UIControlStateSelected];
    [btn setTitle:@"点击隐藏位置" forState:UIControlStateSelected];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kMargin);
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.centerY.mas_equalTo(0);
        make.height.mas_equalTo(kTopH);
    }];
    
    btn.selected = _isShowAddress;
    
    
    UIView *line = [UIView viewWithBackgroundColor:TableColor superView:view];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kTableMinHeight);
        make.top.mas_equalTo(addressView.mas_bottom);
    }];
    
    UILabel *label = [UILabel labelWithText:@"关联产品" font:kFont12 textColor:ThemeColor backGroundColor:ClearColor superView:view];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(kMargin);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(line.mas_bottom);
    }];
    
    UIButton *addBtn = [UIButton buttonWithImage:@"find_add_yellow" target:self action:@selector(clickAddProduct) showView:view];
    
    addBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kMargin);
    addBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(0);
        make.width.mas_equalTo(80);
        make.top.mas_equalTo(line.mas_bottom);
    }];
    
    
    UIView *topLine = [UIView viewWithBackgroundColor:SeparatorCOLOR superView:view];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.centerX.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    return view;
}

#pragma mark - 显示位置
- (void)clickShow:(CustomButton *)sender
{
    if (!_isAllowLocation) {
        //不允许定位
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"定位服务已关闭" message:@"您可到设置->隐私->定位服务中心开启【有意招】定位服务" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            [alertController dismissViewControllerAnimated:YES completion:nil];
            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //prefs:root=LOCATION_SERVICES
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        sender.selected = !sender.selected;
        
        _isShowAddress = sender.selected;
        
        [self.tableView reloadData];
    }
    
    
}

#pragma mark - 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]init];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.backgroundColor = WhiteColor;
        
        _tableView.tableFooterView = [UIView new];
        
        [self.view addSubview:_tableView];
        
        [_tableView registerClass:[YYZSelectProductTableCell class] forCellReuseIdentifier:kSelectProductID];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            //make.top.mas_equalTo(kNavigationH);
            make.left.right.top.mas_equalTo(0);
            make.bottom.mas_equalTo(self.footerView.mas_top);
        }];
        
    }
    return _tableView;

}


- (UIView *)footerView
{
    if (!_footerView) {
        UIView *footerView = [UIView viewWithBackgroundColor:TableColor superView:self.view];
        
        [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(35);
            
        }];
        
        UILabel *tipLbl = [UILabel labelWithText:@"温馨提示：请勿发布色情、反动、政治等敏感词汇" font:kFont10 textColor:ThemeColor backGroundColor:ClearColor superView:footerView];
        
        tipLbl.textAlignment = NSTextAlignmentCenter;
        
        [tipLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.mas_equalTo(0);
            make.left.mas_equalTo(kMargin);
        }];
        
        _footerView = footerView;
    }
    return _footerView;
}


- (UIView *)bgView{
    if (!_bgView) {
        
        _bgView = [[UIView alloc]init];
        
        _bgView.height = 240;
        
        _bgView.backgroundColor = [UIColor whiteColor];
        
        self.tableView.tableHeaderView = _bgView;
        
        
        NDTextView *textView = [[NDTextView alloc]init];
        [_bgView addSubview:textView];
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(120);
        }];
        textView.backgroundColor = [UIColor whiteColor];
        textView.font = [UIFont systemFontOfSize:15];
        textView.placeHolderLabel.text = @"请输入发布的内容";
        textView.returnText = ^(NSString *returnText){
            _textViewText = returnText;
        };
        NDAddPictureCollectionView *pictureView = [[NDAddPictureCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
        pictureView.isHiddenAdd = NO;
        [_bgView addSubview:pictureView];
        
        CGFloat sideEdge = 10;
        CGFloat itemWidth = (ScreenWidth-4*sideEdge)/3.0;
        
        [pictureView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-10);
            make.height.mas_equalTo(itemWidth+10);
        }];
        
        NDAddPictureCollectionView *tempView = pictureView;
        UIView *bgV = _bgView;
        pictureView.returnHeight = ^(CGFloat height)
        {
            
            bgV.height = 120+height;
            
            self.tableView.tableHeaderView = bgV;
            
            [tempView mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.left.right.mas_equalTo(0);
                make.bottom.mas_equalTo(-15);
                make.height.mas_equalTo(height);
                
            }];
        };
        
        pictureView.returnImgArr = ^(NSArray *imgArr){
            [_imgArr removeAllObjects];
            [_imgArr addObjectsFromArray:imgArr];
        };
        
    }
    return _bgView;
}


@end
