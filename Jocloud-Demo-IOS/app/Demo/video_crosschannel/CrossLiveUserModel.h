//
//  CrossLiveUserModel.h
//  AFNetworking
//
//  Created by Huan on 2020/6/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CanvasType) {
    CanvasTypeNone = 0,     //没有类型
    CanvasTypeLocal,        //本地预览
    CanvasTypeRemote        //远端视图
};

@interface CrossLiveUserModel : NSObject

/// 关闭音频
/// Turn off audio
@property (nonatomic, assign) BOOL audioStoped;
/// 是否开播
/// Whether to start broadcasting
@property (nonatomic, assign) BOOL isLive;
/// 预览类型
/// Canvas type
@property (nonatomic, assign) CanvasType canvasType;
/// 上行码率
/// Upstream bit rate
@property (nonatomic, assign) int txBitrate;
/// 上行音频
/// Upstream audio bit rate
@property (nonatomic, assign) int txAudioBitrate;
/// 上行视频
/// Upstream video bit rate
@property (nonatomic, assign) int txVideoBitrate;
/// 下行码率
/// DownStream bit rate
@property (nonatomic, assign) int rxBitrate;
/// 下行音频
/// DownStream audio bit rate
@property (nonatomic, assign) int rxAudioBitrate;
/// 下行视频
/// DownStream video bit rate
@property (nonatomic, assign) int rxVideoBitrate;
/// 网络质量
/// Network Quality
@property (nonatomic, assign) int quality;
/// uid
@property (nonatomic, copy) NSString *uid;
/// roomId
@property (nonatomic, copy) NSString *roomId;

- (void)resetModelData;

@end

NS_ASSUME_NONNULL_END
