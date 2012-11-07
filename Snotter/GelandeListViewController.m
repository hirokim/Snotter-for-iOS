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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
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
    
    [[GANTracker sharedTracker] trackEvent:@"/ゲレンデリスト" action:@"ゲレンデ選択" label:gelande.name value:-1 withError:nil];
    
    GelandeTweetViewController *ctl = [[GelandeTweetViewController alloc] initWithGelande:gelande];
    [self.navigationController pushViewController:ctl animated:YES];
}

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

@end
