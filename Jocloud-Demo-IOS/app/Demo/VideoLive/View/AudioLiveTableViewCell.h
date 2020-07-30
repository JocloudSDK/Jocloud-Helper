//
//  AudioLiveTableViewCell.h
//  app
//
//  Created by 宁丽环 on 2020/7/10.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuidoUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AudioLiveTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *leftTextLabel;

@property (weak, nonatomic) IBOutlet UIImageView *mircImageView;

@property (nonatomic, strong) AuidoUserModel *model;

@end

NS_ASSUME_NONNULL_END
