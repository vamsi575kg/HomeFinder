//
//  MapViewController.h
//  HomeFinder
//
//  Created by vamsi krishna on 06/02/14.
//  Copyright (c) 2014 vamsikrishna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OverlaySelectionView.h"

@interface MapViewController : UIViewController<OverlaySelectionViewDelegate>{
    
    NSArray *searchItems;
    int selectedItem;
    CLLocationCoordinate2D centerLocation;
    CLLocationDistance radius;
}

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *draw;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *clear;

- (IBAction)drawClicked:(id)sender;
- (IBAction)addAnnotation:(id)sender;
- (IBAction)showActionsheet:(id)sender;
@end
