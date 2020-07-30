//
//  auidoUserModel.h
//  app
//
//  Created by 宁丽环 on 2020/7/14.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AuidoUserModel : NSObject

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, assign) BOOL isSelected;

+ (instancetype)auidoUserModelWithUid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
