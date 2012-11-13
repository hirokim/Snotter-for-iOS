//
//  GelandeTweetViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "GelandeTweetViewController.h"
#import "TweetViewController.h"
#import "GelandeMapViewController.h"
#import "WebBrowserViewController.h"
#import "TwitterManager.h"

@interface GelandeTweetViewController ()

@property (nonatomic) Gelande *gelande;

@end

@implementation GelandeTweetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithGelande:(Gelande *)gelande
{
    self = [super initWithNibName:@"GelandeTweetViewController" bundle:nil];
    if (self) {
        self.gelande = gelande;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = HEXCOLOR(NAVIGATION_BAR_COLOR);
    
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:nil];
	[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segmentedControl insertSegmentWithTitle:@"fav" atIndex:0 animated:NO];
	[segmentedControl insertSegmentWithTitle:@"tweet" atIndex:1 animated:NO];
	[segmentedControl insertSegmentWithTitle:@"web" atIndex:2 animated:NO];
	[segmentedControl insertSegmentWithTitle:@"map" atIndex:3 animated:NO];
	[segmentedControl addTarget:self action:@selector(segCtlPressed:) forControlEvents:UIControlEventValueChanged];
    
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
    self.timeLineView = [[SearchViewController alloc] initWithDelegate:self];
    self.timeLineView.tableView.frame = self.view.frame;
    [self.view addSubview:self.timeLineView.tableView];
    
    self.lblSmallArea.text = self.gelande.smallAreaName;
    self.lblGelandeName.text = self.gelande.name;
    self.lblAddress.text = self.gelande.address;
    self.lblTellNumber.text = self.gelande.telNumber;
    
    self.timeLineView.tableView.tableHeaderView = self.gelandeHeaderView;
    [self.timeLineView loadSearchTimeLineWithKeywords:@[self.gelande.hashTag, self.gelande.name] SinceID:nil MaxID:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[GANTracker sharedTracker] trackPageview:GELANDE_TWEET withError:nil];
    
    if (![TwitterManager sharedInstance].usingAccount) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"Twitterアカウントが設定されていません。"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLblSmallArea:nil];
    [self setLblGelandeName:nil];
    [self setLblAddress:nil];
    [self setLblTellNumber:nil];
    [self setGelandeHeaderView:nil];
    [super viewDidUnload];
}

- (void)timeLineViewController:(TimeLineViewController *)controller selectedStatus:(TweetStatus *)status
{
    TweetViewController *ctl = [[TweetViewController alloc] initWithStatus:status];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)segCtlPressed:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        
        case 0: {
            
            [[GANTracker sharedTracker] trackEvent:GELANDE_TWEET action:SEGMENT_SELECTED label:SEL_FAVORITE value:-1 withError:nil];
            
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSMutableArray *favoriteList = [ud objectForKey:FAVORITE_KEY];
            if (!favoriteList) {
                
                favoriteList = [[NSMutableArray alloc] initWithCapacity:0];
            }
            else {
                
                NSData *data = [ud objectForKey:FAVORITE_KEY];
                favoriteList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
            
            [favoriteList addObject:self.gelande];
            
            NSData* classDataSave = [NSKeyedArchiver archivedDataWithRootObject:favoriteList];
            [ud setObject:classDataSave forKey:FAVORITE_KEY];
            [ud synchronize];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"完了"
                                                            message:@"お気に入りに追加しました。"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            break;
        }
        case 1: {
            
            [[GANTracker sharedTracker] trackEvent:GELANDE_TWEET action:SEGMENT_SELECTED label:SEL_TWEET value:-1 withError:nil];
            
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
            break;
        }
        case 2: {
            
            [[GANTracker sharedTracker] trackEvent:GELANDE_TWEET action:SEGMENT_SELECTED label:SEL_GOOGLE_SEARCH value:-1 withError:nil];
            
            NSString *urlStr = [NSString stringWithFormat:@"http://www.google.co.jp/search?q=%@", [self.gelande.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            WebBrowserViewController *ctl = [[WebBrowserViewController alloc] initWithURL:urlStr];
            ctl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:ctl animated:YES];
            break;
        }
        case 3: {
            
            [[GANTracker sharedTracker] trackEvent:GELANDE_TWEET action:SEGMENT_SELECTED label:SEL_MAP value:-1 withError:nil];
            
            GelandeMapViewController *ctl = [[GelandeMapViewController alloc] initWithGelande:self.gelande];
            [self.navigationController pushViewController:ctl animated:YES];
            break;
        }
        default: {
            break;
        }
    }
    
    sender.selectedSegmentIndex = UISegmentedControlNoSegment;
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
    [viewController setInitialText:[NSString stringWithFormat:@"#_snotter #%@ 【%@】", self.gelande.hashTag, self.gelande.name]];
    
    if (image)
        [viewController addImage:image];
    
    viewController.completionHandler = ^(TWTweetComposeViewControllerResult res) {
        
        if (res == TWTweetComposeViewControllerResultDone) {
            
            [[GANTracker sharedTracker] trackEvent:GELANDE_TWEET action:SEL_TWEET label:TWEETED value:-1 withError:nil];
        }
    };
    
    [self presentModalViewController:viewController animated:YES];
}

@end
