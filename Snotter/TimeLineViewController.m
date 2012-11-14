//
//  TimeLineViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "TimeLineViewController.h"
#import "TwitterManager.h"
#import "TweetCell.h"
#import "UIAsyncImageView.h"
#import "TweetViewController.h"

@interface TimeLineViewController ()

@end

@implementation TimeLineViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statuses = [NSMutableArray arrayWithCapacity:0];
    
    // ヘッダー設定
    EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    view.delegate = self;
    [self.tableView addSubview:view];
    self.refreshHeaderView = view;
    
    // フッター設定
    self.tableView.tableFooterView = self.TweetFooterView;
    [self.BtnTweetFooter addTarget:self
                            action:@selector(loadMoreTweet)
                  forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTweetFooterView:nil];
    [self setBtnTweetFooter:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // つぶやきセル + 読み込み中セル
    return [self.statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // つぶやきセル
    static NSString *TweetCellIdentifier = @"TweetCell";
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:TweetCellIdentifier];
    if (cell == nil) {
        
        UINib *nib = [UINib nibWithNibName:TweetCellIdentifier bundle:nil];
        cell = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    
    TweetStatus *status = [self.statuses objectAtIndex:indexPath.row];
    cell.userName.text = status.name;
    cell.tweetText.text = status.text;
    cell.tweetDate.text = [self dateToString:status.date];
    cell.profileImage.layer.cornerRadius = 5;
    cell.profileImage.clipsToBounds = true;
    cell.profileImage.image = nil;
    [cell.profileImage loadImageWithURL:status.profile_image_url_https];
    
    // つぶやきラベルの高さ設定
    CGSize maxBounds = CGSizeMake(cell.tweetText.bounds.size.width, 500);
    CGSize detailSize = [cell.tweetText.text sizeWithFont:cell.tweetText.font
                                        constrainedToSize:maxBounds
                                            lineBreakMode:UILineBreakModeWordWrap];
    cell.tweetText.frame = CGRectMake(cell.tweetText.frame.origin.x,
                                      cell.tweetText.frame.origin.y,
                                      cell.tweetText.frame.size.width,
                                      detailSize.height);
    
    // 先頭、最後尾のIDを保持
    if (indexPath.row == 0) {
        self.sinceId = status.status_id;
    }
    else if (indexPath.row == [self.statuses count] - 1) {
        self.maxId = status.status_id;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell *cell = (TweetCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    float newHeight = cell.userName.frame.size.height + cell.tweetText.frame.size.height + 5;
    
    if (newHeight > cell.bounds.size.height) {
        return newHeight;
    }
    return cell.bounds.size.height;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(timeLineViewController:selectedStatus:)]) {
        
        [self.delegate timeLineViewController:self selectedStatus:[self.statuses objectAtIndex:indexPath.row]];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 

- (NSString *)dateToString:(NSDate *)date
{
    NSCalendarUnit unit =   NSYearCalendarUnit |
                            NSMonthCalendarUnit |
                            NSDayCalendarUnit |
                            NSHourCalendarUnit |
                            NSMinuteCalendarUnit;
    
    NSDateComponents* tweetDateComponents = [[NSCalendar currentCalendar] components:unit fromDate:date];
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    // 時間をのぞいた日付で比較する
	NSString *tmpDate = nil;
    tmpDate = [dateFormatter stringFromDate:date];
	NSDate *tweetDate = [dateFormatter dateFromString:tmpDate];
    tmpDate = [dateFormatter stringFromDate:[NSDate date]];
	NSDate *nowDate = [dateFormatter dateFromString:tmpDate];
    
    NSDateComponents *compare = [[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                                fromDate:tweetDate
                                                                  toDate:nowDate
                                                                 options:0];
    if (compare.day == 0) {
        
        return [NSString stringWithFormat:@"%d:%02d",
                tweetDateComponents.hour,
                tweetDateComponents.minute];
    }
    else if (compare.day == 1) {
        
        return [NSString stringWithFormat:@"昨日 %d:%02d",
                tweetDateComponents.hour,
                tweetDateComponents.minute];
    }
    else {
        
        return [NSString stringWithFormat:@"%d/%d %d:%02d",
                tweetDateComponents.month,
                tweetDateComponents.day,
                tweetDateComponents.hour,
                tweetDateComponents.minute];
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)loadOldTimeLineData
{
    self.loadStatus = Loading;
    [self.BtnTweetFooter setTitle:@"読み込み中..." forState:UIControlStateNormal];
}

- (void)loadNewTimeLineData
{
	self.loadStatus = Loading;
    [self.BtnTweetFooter setTitle:@"読み込み中..." forState:UIControlStateNormal];
}

- (void)doneLoadingTimeLineData
{
	self.loadStatus = Loaded;
    [self.BtnTweetFooter setTitle:@"もっと見る" forState:UIControlStateNormal];
    self.refreshDate = [NSDate date];
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)doneLoadingNewTimeLineDataWithStatuses:(NSArray *)statuses
{
    NSMutableArray *insertStatuses = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:0];
    
    int rowIndex = 0;
    for (TweetStatus *status in statuses) {
        
        if ([self.sinceId isEqualToString:status.status_id]) {
            break;
        }
        
        [insertStatuses addObject:status];
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:rowIndex inSection:0]];
        rowIndex++;
    }
    
    if (insertStatuses.count > 0) {
        
        [self.statuses insertObjects:insertStatuses
                           atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, insertStatuses.count)]];
        [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
    }
    
    [self doneLoadingTimeLineData];
}

- (void)doneLoadingOldTimeLineDataWithStatuses:(NSArray *)statuses
{
    NSMutableArray *addStatuses = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *addIndexPaths = [NSMutableArray arrayWithCapacity:0];
    int rowIndex = self.statuses.count;
    
    for (TweetStatus *status in statuses) {
        
        if ([self.maxId isEqualToString:status.status_id]) {
            continue;
        }
        
        [addStatuses addObject:status];
        [addIndexPaths addObject:[NSIndexPath indexPathForItem:rowIndex inSection:0]];
        rowIndex++;
    }
    
    if (addStatuses.count > 0) {
        
        [self.statuses addObjectsFromArray:addStatuses];
        [self.tableView insertRowsAtIndexPaths:addIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [self doneLoadingTimeLineData];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if (self.loadStatus != Loading) {
        [self loadNewTimeLineData];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return (self.loadStatus == Loading);
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return self.refreshDate;
}

#pragma mark -
- (void)loadMoreTweet
{
    if (self.loadStatus != Loading) {
        [self loadOldTimeLineData];
    }
}

@end
