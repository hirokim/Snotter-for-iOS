//
//  UserViewController.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/25.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "TimeLineViewController.h"
#import "TweetStatus.h"

@interface UserViewController : TimeLineViewController

- (id)initWithTweetStatus:(TweetStatus *)status;
- (void)loadListTimeLineWithUserID:(NSString *)userId SinceID:(NSString *)sinceId MaxID:(NSString *)maxId;

@end
