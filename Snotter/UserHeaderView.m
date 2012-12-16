//
//  UserHeaderView.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/25.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "UserHeaderView.h"
#import "TwitterManager.h"

@interface UserHeaderView()

@property (nonatomic) UserData *user;
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

- (void)awakeFromNib
{
    self.imgProfile.layer.cornerRadius = 5;
    self.imgProfile.clipsToBounds = true;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect frame = CGRectMake(rect.origin.x,
                              rect.origin.y,
                              rect.size.width,
                              rect.size.height - 1);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:0];
    CGContextAddPath(context, path.CGPath);
    
    CGContextSetShadow(context, CGSizeMake(0.0f, 1.0f), 1.0f);
    [path fill];
    
    [path addClip];
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {
        0.647f, 0.831f, 0.980f, 1.0f,     // R, G, B, Alpha64.7, 83.1, 98
        0.455f, 0.741f, 0.973f, 1.0f
    };
    CGFloat locations[] = { 0.0f, 1.0f };
    
    size_t count = sizeof(components)/ (sizeof(CGFloat)* 4);
    
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = frame.origin;
    endPoint.y = frame.origin.y + frame.size.height;
    
    CGGradientRef gradientRef =
    CGGradientCreateWithColorComponents(colorSpaceRef, components, locations, count);
    
    CGContextDrawLinearGradient(context,
                                gradientRef,
                                startPoint,
                                endPoint,
                                kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    CGContextRestoreGState(context);
}


- (void)setProfile:(UserData *)user
{
    self.user = user;
    self.lblUserName.text = user.name;
    self.lblScreenName.text = [NSString stringWithFormat:@"@%@", user.screen_name];
    self.lblTweetCount.text = [NSString stringWithFormat:@"%ld", user.statuses_count];
    self.lblFriendsCount.text = [NSString stringWithFormat:@"%d", user.friends_count];
    self.lblFollowersCount.text = [NSString stringWithFormat:@"%d", user.followers_count];
    [self.imgProfile loadImageWithURL:user.profile_image_url_https];
    
    self.isFollow = user.following;
    
    if (self.isFollow) {
        [self.btnFollowStatus setTitle:@"フォロー中" forState:UIControlStateNormal];
        [self.btnFollowStatus setTitle:@"フォロー中" forState:UIControlStateSelected];
    }
    else {
        [self.btnFollowStatus setTitle:@"フォローする" forState:UIControlStateNormal];
        [self.btnFollowStatus setTitle:@"フォローする" forState:UIControlStateSelected];
    }

    self.indicator.hidden = YES;
    [self.indicator stopAnimating];
    
    // 自分のプロフィール以外ならボタン表示
    NSString *userName = [[[TwitterManager sharedInstance] usingAccount] username];
    if (![userName isEqualToString:user.screen_name]) {
        
        self.btnFollowStatus.hidden = NO;
    }
}

- (IBAction)follow
{
    if (self.isFollow) {
        // フォローをはずす
        [[TwitterManager sharedInstance] requestFriendshipsDestroyWithUserId:self.user.user_id
                                                                  ScreenName:self.user.screen_name];
        self.isFollow = NO;
        [self.btnFollowStatus setTitle:@"フォローする" forState:UIControlStateNormal];
        [self.btnFollowStatus setTitle:@"フォローする" forState:UIControlStateSelected];
    }
    else {
        // フォローする
        [[TwitterManager sharedInstance] requestFriendshipsCreateWithUserId:self.user.user_id
                                                                  ScreenName:self.user.screen_name];
        self.isFollow = YES;
        [self.btnFollowStatus setTitle:@"フォロー中" forState:UIControlStateNormal];
        [self.btnFollowStatus setTitle:@"フォロー中" forState:UIControlStateSelected];
    }
}

@end
