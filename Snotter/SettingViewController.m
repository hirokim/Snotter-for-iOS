//
//  SettingViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "SettingViewController.h"
#import "TwitterManager.h"
#import "appC.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"設定";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"閉じる"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(close)];
    self.navigationItem.leftBarButtonItem = btn;
    
    [[GANTracker sharedTracker] trackPageview:SETTING_VIEW withError:nil];
    
    appCSimpleView *appCView = [[appCSimpleView alloc] initWithBottomWithViewController:self];
    [self.view addSubview:appCView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowCount = 0;
    switch (section) {
        case 0:
            rowCount = 1;
            break;
            
        case 1:
            rowCount = 1;
            break;
            
        case 2:
            rowCount = 1;
            break;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    
    switch (indexPath.section) {
            
        case 0: {
            NSString *userName = [[[TwitterManager sharedInstance] usingAccount] username];
            if ([userName length] == 0) {
                userName = @"選択してください。";
            }
            else {
                userName = [NSString stringWithFormat:@"@%@", userName];
            }
            cell.textLabel.text = userName;
            break;
        }
        case 1: {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"評価をみる・評価をする";
            }
            break;
        }
        case 2: {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = @"作者の他のアプリ";
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = @"今日の無料アプリ";
            }
            break;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleStr = @"";
    switch (section) {
            
        case 0:
            titleStr = @"Twitterアカウント";
            break;
            
        case 1:
            titleStr = @"レビュー";
            break;
            
        case 2:
            titleStr = @"おすすめアプリ";
            break;
    }
    
    return titleStr;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    switch (indexPath.section) {
            
        case 0: {
            [[TwitterManager sharedInstance] logInWithShowInView:self];
            break;
        }
        case 1: {
            if (indexPath.row == 0) {
                NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=422599580&mt=8&type=Purple+Software"];
                [[UIApplication sharedApplication] openURL:url];
            }
            break;
        }
        case 2: {
            
            if (indexPath.row == 0) {
                NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.com/apps/hirokim"];
                [[UIApplication sharedApplication] openURL:url];
            }
            break;
        }
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

#pragma mark -

- (void)close
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
