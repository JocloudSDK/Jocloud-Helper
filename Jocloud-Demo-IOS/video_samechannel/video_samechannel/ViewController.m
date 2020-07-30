//
//  ViewController.m
//  video_samechannel
//
//  Created by GasparChu on 2020/5/26.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "ViewController.h"
#import "SameChannelController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)clickGoChannel:(UIButton *)sender
{
    SameChannelController *con = [SameChannelController new];
    [self.navigationController pushViewController:con animated:YES];
}

@end
