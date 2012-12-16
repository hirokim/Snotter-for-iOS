//
//  AreaListViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "AreaListViewController.h"
#import "TwitterManager.h"
#import "Gelande.h"
#import "GelandeListViewController.h"
#import "GelandeTweetViewController.h"
#import "SettingViewController.h"
#import "GelandeManager.h"

@interface AreaListViewController ()

@property (nonatomic) NSMutableArray *areaList;
@property (nonatomic) NADView *nadView;
@property (nonatomic) BOOL isNadViewVisible;

@property (nonatomic) NSMutableArray *filteredListContent;
@property (nonatomic) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

@end

@implementation AreaListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"スキー場";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = HEXCOLOR(NAVIGATION_BAR_COLOR);
    self.searchDisplayController.searchBar.tintColor = HEXCOLOR(NAVIGATION_BAR_COLOR);
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"設定"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showSetting)];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.areaList = [[GelandeManager sharedInstance] areaList];
    
    self.filteredListContent = [NSMutableArray arrayWithCapacity:0];
    
    // 検索条件が保存されてたらセット
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[GANTracker sharedTracker] trackPageview:AREA_LIST withError:nil];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    if (!self.nadView) {
        
        self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0,
                                                                 self.view.frame.size.height,
                                                                 NAD_ADVIEW_SIZE_320x50.width,
                                                                 NAD_ADVIEW_SIZE_320x50.height)];
        
        [self.view addSubview:self.nadView];
        [self.nadView setNendID:NEND_ID spotID:SPOT_ID];
        [self.nadView setDelegate:self];
        [self.nadView setRootViewController:self];
        [self.nadView load];
    }
    
    [self.nadView resume];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.nadView pause];
    
    // 検索条件を保存
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // 検索時
        return 1;
    }
    
    return [self.areaList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // 検索時
        return self.filteredListContent.count;
    }
    
    NSArray *gelandeList = [self.areaList objectAtIndex:section];
    return [gelandeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Gelande *gelande;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // 検索時
        gelande = [self.filteredListContent objectAtIndex:indexPath.row];
        cell.textLabel.text = gelande.name;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    }
    else {
        
        gelande = [[[self.areaList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] lastObject];
        cell.textLabel.text = gelande.smallAreaName;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // 検索時
        return nil;
    }
    
    Gelande *gelande = [[[self.areaList objectAtIndex:section] lastObject] lastObject];
	
	UIView *v = [[UIView alloc] init];
	UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                             0.0f,
                                                             self.tableView.frame.size.width,
                                                             22.0f)];
	lbl.backgroundColor = HEXCOLOR(NAVIGATION_BAR_COLOR);
	lbl.textColor = [UIColor whiteColor];
	lbl.font = [UIFont boldSystemFontOfSize:14.0];
	lbl.text = gelande.largeAreaName;
	
	[v addSubview:lbl];
	
	return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // 検索時
        return 0;
    }
    
    return 22.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // 検索時
        Gelande *gelande = [self.filteredListContent objectAtIndex:indexPath.row];
        
        [[GANTracker sharedTracker] trackEvent:AREA_LIST action:GELANDE_SELECTED label:gelande.name value:-1 withError:nil];
        
        GelandeTweetViewController *ctl = [[GelandeTweetViewController alloc] initWithGelande:gelande];
        [self.navigationController pushViewController:ctl animated:YES];
        
        return;
    }
    
    NSArray *gelandeList = [[self.areaList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    Gelande *gelande = [gelandeList lastObject];
    
    [[GANTracker sharedTracker] trackEvent:AREA_LIST action:AREA_SELECTED label:gelande.smallAreaName value:-1 withError:nil];
    
    GelandeListViewController *ctl = [[GelandeListViewController alloc] initWithGelandeList:gelandeList];
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark - UISearchDisplayController delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.filteredListContent removeAllObjects];
    
    for (NSArray *area in self.areaList) {
        for (NSArray *gelandeList in area) {
            for (Gelande *gelande in gelandeList) {
                
                NSRange match = [gelande.name rangeOfString:searchString];
                if (match.location != NSNotFound) {
                    
                    [self.filteredListContent addObject:gelande];
                }
            }
        }
    }
    
    return YES;
}

#pragma mark -

- (void)showSetting
{
    SettingViewController *ctl = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:ctl];
    [self presentModalViewController:navi animated:YES];
}

- (void)viewDidUnload {
    [self setAreaList:nil];
    [self setNadView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - NADView delegate

// NADViewのロードが成功した時に呼ばれる
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    DNSLog(@"AreaListViewController delegate nadViewDidFinishLoad");
}

// 広告受信成功
-(void)nadViewDidReceiveAd:(NADView *)adView
{
    DNSLog(@"AreaListViewController delegate nadViewDidReceiveAd");
    
    if (!self.isNadViewVisible) {
        
        self.isNadViewVisible = YES;
        [self nadViewFrameOffset:self.nadView.frame.size.height * -1];
    }
}

// 広告受信エラー
-(void)nadViewDidFailToReceiveAd:(NADView *)adView
{
    DNSLog(@"AreaListViewController delegate nadViewDidFailToReceiveAd");
    
    if (self.isNadViewVisible) {
        
        self.isNadViewVisible = NO;
        [self nadViewFrameOffset:self.nadView.frame.size.height];
    }
}

- (void)nadViewFrameOffset:(float)height
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.nadView.frame = CGRectOffset(self.nadView.frame,
                                          0,
                                          height);
    } completion:^(BOOL finished) {
        
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                          self.tableView.frame.origin.y,
                                          self.tableView.frame.size.width,
                                          self.tableView.frame.size.height
                                          + height);
    }];
}

@end
