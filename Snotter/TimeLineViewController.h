//
//  TimeLineViewController.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EGORefreshTableHeaderView.h"

enum LoadStatus
{
    Loading     = 0,
    Loaded      = 1,
    LoadFailed  = 2
};

@interface TimeLineViewController : UITableViewController <EGORefreshTableHeaderDelegate>

@property (weak, nonatomic) IBOutlet UIView *TweetFooterView;
@property (weak, nonatomic) IBOutlet UIButton *BtnTweetFooter;
@property (nonatomic) NSMutableArray *statuses;
@property (nonatomic) enum LoadStatus loadStatus;
@property (nonatomic) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic) NSDate *refreshDate;
@property (nonatomic) NSString *sinceId;
@property (nonatomic) NSString *maxId;

- (void)loadOldTimeLineData;
- (void)loadNewTimeLineData;
- (void)doneLoadingNewTimeLineDataWithStatuses:(NSArray *)statuses;
- (void)doneLoadingOldTimeLineDataWithStatuses:(NSArray *)statuses;
- (void)doneLoadingTimeLineData;

@end
