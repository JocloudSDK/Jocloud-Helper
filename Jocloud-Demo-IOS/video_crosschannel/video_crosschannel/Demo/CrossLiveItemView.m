//
//  CrossLiveItemView.m
//  AFNetworking
//
//  Created by Huan on 2020/6/12.
//

#import "CrossLiveItemView.h"
#import "Masonry.h"
#import "UIImage+JLYBundle.h"
#import "NSBundle+Language.h"

@interface CrossLiveItemView()

@property (nonatomic, strong) UIView *canvasBottomView;
@property (nonatomic, strong) UIView *canvasView;
@property (nonatomic, strong) UIView *topBgView;
@property (nonatomic, strong) UILabel *previewLabel;
@property (nonatomic, strong) UIImageView *qualityImageView;
@property (nonatomic, strong) UILabel *upLabel;
@property (nonatomic, strong) UILabel *downLabel;

@end

@implementation CrossLiveItemView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setUserModel:(CrossLiveUserModel *)userModel
{
    _userModel = userModel;
    if (userModel.isLive) {
        //画布
        self.canvasBottomView.hidden = NO;
        [self.canvasBottomView addSubview:self.canvasView];
        [_canvasView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.width.height.equalTo(self.canvasBottomView);
        }];
    } else if (_canvasView != nil) {
        self.canvasBottomView.hidden = YES;
        [_canvasView removeFromSuperview];
        _canvasView = nil;
    }
    switch (userModel.canvasType) {
        case CanvasTypeLocal: {
            self.topBgView.hidden = NO;
            self.previewLabel.text = [NSBundle jly_localizedStringWithKey:@"本地预览"];
            [self refreshQuality];
            [self refreshQualityData];
            break;
        }
        case CanvasTypeRemote: {
            self.topBgView.hidden = NO;
            self.previewLabel.text = [NSBundle jly_localizedStringWithKey:@"远端订阅"];
            [self refreshQuality];
            break;
        }
        case CanvasTypeNone: {
            self.upLabel.hidden = YES;
            self.downLabel.hidden = YES;
            self.qualityImageView.hidden = YES;
            break;
        }
        default:
            break;
    }
}

- (void)refreshQuality
{
    self.qualityImageView.hidden = NO;
    UIImage *image;
    if (self.userModel.quality == 0) {
        image = [UIImage imageNamed:@"cross_quality_unknown"];
        if (!image) {
            image = [UIImage jly_imageWithName:@"cross_quality_unknown" bundle:@"video_crosschannel" targetClass:[self class]];
        }
    } else if (self.userModel.quality == 1 || self.userModel.quality == 2) {
        image = [UIImage imageNamed:@"cross_quality_best"];
        if (!image) {
            image = [UIImage jly_imageWithName:@"cross_quality_best" bundle:@"video_crosschannel" targetClass:[self class]];
        }
    } else if (self.userModel.quality == 3 || self.userModel.quality == 4) {
        image = [UIImage imageNamed:@"cross_quality_normal"];
        if (!image) {
            image = [UIImage jly_imageWithName:@"cross_quality_normal" bundle:@"video_crosschannel" targetClass:[self class]];
        }
    } else if (self.userModel.quality == 5 || self.userModel.quality == 6) {
        image = [UIImage imageNamed:@"cross_quality_bad"];
        if (!image) {
            image = [UIImage jly_imageWithName:@"cross_quality_bad" bundle:@"video_crosschannel" targetClass:[self class]];
        }
    }
    self.qualityImageView.image = image;
}

