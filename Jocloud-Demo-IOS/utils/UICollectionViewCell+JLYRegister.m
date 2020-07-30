//
//  UICollectionViewCell+JLYRegister.m
//  app
//
//  Created by GasparChu on 2020/6/1.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "UICollectionViewCell+JLYRegister.h"

@implementation UICollectionViewCell (JLYRegister)

+ (NSString *)jly_reuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (void)jly_registerCellWithCollectionView:(UICollectionView *)collectionView
{
    NSString *nibPath = [[NSBundle mainBundle] pathForResource:[self jly_reuseIdentifier] ofType:@"nib"];
    if (nibPath) {
        UINib *nib = [UINib nibWithNibName:[self jly_reuseIdentifier] bundle:[NSBundle bundleForClass:[self class]]];
        [collectionView registerNib:nib forCellWithReuseIdentifier:[self jly_reuseIdentifier]];
    } else {
        [collectionView registerClass:[self class] forCellWithReuseIdentifier:[self jly_reuseIdentifier]];
    }
}

+ (instancetype)jly_cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self jly_reuseIdentifier] forIndexPath:indexPath];
    if (!cell) {
        [self jly_registerCellWithCollectionView:collectionView];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self jly_reuseIdentifier] forIndexPath:indexPath];
    }
    return cell;
}

@end
