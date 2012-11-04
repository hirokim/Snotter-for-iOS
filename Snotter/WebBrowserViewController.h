//
//  WebBrowserViewController.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebBrowserViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *tweetWebView;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviBarItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

- (id)initWithURL:(NSString *)urlString;

- (IBAction)openSafari:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)forward:(id)sender;
- (IBAction)refresh:(id)sender;

@end
