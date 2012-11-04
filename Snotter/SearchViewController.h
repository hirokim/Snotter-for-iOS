//
//  SearchViewController.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "TimeLineViewController.h"

@protocol SearchViewControllerDelegate <TimeLineViewControllerDelegate>

@end

@interface SearchViewController : TimeLineViewController

- (id)initWithDelegate:(id<SearchViewControllerDelegate>)delegate;
- (void)loadSearchTimeLineWithKeywords:(NSArray *)words SinceID:(NSString *)sinceId MaxID:(NSString *)maxId;

@end
