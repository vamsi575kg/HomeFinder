//
//  MapViewController.m
//  HomeFinder
//
//  Created by vamsi krishna on 06/02/14.
//  Copyright (c) 2014 vamsikrishna. All rights reserved.
//

#import "MapViewController.h"
#import "OverlaySelectionView.h"

#import "NSValue+MyKeyCategory.h"
#import "Parser.h"
#import "SVProgressHUD.h"

#import "ActionSheetStringPicker.h"

#import "DIrectionsViewController.h"


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
    
    searchItems = @[@"accounting",@"museum", @"airport", @"amusement_park",@"grocery_or_supermarket",@"atm",@"pharmacy" ,@"school",@"movie_theater",@"doctor",@"bus_station",@"hospital",@"university",@"bank",@"bakery",@"food",@"hindu_temple",@"taxi_stand",@"dentist",@"hair_care"];
    
    MKUserLocation *userLocation = self.mapView.userLocation;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 5000, 5000);
    
    [self.mapView setRegion:region];
    
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
- (IBAction)showActionsheet:(id)sender{
    [ActionSheetStringPicker showPickerWithTitle:@"Select Item to Search" rows:searchItems initialSelection:selectedItem target:self successAction:@selector(searchItemWasSelected:element:) cancelAction:nil origin:[self.view superview]];
}

- (void)searchItemWasSelected:(NSNumber *)selectedIndex element:(id)element {
    selectedItem = [selectedIndex intValue];
    
    [self fetchDataforType:[searchItems objectAtIndex:selectedItem] withLocation:centerLocation withRadius:radius];
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

- (IBAction)addAnnotation:(id)sender {

    [self.mapView removeOverlay:polygone];
    
    for (id annotation in self.mapView.annotations) {
        
        if (![annotation isKindOfClass:[MKUserLocation class]]){
            
            [self.mapView removeAnnotation:annotation];
        }
    }
    
    [self.draw setEnabled:YES];
    [self.clear setEnabled:NO];

}

-(void)pointInsideOverlay:(CLLocationCoordinate2D )tapPoint withTitle:(NSString *)title withSubTitle:(NSString *)sub
{
    /*MKPolygonView *polygonView = (MKPolygonView *)[self.mapView viewForOverlay:polygone];
    
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
    }*/
    
 
    
  //  MKPolygonView *polygonView = (MKPolygonView *)[self.mapView viewForOverlay:polygone];
    
    MKMapPoint mapPoint = MKMapPointForCoordinate(tapPoint);
    
    CGMutablePathRef mpr = CGPathCreateMutable();
    
    MKMapPoint *polygonPoints = polygone.points;
    //myPolygon is the MKPolygon
    
    for (int p=0; p < polygone.pointCount; p++)
    {
        MKMapPoint mp = polygonPoints[p];
        if (p == 0)
            CGPathMoveToPoint(mpr, NULL, mp.x, mp.y);
        else
            CGPathAddLineToPoint(mpr, NULL, mp.x, mp.y);
    }
    
    CGPoint mapPointAsCGP = CGPointMake(mapPoint.x, mapPoint.y);
    //mapPoint above is the MKMapPoint of the coordinate we are testing.
    //Putting it in a CGPoint because that's what CGPathContainsPoint wants.
    
    BOOL pointIsInPolygon = CGPathContainsPoint(mpr, NULL, mapPointAsCGP, FALSE);
    
    CGPathRelease(mpr);
    
    if (pointIsInPolygon)
    {
        // Add an annotation
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = tapPoint;
        point.title = title;
        point.subtitle = sub;
        [self.mapView addAnnotation:point];
        
    }

}
- (MKAnnotationView *) mapView:(MKMapView *)mapView1 viewForAnnotation:(id <MKAnnotation>) annotation{
    
    MKAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation)
    {
        static NSString *defaultPinID = @"pinId";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        
        if ( pinView == nil ){
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        }
        
        
        pinView.canShowCallout = YES;
        pinView.image = [UIImage imageNamed:@"pin.png"];
          
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
    }    
    return pinView;    
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    MKPointAnnotation *point = (MKPointAnnotation *)view.annotation;
    
    NSLog(@"%f  %f",point.coordinate.longitude, point.coordinate.latitude);
    
    
    DIrectionsViewController *viewController = [[DIrectionsViewController alloc] initWithNibName:@"DIrectionsViewController" bundle:nil];
    viewController.currentLocation = self.mapView.userLocation.coordinate;
    viewController.destinationLocation = point.coordinate;
    
    [self presentModalViewController:viewController animated:NO];
    //[self.navigationController pushViewController:viewController animated:YES];

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
       
        coordinates[i] = coordinate;
       // NSLog(@"%f,%f",coordinate.latitude,coordinate.longitude);
    }
   
    polygone = [[MKPolygon  alloc] init];
    polygone = [MKPolygon polygonWithCoordinates:coordinates count:numberOfSteps];
    [self.mapView addOverlay:polygone];
    
  
    
    CGPoint minPoint;
    
    minPoint.x = [[points valueForKeyPath:@"@min.x"] floatValue];
    minPoint.y = [[points valueForKeyPath:@"@min.y"] floatValue];
    
    NSLog(@"minPoint %f,%f",minPoint.x,minPoint.y);

    CGPoint maxPoint;
    
    maxPoint.x = [[points valueForKeyPath:@"@max.x"] floatValue];
    maxPoint.y = [[points valueForKeyPath:@"@max.y"] floatValue];
    
    NSLog(@"maxPoint%f,%f",maxPoint.x,maxPoint.y);
    
    CGPoint centerPoint;
    centerPoint.x = (minPoint.x + maxPoint.x) / 2.0;
    centerPoint.y = (minPoint.y + maxPoint.y) / 2.0;

    NSLog(@"centerPoint %f,%f",centerPoint.x,centerPoint.y);
    
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:centerPoint toCoordinateFromView:self.view];
    
    CLLocationCoordinate2D tapPoint2 = [self.mapView convertPoint:maxPoint toCoordinateFromView:self.view];

    CLLocation * center = [[CLLocation alloc] initWithLatitude:tapPoint.latitude longitude:tapPoint.longitude];
    CLLocation * newLocation = [[CLLocation alloc] initWithLatitude:tapPoint2.latitude longitude:tapPoint2.longitude];
    
    CLLocationDistance distance = [center distanceFromLocation:newLocation];
    
    centerLocation = tapPoint;
    radius = distance;
   
    [self fetchDataforType:[searchItems objectAtIndex:selectedItem] withLocation:centerLocation withRadius:radius];
    
   
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolygonView *polylineView = [[MKPolygonView alloc] initWithPolygon:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 2.0;
    polylineView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    return polylineView;
}
#pragma mark - Fetch Data
-(void)fetchDataforType:(NSString *)types withLocation:(CLLocationCoordinate2D)location withRadius:(CLLocationDistance)distance{
    [SVProgressHUD show];
    
    NSString *post1 = [NSString stringWithFormat:@"&location=%f,%f",location.latitude,location.longitude];
    
    NSString *post2 = [NSString stringWithFormat:@"&radius=%f",distance];
    NSString *post3 = [NSString stringWithFormat:@"&types=%@",types];
    NSString *post4 = [NSString stringWithFormat:@"&sensor=%@",@"false"];
    
// TODO: Add your google api key
    NSString *post5 = [NSString stringWithFormat:@"&key=%@",];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?",post1,post2,post3,post4,post5];
    //nearbysearch
    //radarsearch
    NSLog(@"url:%@",urlString);
    
    Parser *request = [[Parser alloc] requestWithString:urlString withDelegate:self];
    [request setDidFinishSelector:@selector(serverRequestSuccessWith:)];
    [request setDidFailSelector:@selector(serverRequestFailureWith:)];
    [request sendAsynchronous];
}

