//
//  Parser.h
//  SEWA
//
//  Created by VamsiKrishna on 04/01/13.
//  Copyright (c) 2013 Neologix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParserResponse.h"

@interface Parser : NSObject{
    
    NSURLConnection *_URLConnection;
    NSURLResponse *_ServerResponse;
    NSData *_Data;
    NSArray *_Array;
    BOOL _IsFetching;
}

@property NSMutableURLRequest *_urlRequest;
@property SEL _onSuccess;
@property SEL _onFailurer;
@property id _delegate;

- (id)requestWithString:(NSString *)url withDelegate:(id)delegate;
- (id)requestWithString:(NSString *)url withData:(NSData *)postData withDelegate:(id)delegate;
- (void)setDidFinishSelector:(SEL)onFinish;
- (void)setDidFailSelector:(SEL)onWentWrong;
- (void)sendSynchronous;
- (void)sendAsynchronous;
- (void)releaseInstances;

- (ParserResponse *)compileData:(NSData *)_data withUrlResponse:(id)_response withArray:(id)_array;
- (id)requestWithString:(NSString *)url withImageFile:(NSString *)filePath withData:(NSString *)poststring withDataKey:(NSString *)keystring withDelegate:(id)delegate;

+ (NSString *)encodeUrlString:(NSString *)string;
+ (NSString *)dencodeUrlString:(NSString *)string;
+ (NSString *)jsonSerialization:(NSMutableDictionary *)dict;
@end
