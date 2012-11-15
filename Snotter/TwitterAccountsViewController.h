//
//  AccountsViewController.h
//  SocialLoginTest
//
//  Created by 松瀬 弘樹 on 12/10/03.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@protocol TwitterAccountsViewControllerDelegate <NSObject>

- (void)didSelectedAccount:(ACAccount *)newAccount;

@optional
- (void)cancelSelectAccount;

@end

@interface TwitterAccountsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblErrorMessage;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic) id<TwitterAccountsViewControllerDelegate> delegate;

- (id)initWithAccount:(ACAccount *)usingAccount;
- (IBAction)cancel:(id)sender;

@end
