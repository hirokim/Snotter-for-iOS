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
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *data = [ud objectForKey:FAVORITE_KEY];
    self.favoriteList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self.tableView reloadData];
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
    GelandeTweetViewController *ctl = [[GelandeTweetViewController alloc] initWithGelande:[self.favoriteList objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - 

- (void)showSetting
{
    [[TwitterManager sharedInstance] logInWithShowInView:self];
}

@end
