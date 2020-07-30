//
//  ViewController.m
//  feedback
//
//  Created by GasparChu on 2020/6/9.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "ViewController.h"
#import "FeedbackController.h"
#import <AppConfigInfo.h>
#import <LogHeader.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)goFeedback:(UIButton *)sender
{
    JLYLogInfo(@"goFeedback");
    FeedbackController *con = [FeedbackController new];
    [self.navigationController pushViewController:con animated:YES];
}

@end