- (void)refreshQualityData
{
    NSString *txBitrate = [NSBundle jly_localizedStringWithKey:@"上行码率"];
    NSString *txAudioBitrate = [NSBundle jly_localizedStringWithKey:@"音频"];
    NSString *txVideoBitrate = [NSBundle jly_localizedStringWithKey:@"视频"];
    
    NSString *rxBitrate = [NSBundle jly_localizedStringWithKey:@"下行码率"];
    NSString *rxAudioBitrate = [NSBundle jly_localizedStringWithKey:@"音频"];
    NSString *rxVideoBitrate = [NSBundle jly_localizedStringWithKey:@"视频"];
    NSString *txString = [NSString stringWithFormat:@"%@: %dkbps %@: %dkbps %@: %dkbps",txBitrate,self.userModel.txBitrate,txAudioBitrate,self.userModel.txAudioBitrate,txVideoBitrate,self.userModel.txVideoBitrate];
    NSString *rxString = [NSString stringWithFormat:@"%@: %dkbps %@: %dkbps %@: %dkbps",rxBitrate,self.userModel.rxBitrate,rxAudioBitrate,self.userModel.rxAudioBitrate,rxVideoBitrate,self.userModel.rxVideoBitrate];
    self.downLabel.hidden = NO;
    self.upLabel.hidden = NO;
    self.upLabel.text = txString;
    self.downLabel.text = rxString;
}

- (void)setPreviewLabelText:(NSString *)text
{
    self.previewLabel.text = text;
}

- (void)setupUI
{
    UIImageView *defalutIV = [[UIImageView alloc] init];
    defalutIV.backgroundColor =  [UIColor colorWithRed:245/255.0 green:247/255.0 blue:253/255.0 alpha:1.0];
    UIImage *image = [UIImage imageNamed:@"cross_placeholder"];
    if (!image) {
        image = [UIImage jly_imageWithName:@"cross_placeholder" bundle:@"video_crosschannel" targetClass:[self class]];
    }
    defalutIV.image = image;
    defalutIV.contentMode = UIViewContentModeCenter;
    [self addSubview:defalutIV];
    
    self.canvasBottomView = [[UIView alloc] init];
    [self addSubview:self.canvasBottomView];
    self.canvasBottomView.hidden = YES;
    
    //顶部背景视图
    UIView *topBgView = [[UIView alloc] init];
    topBgView.alpha = 0.4;
    topBgView.backgroundColor = [UIColor blackColor];
    [self addSubview:topBgView];
    self.topBgView = topBgView;
    
    //预览label
    UILabel *previewLabel = [self createLabelWithFont:[UIFont systemFontOfSize:11] textColor:[UIColor whiteColor]];
    self.previewLabel = previewLabel;
    
    //信号质量
    UIImageView *qualityIV = [self createImageView];
    qualityIV.hidden = YES;
    self.qualityImageView = qualityIV;
    
    //下行数据
    UILabel *downLabel = [self createLabelWithFont:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
    downLabel.hidden = YES;
    self.downLabel = downLabel;
    
    //上行数据
    UILabel *upLabel = [self createLabelWithFont:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
    upLabel.hidden = YES;
    self.upLabel = upLabel;
    
    
    [defalutIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.equalTo(self);
    }];
    [self.canvasBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.equalTo(self);
    }];
    [topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@18);
    }];
    [previewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.height.equalTo(topBgView);
        make.left.equalTo(topBgView.mas_left).offset(6);
    }];
    [qualityIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topBgView.mas_right).offset(-6);
        make.centerY.equalTo(topBgView.mas_centerY);
        make.width.equalTo(@18);
        make.height.equalTo(@12);
    }];
    [downLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
        make.height.equalTo(@14);
        make.height.equalTo(@400);
    }];
    [upLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.height.equalTo(downLabel);
        make.bottom.equalTo(downLabel.mas_top).offset(-2);
    }];
}

- (UILabel *)createLabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    label.textAlignment = NSTextAlignmentLeft;
    [self addSubview:label];
    return label;
}

- (UIImageView *)createImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    [self addSubview:imageView];
    return imageView;
}

- (UIView *)canvasView
{
    if (!_canvasView) {
        _canvasView = [[UIView alloc] init];
    }
    return _canvasView;
}

- (UIView *)userCanvasView
{
    return self.canvasView;
}


@end
