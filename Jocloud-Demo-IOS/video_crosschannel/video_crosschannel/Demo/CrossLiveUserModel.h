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

@property (nonatomic, assign) BOOL audioStoped;             //关闭音频
@property (nonatomic, assign) BOOL isLive;                  //是否开播
@property (nonatomic, assign) CanvasType canvasType;        //预览类型
@property (nonatomic, assign) int txBitrate;                //上行码率
@property (nonatomic, assign) int txAudioBitrate;           //上行音频
@property (nonatomic, assign) int txVideoBitrate;           //上行视频
@property (nonatomic, assign) int rxBitrate;                //下行码率
@property (nonatomic, assign) int rxAudioBitrate;           //下行音频
@property (nonatomic, assign) int rxVideoBitrate;           //下行视频
@property (nonatomic, assign) int quality;                  //网络质量
@property (nonatomic, copy) NSString *uid;                  //用户uid
@property (nonatomic, copy) NSString *roomId;               //roomId

- (void)resetModelData;

@end

NS_ASSUME_NONNULL_END
