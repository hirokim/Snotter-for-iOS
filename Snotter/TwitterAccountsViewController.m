//
//  AccountsViewController.m
//  SocialLoginTest
//
//  Created by 松瀬 弘樹 on 12/10/03.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "TwitterAccountsViewController.h"

@interface TwitterAccountsViewController ()
{
    ACAccount *useAccount;
    NSArray *accounts;
    
    ACAccountType *accountType;
    ACAccountStore *accountStore;
}

@end

@implementation TwitterAccountsViewController

/**
 * 初期化（デフォルト）
 *
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"アカウント選択";
    }
    return self;
}

/**
 * 初期化
 *
 * @param usingAccount 使用中Twitterアカウント
 */
- (id)initWithAccount:(ACAccount *)usingAccount
{
    self = [super initWithNibName:@"TwitterAccountsViewController" bundle:nil];
    if (self)
    {
        self.title = @"アカウント選択";
        useAccount = usingAccount;
    }
    return self;
}

/**
 * 画面ロード後
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    accountStore = [[ACAccountStore alloc] init];
    accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self fetchAccounts];
}

/**
 * 画面アンロード後
 *
 */
- (void)viewDidUnload
{
    [self setLblErrorMessage:nil];
    [self setTableview:nil];
    accountStore = nil;
    accountType = nil;
}

/**
 * メモリ警告
 *
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * インスタンス破棄
 *
 */
- (void)dealloc
{
    self.delegate = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ACAccount *account = [accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = [account username];
    
    if ([useAccount.username isEqualToString:account.username])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //選択されたアカウントを取得
	useAccount = [accounts objectAtIndex:indexPath.row];
    
    [self.delegate didSelectedAccount:useAccount];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

/**
 * キャンセルボタン押下
 *
 */
- (IBAction)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cancelSelectAccount)])
        [self.delegate cancelSelectAccount];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/**
 * Twitterアカウントリスト取得
 *
 */
- (void)fetchAccounts
{
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if (!granted)
             {
                 // ユーザがtwitterアカウントへのアクセスを拒否
                 NSLog(@"User rejected access to his account.");
                 self.tableview.hidden = YES;
                 self.lblErrorMessage.text = @"Twitterアカウントへのアクセス権限がありません。\niPhoneの設定からTwitterアカウントを確認してください。";
             }
             else
             {
                 // twitter アカウントへのアクセス許可
                 accounts = [accountStore accountsWithAccountType:accountType];
                 if ([accounts count] == 0)
                 {
                     //設定されていない
                     self.tableview.hidden = YES;
                     self.lblErrorMessage.text = @"Twitterアカウントがありません。\niPhoneの設定からTwitterアカウントを追加してください。";
                 }
                 else
                 {
                     [self.tableview reloadData];
                     
                 }
             }
         });
     }];
}


@end
