//
//  ParserResponse.m
//  SEWA
//
//  Created by VamsiKrishna on 08/01/13.
//  Copyright (c) 2013 Neologix. All rights reserved.
//

#import "ParserResponse.h"

@implementation ParserResponse

@synthesize responseArray;
@synthesize responseData;
@synthesize responseString;
@synthesize urlResponse;

- (ParserResponse *)initWith:(NSString *)responseStr withData:(NSData *)resData withUrlResponse:(NSHTTPURLResponse *)urlRes withArray:(NSArray *)responseArr{
    
    [self setResponseArray:responseArr];
    [self setResponseString:responseStr];
    [self setResponseData:resData];
    [self setUrlResponse:urlRes];
    
    return self;
}
@end
