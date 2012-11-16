//
//  TweetStatus.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetStatus : NSObject

@property (nonatomic) NSString *status_id;
@property (nonatomic) NSString *user_id;
@property (nonatomic) NSString *screen_name;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *description;
@property (nonatomic) NSString *profile_image_url_https;
@property (nonatomic) NSString *url;
@property (nonatomic) unsigned long statuses_count;
@property (nonatomic) int followers_count;
@property (nonatomic) int friends_count;
@property (nonatomic) NSString *text;
@property (nonatomic) NSDate *created_at;

@end
