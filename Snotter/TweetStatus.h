//
//  TweetStatus.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserData.h"

@interface TweetStatus : NSObject

@property (nonatomic) UserData *user;

@property (nonatomic) NSString  *status_id;
@property (nonatomic) NSString  *text;
@property (nonatomic) NSDate    *created_at;

@end
