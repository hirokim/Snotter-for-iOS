//
//  TweetViewController.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/28.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIAsyncImageView.h"
#import "TweetStatus.h"

@interface TweetViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UITableView *tweetTableView;
@property (weak, nonatomic) IBOutlet UIAsyncImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblScreenName;

- (id)initWithStatus:(TweetStatus *)status;

@end
