//
//  OfficialTweetListViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "OfficialTweetListViewController.h"
#import "TweetViewController.h"
#import "TwitterManager.h"

@interface OfficialTweetListViewController ()

@property (nonatomic) NADView *nadView;
@property (nonatomic) BOOL isNadViewVisible;

@end

@implementation OfficialTweetListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"関連ツイート";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = HEXCOLOR(NAVIGATION_BAR_COLOR);
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"設定"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(showSetting)];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.timeLineView = [[ListsViewController alloc] initWithDelegate:self];
    self.timeLineView.tableView.frame = self.view.frame;
    [self.view addSubview:self.timeLineView.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[GANTracker sharedTracker] trackPageview:OFFICIAL_TWEET_LIST withError:nil];
    
    if (!self.nadView) {
        
        self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0,
                                                                 self.view.frame.size.height,
                                                                 NAD_ADVIEW_SIZE_320x50.width,
                                                                 NAD_ADVIEW_SIZE_320x50.height)];
        
        [self.view addSubview:self.nadView];
        [self.nadView setNendID:NEND_ID spotID:SPOT_ID];
        [self.nadView setDelegate:self];
        [self.nadView load];
    }
    
    if (![TwitterManager sharedInstance].usingAccount) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"アカウント設定"
                                                        message:@"左上の設定からTwitterアカウントを\n設定してください。"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        
        self.timeLineView.tableView.hidden = YES;
        return;
    }
    
    self.timeLineView.tableView.hidden = NO;
    
    if (self.timeLineView.statuses.count == 0 && self.timeLineView.loadStatus != Loading) {
        [self.timeLineView loadListTimeLineWithListID:@"79026236" SinceID:nil MaxID:nil];
    }
    
    [self.nadView resume];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.nadView pause];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNadView:nil];
    [super viewDidUnload];
}

#pragma mark - ListsViewControllerDelegate

- (void)timeLineViewController:(TimeLineViewController *)controller selectedStatus:(TweetStatus *)status
{
    TweetViewController *ctl = [[TweetViewController alloc] initWithStatus:status];
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark -

- (void)showSetting
{
    [[TwitterManager sharedInstance] logInWithShowInView:self];
}

#pragma mark - NADView delegate

// NADViewのロードが成功した時に呼ばれる
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    NSLog(@"FirstView delegate nadViewDidFinishLoad");
}

// 広告受信成功
-(void)nadViewDidReceiveAd:(NADView *)adView
{
    NSLog(@"FirstView delegate nadViewDidReceiveAd");
    
    if (!self.isNadViewVisible) {
        
        self.isNadViewVisible = YES;
        [self nadViewFrameOffset:self.nadView.frame.size.height * -1];
    }
}

// 広告受信エラー
-(void)nadViewDidFailToReceiveAd:(NADView *)adView
{
    NSLog(@"FirstView delegate nadViewDidFailToReceiveAd");
    
    if (self.isNadViewVisible) {
        
        self.isNadViewVisible = NO;
        [self nadViewFrameOffset:self.nadView.frame.size.height];
    }
}

- (void)nadViewFrameOffset:(float)height
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.timeLineView.tableView.frame = CGRectMake(self.timeLineView.tableView.frame.origin.x,
                                                       self.timeLineView.tableView.frame.origin.y,
                                                       self.timeLineView.tableView.frame.size.width,
                                                       self.timeLineView.tableView.frame.size.height
                                                       + height);
        
        self.nadView.frame = CGRectOffset(self.nadView.frame,
                                          0,
                                          height);
    } completion:nil];
}

@end
