//
//  NDAddPictureCollectionView.h
//  NDBaseProject
//
//  Created by 王猛 on 2017/3/27.
//  Copyright © 2017年 王猛. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AJPhotoBrowserViewController.h"
#import "AJPhotoPickerViewController.h"


/** 单元格样式 */
@interface NDCollectionViewCellForCom : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imgV;

@end

typedef void(^CellAddBlock)();
@interface NDCollectionViewCellForAdd : UICollectionViewCell

@property (nonatomic,strong) UIButton *addPictureBtn;

@property (nonatomic, copy) CellAddBlock cellAddBlock;

@end

/** 处理回调的图片数组 */
typedef void(^returnImgArr) (NSArray *);


/** 处理回调的图片的显示高度 */
typedef void(^ReturnHeight) (CGFloat);


@interface NDAddPictureCollectionView : UICollectionView <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,GetPictureDelegate, AJPhotoPickerProtocol,AJPhotoBrowserDelegate>//UIImagePickerControllerDelegate>

/** IOS8 之后 用alertviewcontroller代替actionsheet 弹出脚部视图 */
//@property (nonatomic,strong) UIAlertController *alertController;

//是否有添加按钮
@property (nonatomic, assign) BOOL isHiddenAdd;


@property (nonatomic,copy) returnImgArr returnImgArr;
@property (nonatomic, copy) ReturnHeight returnHeight;
@property (nonatomic,strong) NSMutableArray *imgArr;/** 需要显示的图片数组 */

@end
