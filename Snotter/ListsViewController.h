//
//  ListsViewController.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeLineViewController.h"

@protocol ListsViewControllerDelegate <TimeLineViewControllerDelegate>

@end

@interface ListsViewController : TimeLineViewController

- (id)initWithDelegate:(id<ListsViewControllerDelegate>)delegate;
- (void)loadListTimeLineWithListID:(NSString *)listId SinceID:(NSString *)sinceId MaxID:(NSString *)maxId;

@end
