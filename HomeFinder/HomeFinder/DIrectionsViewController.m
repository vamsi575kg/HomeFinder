//
//  DIrectionsViewController.m
//  HomeFinder
//
//  Created by vamsi krishna on 10/02/14.
//  Copyright (c) 2014 vamsikrishna. All rights reserved.
//

#import "DIrectionsViewController.h"

@interface DIrectionsViewController ()

@end

@implementation DIrectionsViewController

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
    
    NSString *path = [NSString stringWithFormat:@"https://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f&output=embed",self.currentLocation.latitude,self.currentLocation.longitude,self.destinationLocation.latitude,self.destinationLocation.longitude];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    [self.webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissView:(id)sender {
    [self dismissModalViewControllerAnimated:NO];
}
@end
