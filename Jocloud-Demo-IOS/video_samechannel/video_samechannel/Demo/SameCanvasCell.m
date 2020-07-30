//
//  SameCanvasCell.m
//  video_samechannel
//
//  Created by GasparChu on 2020/6/3.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "SameCanvasCell.h"
#import "Masonry.h"
#import "NSBundle+Language.h"
#import "UIImage+JLYBundle.h"

@interface SameCanvasCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *uidLabel;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIImageView *placeholderImg;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *audioBtn;
@property (nonatomic, strong) LiveView *liveView;

@end

@implementation SameCanvasCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setLiveView:(LiveView *)view
{
    _liveView = view;
    LiveUserModel *model = view.userModel;
    if (!view || model.fullScreen) {
        [self removeCanvasSubviews];
        self.cameraBtn.selected = NO;
        self.cameraBtn.hidden = NO;
        self.audioBtn.selected = NO;
        self.audioBtn.hidden = NO;
        self.uidLabel.text = @"";
        self.placeholderImg.hidden = NO;
        return;
    }
    
    if ([view isDescendantOfView:self.containerView]) {
        [view removeFromSuperview];
    }
    [self.containerView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0.f);
    }];
    
    
    self.cameraBtn.selected = model.videoUnSubscribe;
    self.cameraBtn.hidden = model.localVideo;
    self.audioBtn.selected = model.audioUnSubscribe;
    self.audioBtn.hidden = model.localVideo;
    self.uidLabel.text = [NSString stringWithFormat:@"  %@%@", model.localVideo ? [NSString stringWithFormat:@"%@/", [NSBundle jly_localizedStringWithKey:@"本地预览"]] : @"", model.uid];
    self.placeholderImg.hidden = YES;
}

- (void)removeCanvasSubviews
{
    for (UIView *subView in self.containerView.subviews) {
        [subView removeFromSuperview];
    }
}

- (void)setupUI
{
    self.contentView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.containerView];
    [self.contentView.layer addSublayer:self.gradientLayer];
    [self.contentView addSubview:self.uidLabel];
    [self.contentView addSubview:self.cameraBtn];
    [self.contentView addSubview:self.audioBtn];
    [self.contentView addSubview:self.placeholderImg];
    
    [self setupLayout];
}

- (void)setupLayout
{
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0.f);
    }];
    [self.uidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_offset(0.f);
        make.left.mas_offset(0.f);
        make.height.mas_offset(18.f);
    }];
    [self.audioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-6.f);
        make.bottom.mas_offset(-3.f);
        make.size.mas_offset(33.f);
    }];
    [self.cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.audioBtn.mas_left).mas_offset(-6.f);
        make.size.centerY.mas_equalTo(self.audioBtn);
    }];
    [self.placeholderImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0.f);
    }];
}

- (void)layoutSubviews
{
    self.gradientLayer.frame = (CGRect){0, 0, self.uidLabel.frame.size.width, self.uidLabel.frame.size.height};
}

#pragma mark - Event
- (void)clickCameraBtn:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    if ([self.delegate respondsToSelector:@selector(cameraBtnClicked:stoped:)]) {
        [self.delegate cameraBtnClicked:self.liveView.userModel stoped:sender.isSelected];
    }
}

- (void)clickAudioBtn:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    if ([self.delegate respondsToSelector:@selector(audioBtnClicked:stoped:)]) {
        [self.delegate audioBtnClicked:self.liveView.userModel stoped:sender.isSelected];
    }
}

#pragma mark Getter/Setter
- (UIView *)containerView
{
    if (!_containerView) {
        UIView *view = [UIView new];
        _containerView = view;
    }
    return _containerView;
}

- (UILabel *)uidLabel
{
    if (!_uidLabel) {
        UILabel *label = [UILabel new];
//        label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11.f];
        _uidLabel = label;
    }
    return _uidLabel;
}

- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer) {
        CAGradientLayer *layer = [CAGradientLayer new];
        layer.startPoint = CGPointMake(1, 0.5);
        layer.endPoint = CGPointMake(0, 0.5);
        layer.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor,                (__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4].CGColor];
        layer.locations = @[@0, @1];
        _gradientLayer = layer;
    }
    return _gradientLayer;
}

- (UIImageView *)placeholderImg
{
    if (!_placeholderImg) {
        UIImageView *imgView = [UIImageView new];
        imgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:247/255.0 blue:253/255.0 alpha:1.0];
        UIImage *image = [UIImage imageNamed:@"same_placeholder"];
        if (!image) {
            image = [UIImage jly_imageWithName:@"same_placeholder" bundle:@"video_samechannel" targetClass:[self class]];
        }
        imgView.image = image;
        imgView.contentMode = UIViewContentModeCenter;
        _placeholderImg = imgView;
    }
    return _placeholderImg;
}

- (UIButton *)cameraBtn
{
    if (!_cameraBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"same_camera"];
        if (!image) {
            image = [UIImage jly_imageWithName:@"same_camera" bundle:@"video_samechannel" targetClass:[self class]];
        }
        UIImage *unimage = [UIImage imageNamed:@"same_uncamera"];
        if (!unimage) {
            unimage = [UIImage jly_imageWithName:@"same_uncamera" bundle:@"video_samechannel" targetClass:[self class]];
        }
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:unimage forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(clickCameraBtn:) forControlEvents:UIControlEventTouchUpInside];
        _cameraBtn = btn;
    }
    return _cameraBtn;
}

- (UIButton *)audioBtn
{
    if (!_audioBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"same_audio"];
        if (!image) {
            image = [UIImage jly_imageWithName:@"same_audio" bundle:@"video_samechannel" targetClass:[self class]];
        }
        UIImage *unimage = [UIImage imageNamed:@"same_unaudio"];
        if (!unimage) {
            unimage = [UIImage jly_imageWithName:@"same_unaudio" bundle:@"video_samechannel" targetClass:[self class]];
        }
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:unimage forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(clickAudioBtn:) forControlEvents:UIControlEventTouchUpInside];
        _audioBtn = btn;
    }
    return _audioBtn;
}

@end
