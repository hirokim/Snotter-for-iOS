//
//  SnotterTweetListViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "SnotterTweetListViewController.h"
#import "TweetViewController.h"
#import "TwitterManager.h"

@interface SnotterTweetListViewController ()

@end

@implementation SnotterTweetListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"ｽﾉったーﾂｲｰﾄ";
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
    
    btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                        target:self
                                                        action:@selector(tweetChoice)];
    self.navigationItem.rightBarButtonItem = btn;

    self.timeLineView = [[SearchViewController alloc] initWithDelegate:self];
    self.timeLineView.tableView.frame = self.view.frame;
    [self.view addSubview:self.timeLineView.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[GANTracker sharedTracker] trackPageview:SNOTTER_TWEET withError:nil];
    
    if (![TwitterManager sharedInstance].usingAccount) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"Twitterアカウントが設定されていません。"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    if (self.timeLineView.statuses.count == 0) {
        [self.timeLineView loadSearchTimeLineWithKeywords:@[@"#_snotter"] SinceID:nil MaxID:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)timeLineViewController:(TimeLineViewController *)controller selectedStatus:(TweetStatus *)status
{
    TweetViewController *ctl = [[TweetViewController alloc] initWithStatus:status];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)showSetting
{
    [[TwitterManager sharedInstance] logInWithShowInView:self];
}

- (void)tweetChoice
{
    UIActionSheet *sheet;
    
    // カメラが使えるかどうか
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"Tweet"
                                            delegate:self
                                   cancelButtonTitle:@"キャンセル"
                              destructiveButtonTitle:@"つぶやく"
                                   otherButtonTitles:@"カメラロールから選択", @"写真を撮る", nil];
        sheet.cancelButtonIndex = 3;
    }
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"Tweet"
                                            delegate:self
                                   cancelButtonTitle:@"キャンセル"
                              destructiveButtonTitle:@"つぶやく"
                                   otherButtonTitles:@"カメラロールから選択", nil];
        sheet.cancelButtonIndex = 2;
    }
    
    [sheet showInView:self.tabBarController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
            
        case 0:
            // つぶやく
            [self tweetWithImage:nil];
            break;
            
        case 1:
            // カメラロールから
            [self showImagePickerControllerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
        case 2:
            // キャンセルじゃない場合
            if (actionSheet.cancelButtonIndex != buttonIndex) {
                
                // 写真を撮る
                [self showImagePickerControllerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            }
            break;
            
        default:
            break;
    }
}

- (void)showImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)type
{
    UIImagePickerController *iPicker = [[UIImagePickerController alloc] init];
    iPicker.sourceType = type;
    iPicker.delegate = self;
    
    [self presentModalViewController:iPicker animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self tweetWithImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark -

- (void)tweetWithImage:(UIImage *)image
{
    TWTweetComposeViewController *viewController = [[TWTweetComposeViewController alloc] init];
    [viewController setInitialText:@"#_snotter "];
    
    if (image)
        [viewController addImage:image];
    
    viewController.completionHandler = ^(TWTweetComposeViewControllerResult res) {
        
        if (res == TWTweetComposeViewControllerResultDone) {
            
            [[GANTracker sharedTracker] trackEvent:SNOTTER_TWEET action:SEL_TWEET label:TWEETED value:-1 withError:nil];
        }
    };
    
    [self presentModalViewController:viewController animated:YES];
}

@end
