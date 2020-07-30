//
//  CrossLiveItemView.h
//  AFNetworking
//
//  Created by Huan on 2020/6/12.
//

#import <UIKit/UIKit.h>
#import "CrossLiveUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CrossLiveItemView : UIView

@property (nonatomic, strong) CrossLiveUserModel *userModel;
@property (nonatomic, strong) UIView *userCanvasView;

- (void)refreshQuality;
- (void)refreshQualityData;
- (void)setPreviewLabelText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
