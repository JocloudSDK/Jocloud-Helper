//
//  UICollectionViewCell+JLYRegister.h
//  app
//
//  Created by GasparChu on 2020/6/1.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewCell (JLYRegister)


/// 注册 cell
/// Register cell
+ (void)jly_registerCellWithCollectionView:(UICollectionView *)collectionView;

/// 获取注册的 cell
/// Get cell
+ (instancetype)jly_cellWithCollectionView:(UICollectionView *)collectionView
                                 indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
