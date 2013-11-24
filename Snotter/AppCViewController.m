//
//  AppCViewController.m
//  Snotter
//
//  Created by Hiroki Matsuse on 2013/10/06.
//  Copyright (c) 2013年 松瀬 弘樹. All rights reserved.
//

#import "AppCViewController.h"

@interface AppCViewController ()

@end

@implementation AppCViewController

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
    if([[UIDevice currentDevice].systemVersion intValue] >= 7)
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
