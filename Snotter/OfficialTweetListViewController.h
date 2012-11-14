//
//  OfficialTweetListViewController.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListsViewController.h"

@interface OfficialTweetListViewController : UIViewController <ListsViewControllerDelegate, NADViewDelegate>

@property (nonatomic) ListsViewController *timeLineView;

@end
