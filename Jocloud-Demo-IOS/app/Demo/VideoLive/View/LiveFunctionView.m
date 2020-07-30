//
//  LiveFunctionView.m
//  app
//
//  Created by 宁丽环 on 2020/7/8.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "LiveFunctionView.h"
#import "LiveFunctionCollectionViewCell.h"
#import "MBProgressHUD+JLYHUD.h"
#import "NSBundle+Language.h"
#import "UIColor+SLExtention.h"
#import "BaseMacro.h"

@interface LiveFunctionView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) BOOL isCloseCamera;//是否关闭了摄像头
@property (nonatomic, assign) BOOL isLandscapeLeft;
@property (nonatomic, strong) NSMutableArray *landscapeLeftdataArray;

@end

@implementation LiveFunctionView


- (instancetype)initWithLayout:(UICollectionViewFlowLayout *)layout;
{
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil].lastObject;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView setCollectionViewLayout:layout];
        [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([LiveFunctionCollectionViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([LiveFunctionCollectionViewCell class])];
        self.collectionView.scrollEnabled = NO;
        UIDevice *device = [UIDevice currentDevice]; //Get the device object
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
    }
    return self;
}

- (void)orientationChanged:(NSNotification *)noti
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait: {          // Device oriented
            self.isLandscapeLeft = NO;
            [self.landscapeLeftdataArray removeAllObjects];
            [self.collectionView reloadData];
            if (self.dataArray.count == 2) {
                LiveFunctionModel *model  = [((NSArray *)[self.dataArray objectAtIndex:1]) objectAtIndex:0];
                model.isSelected = NO;
                [self refreshView];
            }
            if (self.dataArray.count == 1 && ((NSArray *)self.dataArray.firstObject).count == 2) {
                LiveFunctionModel *model  = [((NSArray *)[self.dataArray objectAtIndex:0]) objectAtIndex:0];
                model.isSelected = NO;
                [self refreshView];
            }
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            if (self.dataArray.count == 2) {
                self.isLandscapeLeft = YES;
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                for (NSArray *sectionArray in self.dataArray) {
                    [tempArray addObjectsFromArray:sectionArray];
                }
                LiveFunctionModel *model  = [tempArray objectAtIndex:3];
                model.isSelected = YES;
                [self.landscapeLeftdataArray addObject:[NSArray arrayWithArray:tempArray]];
                [self refreshView];
            }
            if (self.dataArray.count == 1 && ((NSArray *)self.dataArray.firstObject).count == 2) {
                //横屏观众
                LiveFunctionModel *model  = [((NSArray *)[self.dataArray objectAtIndex:0]) objectAtIndex:0];
                model.isSelected = YES;
                [self refreshView];
                
            }
            [self.collectionView reloadData];
        }
            break;
        default:
            break;
    }
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray =  [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    LiveFunctionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LiveFunctionCollectionViewCell class]) forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
    LiveFunctionModel *model = nil;
    if (self.isLandscapeLeft) {
        model = self.landscapeLeftdataArray[indexPath.section][indexPath.row];
    } else {
        model = self.dataArray[indexPath.section][indexPath.row];
    }
     cell.model = model;
    //防止cell复用
     cell.titleColor = [UIColor sl_colorWithHexString:@"ffffff"];
     if (cell.model.type == LiveFunctionTypeFrontOrRearCamera) {
        if (self.isCloseCamera) {
            cell.titleColor = [UIColor colorWithWhite:1 alpha:0.5];
        } else {
            cell.titleColor = [UIColor sl_colorWithHexString:@"ffffff"];
        }
    }
    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.isLandscapeLeft) {
        NSArray *rowArray = self.landscapeLeftdataArray[section];
        return rowArray.count;
    } else {
        NSArray *rowArray = self.dataArray[section];
        return rowArray.count;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.isLandscapeLeft) {
        return 1;
    } else {
        return self.dataArray.count;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LiveFunctionModel *model = nil;
    if (self.landscapeLeftdataArray.count) {
        model = self.landscapeLeftdataArray[indexPath.section][indexPath.row];
    } else {
        model = self.dataArray[indexPath.section][indexPath.row];
    }
    if (!(model.type == LiveFunctionTypeLog || model.type == LiveFunctionTypeApi || model.type == LiveFunctionTypefeedback)) {
         if (!self.enabled) {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"禁止操作"]];
            return;
           }
    }
    
    model.isSelected = !model.isSelected;
    if (model.type == LiveFunctionTypeOnOrOffCamera) {
        if (model.isSelected) {
            self.isCloseCamera = YES;
        } else {
            self.isCloseCamera = NO;
        }
    }
    
    if (model.type == LiveFunctionTypeFrontOrRearCamera) {
        if (self.isCloseCamera) {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"禁止操作"]];
            return;
        }
    }
    [collectionView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(liveFunctionViewDidSelectItemWithType:selected:)]) {
        [self.delegate liveFunctionViewDidSelectItemWithType:model.type selected:model.isSelected];
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isLandscapeLeft) {
        return CGSizeMake(((kScreenWidth - 90.0 - 10) - 6 * 10)/6.0, 36);
    } else {
        LiveFunctionModel *model = self.dataArray[indexPath.section][indexPath.row];
        if (model.type == LiveFunctionTypeApi || model.type == LiveFunctionTypeLog || model.type == LiveFunctionTypefeedback) {
            CGFloat item_w = 50.0;
            CGFloat item_h = 50.0;
            return CGSizeMake(item_w, item_h);
        } else if (model.type == LiveFunctionTypeSpeaker|| model.type ==LiveFunctionTypeEarReturn|| model.type == LiveFunctionTypeEarVariety) {
            CGFloat item_w = 50.0;
            CGFloat item_h = 50.0;
            return CGSizeMake(item_w, item_h);
            return CGSizeMake(item_w, item_h);
        } else if (model.type == LiveFunctionTypeDirection|| model.type ==LiveFunctionTypeRender) {
            if (((NSArray *)self.dataArray[indexPath.section]).count == 2) {
                CGFloat item_w = ((kScreenWidth - 190)- 20)/2.0 > 88.0 ? 88.0 :((kScreenWidth - 190)- 20)/2.0;
                 return CGSizeMake(item_w, 36);
            } else {
                return CGSizeMake(((kScreenWidth - 90.0 - 10) - 3 * 10)/3.0, 36);
            }
            
        } else {
            return CGSizeMake(((kScreenWidth - 90.0 - 10) - 3 * 10)/3.0, 36);
        }
    }
}

- (void)refreshView
{
    [self.collectionView reloadData];
}

- (NSMutableArray *)landscapeLeftdataArray
{
    if (!_landscapeLeftdataArray) {
        _landscapeLeftdataArray  = [[NSMutableArray alloc]init];
    }
    return _landscapeLeftdataArray;
}

@end
