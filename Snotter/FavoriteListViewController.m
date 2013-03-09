//
//  FavoriteListViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "FavoriteListViewController.h"
#import "Gelande.h"
#import "GelandeTweetViewController.h"
#import "TwitterManager.h"
#import "SettingViewController.h"
#import "GelandeManager.h"
#import "appC.h"

@interface FavoriteListViewController ()

@property (nonatomic) NSMutableArray *favoriteList;

@property (nonatomic) NADView *nadView;
@property (nonatomic) BOOL isNadViewVisible;

@end

@implementation FavoriteListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"お気に入り";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"設定"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(showSetting)];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    
    appCMarqueeView *appCView = [[appCMarqueeView alloc] initWithTopWithViewController:self];
    [self.view addSubview:appCView];
    
    CGRect rect = self.view.frame;
    rect.origin.y = rect.origin.y + APPC_MARQUEE_HEIGHT;
    rect.size.height = rect.size.height - APPC_MARQUEE_HEIGHT;
    self.tableView.frame = rect;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[GANTracker sharedTracker] trackPageview:FAVORITE_LIST withError:nil];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *data = [ud objectForKey:FAVORITE_KEY];
    self.favoriteList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self.tableView reloadData];
    
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
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    // UITableView の setEditing:animated: メソッドを呼ぶ。
    [self.tableView setEditing:editing animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNadView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.favoriteList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Gelande *gelande = [self.favoriteList objectAtIndex:indexPath.row];
    cell.textLabel.text = gelande.name;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// 編集
	[self.favoriteList removeObjectAtIndex:indexPath.row];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSData* classDataSave = [NSKeyedArchiver archivedDataWithRootObject:self.favoriteList];
    [ud setObject:classDataSave forKey:FAVORITE_KEY];
    [ud synchronize];
    
	// 見た目的にも削除
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
					 withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Gelande *gelande = [self.favoriteList objectAtIndex:indexPath.row];
    gelande = [[GelandeManager sharedInstance] gelandeWithHashTag:gelande.hashTag];
    
    [[GANTracker sharedTracker] trackEvent:FAVORITE_LIST action:GELANDE_SELECTED label:gelande.name value:-1 withError:nil];
    
    GelandeTweetViewController *ctl = [[GelandeTweetViewController alloc] initWithGelande:gelande];
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark -

- (void)showSetting
{
    SettingViewController *ctl = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:ctl];
    [self presentModalViewController:navi animated:YES];
}

#pragma mark - NADView delegate

// NADViewのロードが成功した時に呼ばれる
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    DNSLog(@"FavoriteListViewController delegate nadViewDidFinishLoad");
}

// 広告受信成功
-(void)nadViewDidReceiveAd:(NADView *)adView
{
    DNSLog(@"FavoriteListViewController delegate nadViewDidReceiveAd");
    
    if (!self.isNadViewVisible) {
        
        self.isNadViewVisible = YES;
        [self nadViewFrameOffset:self.nadView.frame.size.height * -1];
    }
}

// 広告受信エラー
-(void)nadViewDidFailToReceiveAd:(NADView *)adView
{
    DNSLog(@"FavoriteListViewController delegate nadViewDidFailToReceiveAd");
    
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
