//
//  GelandeMapViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "GelandeMapViewController.h"
#import "GelandeTweetViewController.h"

@interface GelandeMapViewController ()

@property (nonatomic) BOOL detailDisclosureHidden;
@property (nonatomic) NSMutableArray *gelandeList;
@property (nonatomic) CLLocationCoordinate2D coordinates;

@property (nonatomic) NADView *nadView;
@property (nonatomic) BOOL isNadViewVisible;

@end

@implementation GelandeMapViewController

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
    self = [super initWithNibName:@"GelandeMapViewController" bundle:nil];
    if (self) {
        
        self.gelandeList = [NSMutableArray arrayWithObject:gelande];
        self.detailDisclosureHidden = YES;
    }
    return self;
}

- (id)initWithGelandeList:(NSArray *)list
{
    self = [super initWithNibName:@"GelandeMapViewController" bundle:nil];
    if (self) {
        
        self.gelandeList = [NSMutableArray arrayWithArray:list];
        self.detailDisclosureHidden = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"現在地"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(nowLocation)];
    self.navigationItem.rightBarButtonItem = btn;
    
    // お店のアノテーションを地図に付加
	[self.mapView addAnnotations:self.gelandeList];
	
	// 初期表示時の地図の表示範囲を設定
	MKCoordinateSpan span;
	double distance = 150000;
	span.latitudeDelta = distance * ONE_METER;
	span.longitudeDelta = distance * ONE_METER;
	
	// 初期表示情報を設定
	MKCoordinateRegion region;
	region.span=span;
	
	Gelande *g = [self.gelandeList lastObject];
	CLLocationCoordinate2D center;
	center.latitude = [g.latitude doubleValue];
	center.longitude = [g.longitude doubleValue];
	
	region.center=center;
	[self.mapView setRegion:region animated:YES];
    
    if ([self.gelandeList count] > 1) {
        
        [self.btnOpenMap setHidden:YES];
        [self updateTitleWithTitle:g.smallAreaName];
    }
    else {
        
        [self updateTitleWithTitle:g.name];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[GANTracker sharedTracker] trackPageview:GELANDE_MAP withError:nil];
    
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

- (void)viewDidUnload
{
    [self setNadView:nil];
    [self setMapView:nil];
    [self setBtnOpenMap:nil];
    [super viewDidUnload];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	// ゲレンデアノテーションの場合
	if ([annotation isKindOfClass:[Gelande class]]) {
		
        static NSString *AnnotationIdentifier = @"GelandeAnnotation";
		MKPinAnnotationView *annotateView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
		if (annotateView == nil) {
			annotateView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                           reuseIdentifier:AnnotationIdentifier];
		}
		else {
			annotateView.annotation = annotation;
		}
        
		annotateView.pinColor = MKPinAnnotationColorGreen;
		annotateView.animatesDrop=YES;
		annotateView.canShowCallout = YES;
		
		if ([self.gelandeList count] > 1) {
			UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			annotateView.rightCalloutAccessoryView = myDetailButton;
		}
		
		return annotateView;
	}
	else {
		// ユーザーロケーション用のアノテーションは必要ないので設定しない
		// システムデフォルトのロケーション表示（青い波紋のようなアニメーション）で表現される
		return nil;
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	GelandeTweetViewController *ctl = [[GelandeTweetViewController alloc] initWithGelande:(Gelande *)view.annotation];
	[self.navigationController pushViewController:ctl animated:YES];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
	
}

- (void)mapView:(MKMapView*)mapView didAddAnnotationViews:(NSArray*)views
{
	
}

#pragma mark -

- (IBAction)nowLocation
{
	self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
}

- (IBAction)openMap
{
    Gelande *g = [self.gelandeList lastObject];
    
    NSString *mapURL;
    BOOL hasGoogleMap = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
    if (hasGoogleMap) {
        mapURL = @"comgooglemaps://?center=%@,%@";
    }
    else {
        mapURL = @"http://maps.google.com/maps?ll=%@,%@";
    }
    
    mapURL = [NSString stringWithFormat:mapURL, g.latitude, g.longitude];
    DNSLog(@"Open Map url:%@", mapURL);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapURL]];
}

- (void)updateTitleWithTitle:(NSString *)title
{
	UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 160, 40.0)];
	lblTitle.numberOfLines = 2;
	lblTitle.textAlignment = UITextAlignmentCenter;
	lblTitle.font = [UIFont boldSystemFontOfSize:14.0];
	lblTitle.text = title;
	lblTitle.textColor = [UIColor whiteColor];
	lblTitle.backgroundColor = [UIColor clearColor];
	self.navigationItem.titleView = lblTitle;
}

#pragma mark - NADView delegate

// NADViewのロードが成功した時に呼ばれる
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    DNSLog(@"GelandeMapViewController delegate nadViewDidFinishLoad");
}

// 広告受信成功
-(void)nadViewDidReceiveAd:(NADView *)adView
{
    DNSLog(@"GelandeMapViewController delegate nadViewDidReceiveAd");
    
    if (!self.isNadViewVisible) {
        
        self.isNadViewVisible = YES;
        [self nadViewFrameOffset:self.nadView.frame.size.height * -1];
    }
}

// 広告受信エラー
-(void)nadViewDidFailToReceiveAd:(NADView *)adView
{
    DNSLog(@"GelandeMapViewController delegate nadViewDidFailToReceiveAd");
    
    if (self.isNadViewVisible) {
        
        self.isNadViewVisible = NO;
        [self nadViewFrameOffset:self.nadView.frame.size.height];
    }
}

- (void)nadViewFrameOffset:(float)height
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.btnOpenMap.frame = CGRectOffset(self.btnOpenMap.frame,
                                             0,
                                             height);
        
        self.nadView.frame = CGRectOffset(self.nadView.frame,
                                          0,
                                          height);
    } completion:^(BOOL finished) {
        
        self.mapView.frame = CGRectMake(self.mapView.frame.origin.x,
                                        self.mapView.frame.origin.y,
                                        self.mapView.frame.size.width,
                                        self.mapView.frame.size.height
                                        + height);
    }];
}

@end
