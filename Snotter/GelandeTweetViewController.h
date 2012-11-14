//
//  GelandeTweetViewController.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/TWTweetComposeViewController.h>
#import "Gelande.h"
#import "SearchViewController.h"

@interface GelandeTweetViewController : UIViewController <SearchViewControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NADViewDelegate>

@property (nonatomic) SearchViewController *timeLineView;

@property (strong, nonatomic) IBOutlet UIView *gelandeHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *lblSmallArea;
@property (weak, nonatomic) IBOutlet UILabel *lblGelandeName;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblTellNumber;

- (id)initWithGelande:(Gelande *)gelande;

@end
