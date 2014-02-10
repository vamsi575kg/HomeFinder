//
//  NSValue+MyKeyCategory.m
//  HomeFinder
//
//  Created by vamsi krishna on 07/02/14.
//  Copyright (c) 2014 vamsikrishna. All rights reserved.
//

#import "NSValue+MyKeyCategory.h"

@implementation NSValue (MyKeyCategory)
- (id)valueForKey:(NSString *)key
{
    if (strcmp([self objCType], @encode(CGPoint)) == 0) {
        CGPoint p = [self CGPointValue];
        if ([key isEqualToString:@"x"]) {
            return @(p.x);
        } else if ([key isEqualToString:@"y"]) {
            return @(p.y);
        }
    }
    return [super valueForKey:key];
}
@end
