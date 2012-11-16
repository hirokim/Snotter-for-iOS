//
//  SearchViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "SearchViewController.h"
#import "TwitterManager.h"

@interface SearchViewController ()

@property (nonatomic) NSArray *keywords;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDelegate:(id<SearchViewControllerDelegate>)delegate
{
    self = [super initWithNibName:@"TimeLineViewController" bundle:nil];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSearchTimeLineWithKeywords:(NSArray *)words SinceID:(NSString *)sinceId MaxID:(NSString *)maxId
{
    self.keywords = words;
    self.loadStatus = Loading;
    [[TwitterManager sharedInstance] requestSearchStatusesWithKeywords:words SinceID:sinceId MaxID:maxId Handler:^(NSArray *statuses, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [super doneLoadingTimeLineDataWithStatuses:statuses SinceID:sinceId MaxID:maxId];
        });
    }];
}

- (void)loadNewTimeLineData
{
	[super loadNewTimeLineData];
    [self loadSearchTimeLineWithKeywords:self.keywords SinceID:self.sinceId MaxID:nil];
}

- (void)loadOldTimeLineData
{
    [super loadOldTimeLineData];
    [self loadSearchTimeLineWithKeywords:self.keywords SinceID:nil MaxID:self.maxId];
}

@end
