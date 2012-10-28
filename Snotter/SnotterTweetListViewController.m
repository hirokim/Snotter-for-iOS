//
//  SnotterTweetListViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "SnotterTweetListViewController.h"
#import "TwitterManager.h"

@interface SnotterTweetListViewController ()

@end

@implementation SnotterTweetListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.imageTest loadImageWithURL:@"https://si0.twimg.com/profile_images/1843055878/__________2012-02-21_20.42.27__normal.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)test:(id)sender {
    
    [[TwitterManager sharedInstance] logInWithShowInView:self];
}
- (void)viewDidUnload {
    [self setImageTest:nil];
    [super viewDidUnload];
}
@end
