//
//  LiveFunctionModel.h
//  app
//
//  Created by 宁丽环 on 2020/7/13.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,LiveFunctionType) {
    LiveFunctionTypeNone,
    LiveFunctionTypeQuality,
    LiveFunctionTypeMirror,
    LiveFunctionTypeRender,
    LiveFunctionTypeDirection,
    LiveFunctionTypeOnOrOffCamera,
    LiveFunctionTypeFrontOrRearCamera,
    LiveFunctionTypeApi,
    LiveFunctionTypeLog,
    LiveFunctionTypefeedback,
    LiveFunctionTypeSpeaker,//扬声器
    LiveFunctionTypeEarReturn,//耳返
    LiveFunctionTypeEarVariety//变声
};

typedef NS_ENUM(NSInteger,LiveFunctionAlertType) {
    LiveFunctionAlertTypeStallNone,
    LiveFunctionAlertTypeStallSmooth,//流畅
    LiveFunctionAlertTypeStallMark, //标清
    LiveFunctionAlertTypeStallHD,   //高清
    LiveFunctionAlertTypeStallClear,//超清
    LiveFunctionAlertTypeRenderStretch, //拉伸
    LiveFunctionAlertTypeRenderCut,//裁剪
    LiveFunctionAlertTypeRenderFit,//适应窗口
    LiveFunctionAlertTypeMirrorPreview,//预览
    LiveFunctionAlertTypeMirrorPushflow//推流
};
// Mirroring
typedef NS_ENUM(NSInteger, JYLMirrorMode)
{
  JYLMirrorMode_PREVIEW_MIRROR_PUBLISH_NO_MIRROR = 0, // The preview other than stream publishing is mirrored
  JYLMirrorMode_PREVIEW_PUBLISH_BOTH_MIRROR = 1, // Both preview and stream publishing are not mirrored
  JYLMirrorMode_PUBLISH_BOTH_NO_MIRROR = 2, // Neither preview and stream publishing is not mirrored
  JYLMirrorMode_PREVIEW_NO_MIRROR_PUBLISH_MIRROR = 3, // Preview is not mirrored, but publish is mirrored
};
NS_ASSUME_NONNULL_BEGIN

@interface LiveFunctionModel : NSObject

@property (nonatomic, copy) NSString *normalTitle;

@property (nonatomic, copy) NSString *selectedTitle;

@property (nonatomic, copy) NSString *imageName;


@property (nonatomic, assign) LiveFunctionType type;

@property (nonatomic, assign) LiveFunctionAlertType functionType;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) BOOL isSelectedLeft;

@property (nonatomic, assign) BOOL isSelectedRight;

+ (instancetype)liveFunctionModelWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle image:(NSString *)imageName functionType:(LiveFunctionType)type;

+ (instancetype)liveFunctionModelWithTitle:(NSString *)title functionType:(LiveFunctionAlertType)type;
@end

NS_ASSUME_NONNULL_END
