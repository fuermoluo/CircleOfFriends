//
//  YYZFindTableCell.h
//  Youyizhao
//
//  Created by WenhuaLuo on 17/5/9.
//  Copyright © 2017年 Nado. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDTimeLineCellModel.h"

@protocol SDTimeLineCellModelDelegate <NSObject>

@optional
-(void)clickDeleteWith:(NSIndexPath *)index;

- (void)clickBrowser:(NSIndexPath *)index;

- (void)clickProductWithIndexPath:(NSIndexPath *)indexPath productIndex:(NSInteger)index;

- (void)clickFoucsReload;//操作关注之后刷新页面

@end

@interface YYZFindTableCell : UITableViewCell

@property (nonatomic, strong) SDTimeLineCellModel *model;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, weak)id<SDTimeLineCellModelDelegate> delegate;

@property (nonatomic, strong) UINavigationController *supNavigationController;

@end



@interface YYZFindDetailTableCell : UITableViewCell

//故事里面显示
@property (nonatomic, strong) UIView *bgView;

//名＋回复＋名
@property (nonatomic, strong) UILabel *nameLbl;

@property (nonatomic, strong) UILabel *tipLbl;//回复

@property (nonatomic, strong) UILabel *otherNameLbl;

@property (nonatomic, strong) UILabel *contentLbl;

@property (nonatomic, strong) UINavigationController *supNavigationController;

@end
