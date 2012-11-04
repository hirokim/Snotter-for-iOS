//
//  SnotterTweetListViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "SnotterTweetListViewController.h"
#import "TweetViewController.h"
#import "TwitterManager.h"

@interface SnotterTweetListViewController ()

@end

@implementation SnotterTweetListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"ｽﾉったーﾂｲｰﾄ";
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
    
    self.timeLineView = [[SearchViewController alloc] initWithDelegate:self];
    self.timeLineView.tableView.frame = self.view.frame;
    [self.view addSubview:self.timeLineView.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![TwitterManager sharedInstance].usingAccount) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"Twitterアカウントが設定されていません。"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    if (self.timeLineView.statuses.count == 0) {
        [self.timeLineView loadSearchTimeLineWithKeywords:@[@"#_snotter"] SinceID:nil MaxID:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)timeLineViewController:(TimeLineViewController *)controller selectedStatus:(TweetStatus *)status
{
    TweetViewController *ctl = [[TweetViewController alloc] initWithStatus:status];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)showSetting
{
    [[TwitterManager sharedInstance] logInWithShowInView:self];
}

@end
