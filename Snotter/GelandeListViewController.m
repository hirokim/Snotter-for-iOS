//
//  GelandeListViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "GelandeListViewController.h"
#import "Gelande.h"
#import "GelandeTweetViewController.h"
#import "GelandeMapViewController.h"

@interface GelandeListViewController ()

@property (nonatomic) NSArray *gelandeList;

@property (nonatomic) NADView *nadView;
@property (nonatomic) BOOL isNadViewVisible;

@end

@implementation GelandeListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithGelandeList:(NSArray *)gelandeList
{
    self = [super initWithNibName:@"GelandeListViewController" bundle:nil];
    if (self) {
        self.gelandeList = gelandeList;
        
        Gelande *g = [gelandeList lastObject];
        self.title = g.largeAreaName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateTitleWithTitle:self.title];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(showMap)];
    self.navigationItem.rightBarButtonItem = btn;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[GANTracker sharedTracker] trackPageview:GELANDE_LIST withError:nil];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
    return [self.gelandeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Gelande *gelande = [self.gelandeList objectAtIndex:indexPath.row];
    cell.textLabel.text = gelande.name;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Gelande *gelande = [self.gelandeList objectAtIndex:indexPath.row];
    
    [[GANTracker sharedTracker] trackEvent:GELANDE_LIST action:GELANDE_SELECTED label:gelande.name value:-1 withError:nil];
    
    GelandeTweetViewController *ctl = [[GelandeTweetViewController alloc] initWithGelande:gelande];
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark -

- (void)showMap
{
    GelandeMapViewController *ctl = [[GelandeMapViewController alloc] initWithGelandeList:self.gelandeList];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)updateTitleWithTitle:(NSString *)title
{
	UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 160, 40.0)];
	lblTitle.numberOfLines = 2;
	lblTitle.textAlignment = UITextAlignmentCenter;
	lblTitle.font = [UIFont boldSystemFontOfSize:14.0];
	lblTitle.text = title;
	lblTitle.textColor = [UIColor whiteColor];
	lblTitle.backgroundColor = [UIColor clearColor];
	self.navigationItem.titleView = lblTitle;
}

#pragma mark - NADView delegate

// NADViewのロードが成功した時に呼ばれる
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    DNSLog(@"GelandeListViewController delegate nadViewDidFinishLoad");
}

// 広告受信成功
-(void)nadViewDidReceiveAd:(NADView *)adView
{
    DNSLog(@"GelandeListViewController delegate nadViewDidReceiveAd");
    
    if (!self.isNadViewVisible) {
        
        self.isNadViewVisible = YES;
        [self nadViewFrameOffset:self.nadView.frame.size.height * -1];
    }
}

// 広告受信エラー
-(void)nadViewDidFailToReceiveAd:(NADView *)adView
{
    DNSLog(@"GelandeListViewController delegate nadViewDidFailToReceiveAd");
    
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
