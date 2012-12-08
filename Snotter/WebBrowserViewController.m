//
//  WebBrowserViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "WebBrowserViewController.h"
#import "SVProgressHUD.h"

@interface WebBrowserViewController ()

@property (nonatomic) NSURL *url;

@end

@implementation WebBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithURL:(NSString *)urlString
{
    self = [super initWithNibName:@"WebBrowserViewController" bundle:nil];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.naviBar.tintColor = HEXCOLOR(NAVIGATION_BAR_COLOR);
    self.toolBar.tintColor = HEXCOLOR(NAVIGATION_BAR_COLOR);
    
    UIBarButtonItem *btnSetting = [[UIBarButtonItem alloc] initWithTitle:@"閉じる"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(close)];
    self.naviBarItem.leftBarButtonItem = btnSetting;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0f];
    
    [self.tweetWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTweetWebView:nil];
    [self setNaviBar:nil];
    [self setNaviBarItem:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self updateTitleWithTitle:[self.tweetWebView stringByEvaluatingJavaScriptFromString:@"document.title"]];
    [self stopIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopIndicator];
}

#pragma mark -

- (void)startIndicator
{
    // インジケータ開始
    [[NetworkActivityManager sharedInstance] increment];
    [SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeNone];
}

- (void)stopIndicator
{
    // インジケータ停止
    [[NetworkActivityManager sharedInstance] decrement];
    [SVProgressHUD dismiss];
}

- (IBAction)openSafari:(id)sender
{
    NSString* url = [self.tweetWebView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction)back:(id)sender
{
    [self.tweetWebView goBack];
}

- (IBAction)forward:(id)sender
{
    [self.tweetWebView goForward];
}

- (IBAction)refresh:(id)sender
{
    [self.tweetWebView reload];
}

- (void)close
{
    if (self.tweetWebView.isLoading) {
        [self.tweetWebView stopLoading];
        [self stopIndicator];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)updateTitleWithTitle:(NSString *)title
{
	UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 160, 40.0)];
	lblTitle.numberOfLines = 2;
	lblTitle.textAlignment = UITextAlignmentCenter;
	lblTitle.font = [UIFont boldSystemFontOfSize:14.0];
	lblTitle.text = title;
	lblTitle.textColor = [UIColor whiteColor];
	lblTitle.backgroundColor = [UIColor clearColor];
	self.naviBarItem.titleView = lblTitle;
}

@end
