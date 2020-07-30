//
//  DocumentWebController.m
//  AFNetworking
//
//  Created by Huan on 2020/6/9.
//

#import "DocumentWebController.h"
#import <WebKit/WebKit.h>
#import "MBProgressHUD+JLYHUD.h"

API_AVAILABLE(ios(8.0))
@interface DocumentWebController ()<WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation DocumentWebController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 8.0, *)) {
        WKWebViewConfiguration *webConfiguration = [WKWebViewConfiguration new];
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height) configuration:webConfiguration];
        NSString *urlStr = self.documentUrl;
        _webView.navigationDelegate = self;
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [_webView loadRequest:request];
        [self.view addSubview:_webView];
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [MBProgressHUD jly_showLoadingActivityIndicatorWithDruation:30];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [MBProgressHUD jly_hideActivityIndicator];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [MBProgressHUD jly_hideActivityIndicator];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [MBProgressHUD jly_hideActivityIndicator];
}

@end
