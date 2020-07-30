//
//  JYLButtonTableViewCell.h
//  app
//
//  Created by 宁丽环 on 2020/7/17.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveFunctionModel.h"
@protocol JYLButtonTableViewCellDelegate <NSObject>

- (void)didChangeMirrorMode:(LiveFunctionModel *_Nullable)model;

@end

NS_ASSUME_NONNULL_BEGIN

@interface JYLButtonTableViewCell : UITableViewCell

@property (strong, nonatomic)  LiveFunctionModel *model;
@property (nonatomic, assign) id <JYLButtonTableViewCellDelegate> delegate;
 
@end

NS_ASSUME_NONNULL_END
