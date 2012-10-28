//
//  TwitterManager.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "TwitterAccountsViewController.h"
#import "TweetStatus.h"

typedef void (^RequestHandler)(id);

@interface TwitterManager : NSObject <TwitterAccountsViewControllerDelegate>

@property (nonatomic) ACAccount *usingAccount;

+ (TwitterManager*)sharedInstance;

- (void)logInWithShowInView:(UIViewController *)viewController;

- (void)requestListsStatusesWithListID:(NSString *)listId SinceID:(NSString *)sinceId MaxID:(NSString *)maxId Handler:(RequestHandler)handler;

@end
