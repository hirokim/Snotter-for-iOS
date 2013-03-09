//
//  AppDelegate.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "AppDelegate.h"

#import "AreaListViewController.h"
#import "SnotterTweetListViewController.h"
#import "FavoriteListViewController.h"
#import "OfficialTweetListViewController.h"
#import "SettingViewController.h"
#import "TwitterManager.h"
#import "Bead.h"
#import "appC.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-33846161-1"
                                           dispatchPeriod:10
                                                 delegate:nil];
    
    [TwitterManager sharedInstance];
    
    [Bead initializeAd];
    [[Bead sharedInstance] addSID:BEAD_SID interval:BEAD_INTERVAL];
    
    [appC setupAppCWithMediaKey:APPC_MEDIA_ID];
    
    UIColor *barColor = HEXCOLOR(NAVIGATION_BAR_COLOR);
    [[UINavigationBar appearance]   setTintColor:barColor];
    [[UISearchBar appearance]       setTintColor:barColor];
    [[UIToolbar appearance]         setTintColor:barColor];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // ビューコントローラ生成
    UIViewController *viewController1 = [[AreaListViewController alloc] initWithNibName:@"AreaListViewController" bundle:nil];    
    UIViewController *viewController2 = [[SnotterTweetListViewController alloc] initWithNibName:@"SnotterTweetListViewController" bundle:nil];
    UIViewController *viewController3 = [[FavoriteListViewController alloc] initWithNibName:@"FavoriteListViewController" bundle:nil];
    UIViewController *viewController4 = [[OfficialTweetListViewController alloc] initWithNibName:@"OfficialTweetListViewController" bundle:nil];
    
    UINavigationController *naviCon1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    UINavigationController *naviCon2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    UINavigationController *naviCon3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    UINavigationController *naviCon4 = [[UINavigationController alloc] initWithRootViewController:viewController4];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[naviCon1, naviCon2, naviCon3, naviCon4];
    
    
    UITabBarItem *tbItem;
    tbItem = [self.tabBarController.tabBar.items objectAtIndex:0];
    tbItem.title = @"スキー場";
    tbItem.image = [UIImage imageNamed:@"FormatBullets"];
    
    tbItem = [self.tabBarController.tabBar.items objectAtIndex:1];
    tbItem.title = @"ｽﾉったーﾂｲｰﾄ";
    tbItem.image = [UIImage imageNamed:@"Balloon"];
    
    tbItem = [self.tabBarController.tabBar.items objectAtIndex:2];
    tbItem.title = @"お気に入り";
    tbItem.image = [UIImage imageNamed:@"Heart"];
    
    tbItem = [self.tabBarController.tabBar.items objectAtIndex:3];
    tbItem.title = @"関連ツイート";
    tbItem.image = [UIImage imageNamed:@"Information"];
    
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    
    // Bundle versions取得
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    // 保存してあるversion取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *savedVersion = [ud stringForKey:@"BundleVersion"];
    
    // バージョンが変わってたらDB初期化
    if (![version isEqualToString:savedVersion]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"アップデート"
                                                        message:UPDATE_INFO
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        
        [alert show];
        
        [ud setObject:version forKey:@"BundleVersion"];
        [ud synchronize];
    }
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    return YES;
}

void uncaughtExceptionHandler(NSException *exception)
{
    // ここで、例外発生時の情報を出力します。
    NSLog(@"%@", exception.name);
    NSLog(@"%@", exception.reason);
    NSLog(@"%@", exception.callStackSymbols);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[GANTracker sharedTracker] stopTracker];
}


// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [[Bead sharedInstance] showWithSID:BEAD_SID];
}


/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
