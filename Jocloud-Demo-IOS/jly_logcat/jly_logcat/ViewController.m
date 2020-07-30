//
//  ViewController.m
//  jly_logcat
//
//  Created by GasparChu on 2020/5/26.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "ViewController.h"
#import "LogHeader.h"

@interface ViewController ()

@end

@implementation ViewController {
    dispatch_source_t _timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LogTableController *con = [LogManager sharedInstance].logController;
    [self addChildViewController:con];
    [self.view addSubview:con.view];    
    con.view.frame = (CGRect) {0, 200, self.view.frame.size.width, self.view.frame.size.height - 200};

    
    JLYLogInfo(@"1111asdasdasdasdasdasdasdasdasdasdasdasdasdasdasdsadasd%@", @"爱上了凯迪拉克时间啦达拉斯");
    JLYLogWarn(@"2222");
    JLYLogSuccess(@"3333");
    JLYLogError(@"4444");
    
    dispatch_queue_t  queue = dispatch_get_global_queue(0, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        JLYLogInfo(@"1111asdasdasdasdasdasdasdasdasdasdasdasdasdasdasdsadasd%@", @"爱上了凯迪拉克时间啦达拉斯");
    });
    dispatch_resume(_timer);
}


@end
