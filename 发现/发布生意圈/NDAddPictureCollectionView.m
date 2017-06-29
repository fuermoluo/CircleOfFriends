//
//  NDAddPictureCollectionView.m
//  NDBaseProject
//
//  Created by 王猛 on 2017/3/27.
//  Copyright © 2017年 王猛. All rights reserved.
//

#import "NDAddPictureCollectionView.h"

#define kMaxPicNum 6

@implementation NDCollectionViewCellForCom
#pragma mark ******************** 懒加载 *****************************
- (UIImageView *)imgV{
    if (!_imgV) {
        _imgV = [UIImageView new];
        [self addSubview:_imgV];
        [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _imgV;
}
@end

@implementation NDCollectionViewCellForAdd

- (void)clickAddPic
{
    if (_cellAddBlock) {
        _cellAddBlock();
    }
    
}

- (UIButton *)addPictureBtn{
    if (!_addPictureBtn) {
        
        _addPictureBtn = [UIButton buttonWithImage:@"find_add_pic" target:self action:@selector(clickAddPic) showView:self.contentView];
        
        _addPictureBtn.backgroundColor = TableColor;
        //[UIButton buttonWithBackgroundImage:@"" target:self action:@selector(clickAddPic) showView:self.contentView];
        
        [_addPictureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
    }
    return _addPictureBtn;
}

@end

@implementation NDAddPictureCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout{
    /** 初始化设置layout */
    CGFloat sideEdge = 10;
    //CGFloat itemEdge = 10;
    layout.sectionInset = UIEdgeInsetsMake(sideEdge, sideEdge, sideEdge, sideEdge);
    layout.minimumLineSpacing = sideEdge;
    layout.minimumInteritemSpacing = sideEdge/2.0;
    //layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat itemWidth = (ScreenWidth-4*sideEdge)/3.0;//ImgWidth(90);
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    self.scrollEnabled = NO;
    
    _imgArr = [NSMutableArray new];
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.backgroundColor = [UIColor whiteColor];
        self.delegate = self;
        self.dataSource = self;
        self.showsHorizontalScrollIndicator = NO;
        [self registerClass:[NDCollectionViewCellForCom class] forCellWithReuseIdentifier:@"Cell0"];
        [self registerClass:[NDCollectionViewCellForAdd class] forCellWithReuseIdentifier:@"Cell1"];
    }
    return self;

}
#pragma mark - *******************************  UICollectionViewDataSource  *******************************

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return MIN(kMaxPicNum, _imgArr.count+1);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == [self.imgArr count]) {
        
        NDCollectionViewCellForAdd *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell1" forIndexPath:indexPath];
        
        if (!self.isHiddenAdd) {
            [cell addPictureBtn];
        }
        
        cell.cellAddBlock = ^()
        {
            //选择照片
            [[GetPicture sharedInstance]initPhotePickerWithController:APPDELEGATE.window.rootViewController selectMaxNum:kMaxPicNum containArr:self.imgArr keyTag:@"照片" delegate:self];
        };
        
        return cell;
    }
    NDCollectionViewCellForCom *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell0" forIndexPath:indexPath];
    
    if ([_imgArr[indexPath.row] isKindOfClass:[UIImage class]]) {
        cell.imgV.image = _imgArr[indexPath.row];
    }
    else
    {
        [cell.imgV sd_setImageWithURL:[NSURL URLWithString:_imgArr[indexPath.row]]];
    }
    return cell;
}
#pragma mark *************************** UICollectionViewDelegate *******************************
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == [self.imgArr count] ) {
        //选择照片
        [[GetPicture sharedInstance]initPhotePickerWithController:APPDELEGATE.window.rootViewController selectMaxNum:kMaxPicNum containArr:self.imgArr keyTag:@"照片" delegate:self];
    }
    else
    {
        //预览图片
        //显示预览
        AJPhotoBrowserViewController *photoBrowserViewController = [[AJPhotoBrowserViewController alloc] initWithPhotos:self.imgArr index:indexPath.row];
        
        photoBrowserViewController.delegate = self;
        
        photoBrowserViewController.isHiddenDelete = self.isHiddenAdd;
        
        [APPDELEGATE.window.rootViewController presentViewController:photoBrowserViewController animated:YES completion:nil];
    }
}


#pragma mark - AJPhotoBrowserDelegate,,图片预览

- (void)photoBrowser:(AJPhotoBrowserViewController *)vc deleteWithIndex:(NSInteger)index {
    
    [self.imgArr removeObjectAtIndex:index];
    
    [self evaluateHeight];

    if (self.returnImgArr) {
        self.returnImgArr([self.imgArr copy]);
    }
    
    [self reloadData];
}


- (void)photoBrowser:(AJPhotoBrowserViewController *)vc didDonePhotos:(NSArray *)photos {
    [vc dismissViewControllerAnimated:YES completion:nil];
}


- (void)evaluateHeight
{
    
    if (self.returnHeight) {
        
        
        CGFloat sideEdge = 10;
        CGFloat itemWidth = (ScreenWidth-4*sideEdge)/3.0;
        
        NSInteger num = MIN(self.imgArr.count+1, kMaxPicNum);
        
        CGFloat height = 0;
        
        if (num <= 3) {
            //一行
            height = itemWidth+sideEdge;
        }
        else
        {
            height = (itemWidth+sideEdge)*2;
        }
        
        self.returnHeight(height);
    }

}

#pragma mark - GetPictureDelegate,选择照片

- (void)getPictureResult:(NSArray *)pictureArr keyTag:(NSString *)keyTag
{//[@[base64, UIImage]]
    
    if ([keyTag isEqualToString:@"照片"]) {
        
        [self.imgArr removeAllObjects];
        
        for (id picture in pictureArr) {
            
            if ([picture isKindOfClass:[NSArray class]]) {
                [self.imgArr addObject:picture[1]];
            }
            else
                [self.imgArr addObject:picture];
            
        }
        
        [self evaluateHeight];
        
        if (self.returnImgArr) {
            self.returnImgArr([self.imgArr copy]);
        }
        
        [self reloadData];
    }
}


@end
