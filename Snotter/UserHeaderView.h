//
//  UserHeaderView.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/25.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Accounts/Accounts.h>
#import "UIAsyncImageView.h"
#import "UserData.h"

@interface UserHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIAsyncImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblScreenName;
@property (weak, nonatomic) IBOutlet UILabel *lblTweetCount;
@property (weak, nonatomic) IBOutlet UILabel *lblFollowersCount;
@property (weak, nonatomic) IBOutlet UILabel *lblFriendsCount;
@property (weak, nonatomic) IBOutlet UIButton *btnFollowStatus;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (void)setProfile:(UserData *)user;
- (IBAction)follow;

@end
