//
//  GelandeListViewController.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GelandeListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (id)initWithGelandeList:(NSArray *)gelandeList;

@end
