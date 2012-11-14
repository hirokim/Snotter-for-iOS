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

@interface FavoriteListViewController ()

@property (nonatomic) NSMutableArray *favoriteList;

@property (nonatomic) NADView *nadView;
@property (nonatomic) BOOL *isNadViewVisible;

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
    
    self.navigationController.navigationBar.tintColor = HEXCOLOR(NAVIGATION_BAR_COLOR);
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"設定"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(showSetting)];
    self.navigationItem.leftBarButtonItem = btn;
    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    
    self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0,
                                                             self.view.frame.size.height,
                                                             NAD_ADVIEW_SIZE_320x50.width,
                                                             NAD_ADVIEW_SIZE_320x50.height)];
    [self.view addSubview:self.nadView];
    [self.nadView setNendID:@"42ab03e7c858d17ad8dfceccfed97c8038a9e12e" spotID:@"16073"];
    [self.nadView setDelegate:self];
    [self.nadView load];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[GANTracker sharedTracker] trackPageview:FAVORITE_LIST withError:nil];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *data = [ud objectForKey:FAVORITE_KEY];
    self.favoriteList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self.tableView reloadData];
    
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
    
    [[GANTracker sharedTracker] trackEvent:@"/お気に入りリスト" action:@"お気に入り選択" label:gelande.name value:-1 withError:nil];
    
    GelandeTweetViewController *ctl = [[GelandeTweetViewController alloc] initWithGelande:gelande];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)viewDidUnload {
    [self setNadView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
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
        
        [UIView transitionWithView:self.view
                          duration:1.0
                           options:UIViewAnimationCurveEaseOut
                        animations:^{
                            
                            [self nadViewFrameOffset:self.nadView.frame.size.height * -1];
                        }
                        completion:nil];
    }
}

// 広告受信エラー
-(void)nadViewDidFailToReceiveAd:(NADView *)adView
{
    NSLog(@"FirstView delegate nadViewDidFailToReceiveAd");
    
    if (self.isNadViewVisible) {
        
        [UIView transitionWithView:self.view
                          duration:1.0
                           options:UIViewAnimationCurveEaseOut
                        animations:^{
                            
                            [self nadViewFrameOffset:self.nadView.frame.size.height];
                        }
                        completion:nil];
    }
}

- (void)nadViewFrameOffset:(float)height
{
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableView.frame.origin.y,
                                      self.tableView.frame.size.width,
                                      self.tableView.frame.size.height
                                      + height);
    
    self.nadView.frame = CGRectOffset(self.nadView.frame,
                                      0,
                                      height);
}

@end