- (void)serverRequestSuccessWith:(ParserResponse *)response{
    
    // NSLog(@"Response:%@",[response responseArray]);
    
    id existing = [response responseArray];
    
    if ([existing isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)existing;
    
      //  NSLog(@"%@",[dict objectForKey:@"results"]);
    
        NSArray *results = [dict objectForKey:@"results"];
        
        for (id annotation in self.mapView.annotations) {
            NSLog(@"annotation %@", annotation);
            
            if (![annotation isKindOfClass:[MKUserLocation class]]){
                
                [self.mapView removeAnnotation:annotation];
            }
        }

        
        for (NSDictionary *locations in results) {
            
            NSDictionary *location = [[locations objectForKey:@"geometry"] objectForKey:@"location"];
            
           // NSLog(@"%@",location);
            
            CLLocationCoordinate2D loc;
            
            loc.latitude = [[location objectForKey:@"lat"] doubleValue];
            loc.longitude = [[location objectForKey:@"lng"] doubleValue];
            
            // NSLog(@"%f,%f",loc.latitude,loc.longitude);
            
            NSString *name = [locations objectForKey:@"name"];
            NSString *rating = [locations objectForKey:@"vicinity"];
            [self pointInsideOverlay:loc withTitle:name withSubTitle:rating];
        }
    }
   
    
    [SVProgressHUD dismiss];
    
    
}

- (void)serverRequestFailureWith: (NSError *)error{
    
    NSLog(@"err msg:%@",[error localizedDescription]);
    
    [SVProgressHUD dismiss];
    
}

@end
