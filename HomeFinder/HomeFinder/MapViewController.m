//
//  MapViewController.m
//  HomeFinder
//
//  Created by vamsi krishna on 06/02/14.
//  Copyright (c) 2014 vamsikrishna. All rights reserved.
//

#import "MapViewController.h"
#import "OverlaySelectionView.h"

@interface MapViewController (){
    MKPolygon *polygone;
}

@end

@implementation MapViewController

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
    // Do any additional setup after loading the view from its nib.
    
    MKUserLocation *userLocation = self.mapView.userLocation;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000);
    
    [self.mapView setRegion:region];
    
    UITapGestureRecognizer* tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showsideview:)];
    tap1.numberOfTapsRequired = 1;
    [self.mapView addGestureRecognizer:tap1];
    
    [self.clear setEnabled:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload
{
    self.mapView.delegate = nil;
    
    self.mapView = nil;
    [super viewDidUnload];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.mapView.centerCoordinate = userLocation.location.coordinate;
}
- (IBAction)drawClicked:(id)sender {

    OverlaySelectionView *overlay = [[OverlaySelectionView alloc] initWithFrame:self.mapView.frame];
    overlay.delegate = self;
    [self.view addSubview: overlay];

    
    self.draw.style = UIBarButtonItemStyleDone;
    self.draw.title = @"Done";
}
-(void)showsideview:(UITapGestureRecognizer *)sender
{
    
    CGPoint point = [sender locationInView:self.mapView];
    
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    
    [self pointInsideOverlay:tapPoint];

}
- (IBAction)addAnnotation:(id)sender {

    [self.mapView removeOverlay:polygone];
    
    for (id annotation in self.mapView.annotations) {
        NSLog(@"annotation %@", annotation);
        
        if (![annotation isKindOfClass:[MKUserLocation class]]){
            
            [self.mapView removeAnnotation:annotation];
        }
    }
    
    [self.draw setEnabled:YES];
    [self.clear setEnabled:NO];

}

-(void)pointInsideOverlay:(CLLocationCoordinate2D )tapPoint
{
    MKPolygonView *polygonView = (MKPolygonView *)[self.mapView viewForOverlay:polygone];
    
    MKMapPoint mapPoint = MKMapPointForCoordinate(tapPoint);
    
    CGPoint polygonViewPoint = [polygonView pointForMapPoint:mapPoint];
    
    BOOL mapCoordinateIsInPolygon = CGPathContainsPoint(polygonView.path, NULL, polygonViewPoint, NO);
    
    if (mapCoordinateIsInPolygon)
    {
        // Add an annotation
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = tapPoint;
        point.title = @"Inside region";
       
        [self.mapView addAnnotation:point];
    }else{
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = tapPoint;
        point.title = @"outside region";
        [self.mapView addAnnotation:point];
    }
}
#pragma mark - OverlaySelectionViewDelegate

- (void)selectedAreaPoints:(NSArray *)points;
{
    
    // TODO: comment out to keep search rectangle on screen
    [[self.view.subviews lastObject] removeFromSuperview];
    
    self.draw.style = UIBarButtonItemStyleBordered;
    self.draw.title = @"Draw";
    
    [self.draw setEnabled:NO];
    [self.clear setEnabled:YES];
    NSInteger numberOfSteps = points.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];

    for (int i =0 ; i<[points count]; i++) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView: self.mapView];
        NSLog(@"%f,%f",coordinate.latitude,coordinate.longitude);
        coordinates[i] = coordinate;
    }
    
    polygone = [[MKPolygon  alloc] init];
    polygone = [MKPolygon polygonWithCoordinates:coordinates count:numberOfSteps];
    [self.mapView addOverlay:polygone];
    
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolygonView *polylineView = [[MKPolygonView alloc] initWithPolygon:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 2.0;
    polylineView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    return polylineView;
}

@end
