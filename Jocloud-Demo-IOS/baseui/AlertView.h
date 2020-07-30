//
//  AlertView.h
//  AFNetworking
//
//  Created by Huan on 2020/6/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AlertViewType) {
    AlertViewTypeNormal = 0,       //普通、Normal
    AlertViewTypeTimer,            //计时器、Timer
    AlertViewTypeToast             //Toast
};

@protocol AlertViewDelegate <NSObject>

- (void)sureAction;
- (void)cancelAction:(BOOL)isTimeOut;
- (void)timeOutAction;

@end

@interface AlertView : UIView

@property (nonatomic, assign) id<AlertViewDelegate> delegate;
@property (nonatomic, assign) AlertViewType alertType;
@property (nonatomic, copy) NSString *remoteUid;
- (void)stopTimer;
@end

NS_ASSUME_NONNULL_END
