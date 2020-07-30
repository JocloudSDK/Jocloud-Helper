//
//  LivePublicTalkCell.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/11.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LivePublicTalkCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *talkLable;
@property (weak, nonatomic) IBOutlet UILabel *uidLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

NS_ASSUME_NONNULL_END
