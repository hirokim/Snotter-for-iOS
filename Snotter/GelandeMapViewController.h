//
//  GelandeMapViewController.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Gelande.h"

@interface GelandeMapViewController : UIViewController <MKMapViewDelegate, NADViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *btnOpenMap;

- (id)initWithGelande:(Gelande *)gelande;
- (id)initWithGelandeList:(NSArray *)list;
- (IBAction)nowLocation;
- (IBAction)openMap;

@end
