//
//  LiveFunctionView.h
//  app
//
//  Created by 宁丽环 on 2020/7/8.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveFunctionModel.h"


@protocol LiveFunctionViewDelegate <NSObject>

- (void)liveFunctionViewDidSelectItemWithType:(LiveFunctionType)type selected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LiveFunctionView : UIView

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, strong) NSMutableArray *dataArray;


@property (nonatomic, assign) id <LiveFunctionViewDelegate> delegate;

- (instancetype)initWithLayout:(UICollectionViewFlowLayout *)layout;

- (void)refreshView;

@end

NS_ASSUME_NONNULL_END
