//
//  ListsViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "ListsViewController.h"
#import "TwitterManager.h"

@interface ListsViewController ()

@property (nonatomic) NSString *listId;

@end

@implementation ListsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDelegate:(id<ListsViewControllerDelegate>)delegate
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadListTimeLineWithListID:(NSString *)listId SinceID:(NSString *)sinceId MaxID:(NSString *)maxId
{
    self.listId = listId;
    self.loadStatus = Loading;
    [[TwitterManager sharedInstance] requestListsStatusesWithListID:listId SinceID:sinceId MaxID:maxId Handler:^(NSArray *statuses) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (statuses && sinceId) {
                
                [super doneLoadingNewTimeLineDataWithStatuses:statuses];
            }
            else if (statuses) {
                
                [super doneLoadingOldTimeLineDataWithStatuses:statuses];
            }
            else {
                
                [super doneLoadingTimeLineData];
            }
        });
    }];
}

- (void)loadNewTimeLineData
{
	[super loadNewTimeLineData];
    [self loadListTimeLineWithListID:self.listId SinceID:self.sinceId MaxID:nil];
}

- (void)loadOldTimeLineData
{
    [super loadOldTimeLineData];
    [self loadListTimeLineWithListID:self.listId SinceID:nil MaxID:self.maxId];
}

@end
