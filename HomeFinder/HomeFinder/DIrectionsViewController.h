//
//  DIrectionsViewController.h
//  HomeFinder
//
//  Created by vamsi krishna on 10/02/14.
//  Copyright (c) 2014 vamsikrishna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DIrectionsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, assign) CLLocationCoordinate2D destinationLocation;
- (IBAction)dismissView:(id)sender;
@end
