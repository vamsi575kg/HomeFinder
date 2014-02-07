//
//  OverlaySelectionView.m
//  HomeFinder
//
//  Created by vamsi krishna on 06/02/14.
//  Copyright (c) 2014 vamsikrishna. All rights reserved.
//

#import "OverlaySelectionView.h"


@interface OverlaySelectionView()
@property (nonatomic, retain) UIView* dragArea;
@end

@implementation OverlaySelectionView

@synthesize dragArea;
@synthesize delegate;

- (void) initialize {
    [self.imageView removeFromSuperview];
    
    points = [[NSMutableArray alloc]init];
    
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.frame];
    [self addSubview:self.imageView];
}

- (id) initWithCoder: (NSCoder*) coder {
    self = [super initWithCoder: coder];
    if (self != nil) {
        [self initialize];
    }
    return self;
}

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame: frame];
    if (self != nil) {
        [self initialize];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // do nothing
}

#pragma mark - Touch handling

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    
    previousPoint1 = [touch previousLocationInView:self];
    previousPoint2 = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
    
    [points addObject:[NSValue valueWithCGPoint:currentPoint]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    
    previousPoint2 = previousPoint1;
    previousPoint1 = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
    
    [points addObject:[NSValue valueWithCGPoint:currentPoint]];
    
    // calculate mid point
    CGPoint mid1 = midPoint(previousPoint1, previousPoint2);
    CGPoint mid2 = midPoint(currentPoint, previousPoint1);
    
    UIGraphicsBeginImageContext(self.imageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.imageView.image drawInRect:CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height)];
    
    CGContextMoveToPoint(context, mid1.x, mid1.y);
    // Use QuadCurve is the key
    CGContextAddQuadCurveToPoint(context, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y);
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextStrokePath(context);
    
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.delegate != nil) {
        [delegate selectedAreaPoints:points];
    }
    [self initialize];
}



@end
