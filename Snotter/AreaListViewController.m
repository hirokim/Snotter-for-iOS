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
    
    [self createAllGelandeList];
    
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
    
    for (NSArray *arealist in self.areaList) {
        for (NSArray *gelandeList in arealist) {
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
    [[TwitterManager sharedInstance] logInWithShowInView:self];
}

- (void)createAllGelandeList
{
    self.areaList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSMutableArray *gelandeList = nil;
    NSString *largeAreaName = nil;
    
    largeAreaName = @"北海道";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"douhoku" LargeAreaName:largeAreaName SmallAreaName:@"道北"]];
	[gelandeList addObject:[self loadGelandeCSV:@"doutou" LargeAreaName:largeAreaName SmallAreaName:@"道東"]];
	[gelandeList addObject:[self loadGelandeCSV:@"douou" LargeAreaName:largeAreaName SmallAreaName:@"道央"]];
    [self.areaList addObject:gelandeList];
    
    
    largeAreaName = @"東北";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"aomori" LargeAreaName:largeAreaName SmallAreaName:@"青森"]];
	[gelandeList addObject:[self loadGelandeCSV:@"iwate" LargeAreaName:largeAreaName SmallAreaName:@"岩手"]];
	[gelandeList addObject:[self loadGelandeCSV:@"akita" LargeAreaName:largeAreaName SmallAreaName:@"秋田"]];
	[gelandeList addObject:[self loadGelandeCSV:@"miyagi" LargeAreaName:largeAreaName SmallAreaName:@"宮城"]];
	[gelandeList addObject:[self loadGelandeCSV:@"yamagata" LargeAreaName:largeAreaName SmallAreaName:@"山形"]];
	[gelandeList addObject:[self loadGelandeCSV:@"hukushima" LargeAreaName:largeAreaName SmallAreaName:@"福島"]];
    [self.areaList addObject:gelandeList];
    
    
    largeAreaName = @"関東甲信越";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"nasu" LargeAreaName:largeAreaName SmallAreaName:@"那須・塩原"]];
	[gelandeList addObject:[self loadGelandeCSV:@"numata" LargeAreaName:largeAreaName SmallAreaName:@"沼田・水上"]];
	[gelandeList addObject:[self loadGelandeCSV:@"kusatsu" LargeAreaName:largeAreaName SmallAreaName:@"草津・嬬恋・万座"]];
	[gelandeList addObject:[self loadGelandeCSV:@"kanagawa" LargeAreaName:largeAreaName SmallAreaName:@"神奈川・埼玉"]];
	[gelandeList addObject:[self loadGelandeCSV:@"jouetsu" LargeAreaName:largeAreaName SmallAreaName:@"上越・湯沢"]];
	[gelandeList addObject:[self loadGelandeCSV:@"myoukou" LargeAreaName:largeAreaName SmallAreaName:@"妙高"]];
	[gelandeList addObject:[self loadGelandeCSV:@"madarao" LargeAreaName:largeAreaName SmallAreaName:@"斑尾・野沢・飯綱"]];
	[gelandeList addObject:[self loadGelandeCSV:@"fuji" LargeAreaName:largeAreaName SmallAreaName:@"富士・八ヶ岳・車山"]];
	[gelandeList addObject:[self loadGelandeCSV:@"karuizawa" LargeAreaName:largeAreaName SmallAreaName:@"軽井沢・菅平"]];
	[gelandeList addObject:[self loadGelandeCSV:@"shigakougen" LargeAreaName:largeAreaName SmallAreaName:@"志賀高原・北志賀"]];
	[gelandeList addObject:[self loadGelandeCSV:@"hakuba" LargeAreaName:largeAreaName SmallAreaName:@"白馬"]];
    [self.areaList addObject:gelandeList];
    
    
    largeAreaName = @"北陸";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"toyama" LargeAreaName:largeAreaName SmallAreaName:@"富山"]];
	[gelandeList addObject:[self loadGelandeCSV:@"ishikawa" LargeAreaName:largeAreaName SmallAreaName:@"石川"]];
	[gelandeList addObject:[self loadGelandeCSV:@"hukui" LargeAreaName:largeAreaName SmallAreaName:@"福井"]];
    [self.areaList addObject:gelandeList];
    
    largeAreaName = @"中京";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"hida" LargeAreaName:largeAreaName SmallAreaName:@"御岳・飛騨・奥美濃"]];
    [self.areaList addObject:gelandeList];
    
    
    largeAreaName = @"関西";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"shiga" LargeAreaName:largeAreaName SmallAreaName:@"滋賀"]];
	[gelandeList addObject:[self loadGelandeCSV:@"hyougo" LargeAreaName:largeAreaName SmallAreaName:@"兵庫"]];
	[gelandeList addObject:[self loadGelandeCSV:@"kyoto" LargeAreaName:largeAreaName SmallAreaName:@"京都・三重"]];
    [self.areaList addObject:gelandeList];
    
    
    largeAreaName = @"中国・四国・九州";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"tottori" LargeAreaName:largeAreaName SmallAreaName:@"鳥取・島根"]];
	[gelandeList addObject:[self loadGelandeCSV:@"okayama" LargeAreaName:largeAreaName SmallAreaName:@"岡山・広島・山口"]];
	[gelandeList addObject:[self loadGelandeCSV:@"shikoku" LargeAreaName:largeAreaName SmallAreaName:@"四国"]];
	[gelandeList addObject:[self loadGelandeCSV:@"kyushu" LargeAreaName:largeAreaName SmallAreaName:@"九州"]];
    [self.areaList addObject:gelandeList];
}

- (NSMutableArray *)loadGelandeCSV:(NSString *)fileName LargeAreaName:(NSString *)largeName SmallAreaName:(NSString *)smallName
{
    // CSVファイル読み込み
	NSString *csvFile = [[NSBundle mainBundle] pathForResource:fileName ofType:@"csv"];
	NSData *csvData = [NSData dataWithContentsOfFile:csvFile];
	NSString *csv = [[NSString alloc] initWithData:csvData encoding:NSUTF8StringEncoding];
	NSScanner *scanner = [NSScanner scannerWithString:csv];
	
	// 改行文字の集合を取得
	NSCharacterSet *chSet = [NSCharacterSet newlineCharacterSet];
    
	// 一行ずつの読み込み
	NSString *line;
	NSMutableArray *gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    
	while (![scanner isAtEnd]) {
        
		// 一行読み込み
		[scanner scanUpToCharactersFromSet:chSet intoString:&line];
		
		// カンマ「,」で区切る
		NSArray *array = [line componentsSeparatedByString:@","];

		// ゲレンデ情報を配列に挿入する
		Gelande *g = [[Gelande alloc] init];
		
		g.name = [array objectAtIndex:0];
		g.address = [array objectAtIndex:1];
		g.telNumber = [array objectAtIndex:2];
		g.hashTag = [NSString stringWithFormat:@"#%@", [array objectAtIndex:3]];
		g.latitude = [array objectAtIndex:4];
		g.longitude = [array objectAtIndex:5];
        g.largeAreaName = largeName;
		g.smallAreaName = smallName;
		g.csvFileName = fileName;
		g.kana = [array objectAtIndex:6];
		g.serachWord = [array objectAtIndex:7];
        
		[gelandeList addObject:g];
		
		//　改行文字をスキップ
		[scanner scanCharactersFromSet:chSet intoString:NULL];
	}
    
    return gelandeList;
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
