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
#import "SettingViewController.h"

@interface SnotterTweetListViewController ()

@property (nonatomic) NADView *nadView;
@property (nonatomic) BOOL isNadViewVisible;

@end

@implementation SnotterTweetListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"ｽﾉったーﾂｲーﾄ";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([[UIDevice currentDevice].systemVersion intValue] >= 7)
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
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
    [self.view addSubview:self.timeLineView.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[GANTracker sharedTracker] trackPageview:SNOTTER_TWEET withError:nil];
    
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
    
    if (![TwitterManager sharedInstance].usingAccount) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"アカウント設定"
                                                        message:@"左上の設定からTwitterアカウントを\n設定してください。"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        
        self.timeLineView.tableView.hidden = YES;
        return;
    }
    
    self.timeLineView.tableView.hidden = NO;
    
    if (self.timeLineView.statuses.count == 0 && self.timeLineView.loadStatus != Loading) {
        [self.timeLineView loadSearchTimeLineWithKeywords:@[@"#_snotter"] SinceID:nil MaxID:nil];
    }
    
    [self.nadView resume];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.nadView pause];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNadView:nil];
    [super viewDidUnload];
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

#pragma mark - UIActionSheetDelegate

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

#pragma mark - SearchViewControllerDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetViewController *ctl = [[TweetViewController alloc] initWithStatus:[self.timeLineView.statuses objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark -

- (void)showSetting
{
    SettingViewController *ctl = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:ctl];
    [self presentModalViewController:navi animated:YES];
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

- (void)showImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)type
{
    UIImagePickerController *iPicker = [[UIImagePickerController alloc] init];
    iPicker.sourceType = type;
    iPicker.delegate = self;
    
    [self presentModalViewController:iPicker animated:YES];
}

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
        
        [self dismissModalViewControllerAnimated:YES];
    };
        
    [self presentModalViewController:viewController animated:YES];
}

#pragma mark - NADView delegate

// NADViewのロードが成功した時に呼ばれる
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    DNSLog(@"SnotterTweetListViewController delegate nadViewDidFinishLoad");
}

// 広告受信成功
-(void)nadViewDidReceiveAd:(NADView *)adView
{
    DNSLog(@"SnotterTweetListViewController delegate nadViewDidReceiveAd");
    
    if (!self.isNadViewVisible) {
        
        self.isNadViewVisible = YES;
        [self nadViewFrameOffset:self.nadView.frame.size.height * -1];
    }
}

// 広告受信エラー
-(void)nadViewDidFailToReceiveAd:(NADView *)adView
{
    DNSLog(@"SnotterTweetListViewController delegate nadViewDidFailToReceiveAd");
    
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
        
        self.timeLineView.tableView.frame = CGRectMake(self.timeLineView.tableView.frame.origin.x,
                                                       self.timeLineView.tableView.frame.origin.y,
                                                       self.timeLineView.tableView.frame.size.width,
                                                       self.timeLineView.tableView.frame.size.height
                                                       + height);
    }];
}

@end
