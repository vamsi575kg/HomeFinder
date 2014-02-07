//
//  OverlaySelectionView.h
//  HomeFinder
//
//  Created by vamsi krishna on 06/02/14.
//  Copyright (c) 2014 vamsikrishna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

@protocol OverlaySelectionViewDelegate
// callback when user finishes selecting map region
- (void)selectedAreaPoints:(NSArray *)points;
@end


@interface OverlaySelectionView : UIView {
@private
    NSMutableArray *points;
    
    CGPoint previousPoint2 ;
    CGPoint previousPoint1 ;
    CGPoint currentPoint ;
}
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) id<OverlaySelectionViewDelegate> delegate;

@end
