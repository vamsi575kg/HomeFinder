//
//  ParserResponse.h
//  SEWA
//
//  Created by VamsiKrishna on 08/01/13.
//  Copyright (c) 2013 Neologix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParserResponse : NSObject

@property (strong, nonatomic) NSArray *responseArray;
@property (strong, nonatomic) NSData *responseData;
@property (strong, nonatomic) NSString *responseString;
@property (strong, nonatomic) id urlResponse;

- (ParserResponse *)initWith:(NSString *)responseStr withData:(NSData *)responseData withUrlResponse:(NSHTTPURLResponse *)urlResponse withArray:(NSArray *)responseArray;

@end
