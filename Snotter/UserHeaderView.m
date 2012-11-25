//
//  UserHeaderView.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/25.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "UserHeaderView.h"

@interface UserHeaderView()

@property (nonatomic) BOOL isFollow;

@end

@implementation UserHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setProfile:(UserData *)user
{
    self.lblUserName.text = user.name;
    self.lblScreenName.text = [NSString stringWithFormat:@"@%@", user.screen_name];
    self.lblTweetCount.text = [NSString stringWithFormat:@"%ld", user.statuses_count];
    self.lblFriendsCount.text = [NSString stringWithFormat:@"%d", user.friends_count];
    self.lblFollowersCount.text = [NSString stringWithFormat:@"%d", user.followers_count];
    [self.imgProfile loadImageWithURL:user.profile_image_url_https];
    
    self.btnFollowStatus.selected = user.following;
}

- (IBAction)follow
{
    
}

@end
