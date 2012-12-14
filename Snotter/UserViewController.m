//
//  UserViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/25.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "UserViewController.h"
#import "TwitterManager.h"
#import "UserHeaderView.h"
#import "TweetViewController.h"
#import "UserData.h"

@interface UserViewController ()

@property (nonatomic) TweetStatus *status;
@property (nonatomic) UserHeaderView *headerView;
@property (nonatomic) NSString *userId;

@end

@implementation UserViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (id)initWithTweetStatus:(TweetStatus *)status
{
    self = [super initWithNibName:@"TimeLineViewController" bundle:nil];
    if (self) {
        self.title = @"プロフィール";
        self.status = status;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"UserHeaderView" bundle:nil];
    self.headerView = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [self.headerView setProfile:self.status.user];
    
    [[TwitterManager sharedInstance] requestUserInfoWithUserId:self.status.user.user_id
                                                    ScreenName:self.status.user.screen_name
                                                       Handler:^(UserData *user, NSError *error) {
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if (user) {
                                                                   self.status.user = user;
                                                                   [self.headerView setProfile:user];
                                                               }
                                                           });
                                                       }];
    
    [self loadListTimeLineWithUserID:self.status.user.user_id SinceID:nil MaxID:nil];
}

- (void)viewDidUnload
{
    [self setHeaderView:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadListTimeLineWithUserID:(NSString *)userId SinceID:(NSString *)sinceId MaxID:(NSString *)maxId
{
    self.userId = userId;
    self.loadStatus = Loading;
    [[TwitterManager sharedInstance] requestUserStatusesWithUserID:userId SinceID:sinceId MaxID:maxId Handler:^(NSArray *statuses, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [super doneLoadingTimeLineDataWithStatuses:statuses SinceID:sinceId MaxID:maxId];
        });
    }];
}

- (void)loadNewTimeLineData
{
	[super loadNewTimeLineData];
    [self loadListTimeLineWithUserID:self.userId SinceID:self.sinceId MaxID:nil];
}

- (void)loadOldTimeLineData
{
    [super loadOldTimeLineData];
    [self loadListTimeLineWithUserID:self.userId SinceID:nil MaxID:self.maxId];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.headerView.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetViewController *ctl = [[TweetViewController alloc] initWithStatus:[self.statuses objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:ctl animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
