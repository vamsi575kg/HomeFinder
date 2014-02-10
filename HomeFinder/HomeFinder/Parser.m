//
//  Parser.m
//  SEWA
//
//  Created by VamsiKrishna on 04/01/13.
//  Copyright (c) 2013 Neologix. All rights reserved.
//

#import "Parser.h"

#import "ParserResponse.h"

static NSString * const BOUNDRY = @"0xKhTmLbOuNdArY";
static NSString * const FORM_FLE_INPUT = @"uploaded";

@implementation Parser
@synthesize _delegate;
@synthesize _urlRequest;
@synthesize _onSuccess, _onFailurer;


- (id)requestWithString:(NSString *)url withData:(NSData *)postData withDelegate:(id)delegate{
    
    if (!delegate) {
        return nil;
    }
    
    [self set_delegate:delegate];
    

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: postData];

    
    _urlRequest = request;
    
    return self;
}

- (id)requestWithString:(NSString *)url withImageFile:(NSString *)filePath withData:(NSString *)poststring withDataKey:(NSString *)keystring withDelegate:(id)delegate{
    
    if (!delegate) {
        return nil;
    }
    
    [self set_delegate:delegate];
    
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BOUNDRY]       forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postData = [NSMutableData data];
    
    if ([filePath length] == 0) {
        
        [postData appendData: [[NSString stringWithFormat:@"--%@\r\n", BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", FORM_FLE_INPUT] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:nil];
        [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];

    }else{

        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [postData appendData: [[NSString stringWithFormat:@"--%@\r\n", BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"mashimage.jpg\"\r\n\r\n", FORM_FLE_INPUT] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:data];
        [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];

    }
    
    
    
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n",BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //append object and keys
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",keystring] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"%@",poststring] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",BOUNDRY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [urlRequest setHTTPBody:postData];

    _urlRequest = urlRequest;
    
    return self;
}



- (id)requestWithString:(NSString *)url withDelegate:(id)delegate{
    
    if (!delegate) {
        return nil;
    }
    
    [self set_delegate:delegate];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];  
    
    _urlRequest = request;
    
    return self;
}


- (void)setDidFinishSelector:(SEL)onFinish{
    [self set_onSuccess:onFinish];
}

- (void)setDidFailSelector:(SEL)onWentWrong{
    [self set_onFailurer:onWentWrong];
}

- (ParserResponse *)compileData:(NSData *)_data withUrlResponse:(id)_response withArray:(id)_array{
    NSString *_str = [[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    ParserResponse *obj = [[ParserResponse alloc] initWith:_str withData:_data withUrlResponse:_response withArray:_array];
    
    _str = nil;
    return obj;
}

- (void)releaseInstances{
    _delegate = nil;
    _urlRequest = nil;
    _onSuccess = nil;
    _onFailurer = nil;
    _ServerResponse = nil;
    _Data = nil;
}
- (void)sendSynchronous{
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:_urlRequest returningResponse:&response error:&error];
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    
    NSData *jsonData = [result dataUsingEncoding:NSASCIIStringEncoding];
   // NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
  //  NSLog(@"JSON: %@", jsonDict);
   NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    //NSArray *responseArray = [result JSONValue];

    if (responseData) {
        ParserResponse *resultObj = [self compileData:responseData withUrlResponse:response withArray:responseArray ];
        [_delegate performSelectorOnMainThread:_onSuccess withObject:resultObj waitUntilDone:YES];
    }
    else {
        [_delegate performSelectorOnMainThread:_onFailurer withObject:error waitUntilDone:YES];
    }
    
    error = nil;
    response = nil;
    responseData = nil;
    responseArray =nil;
    [self releaseInstances];
    
}

- (void) sendAsynchronous {
    if (_IsFetching){
        return;
    }
    
    @synchronized(self){
        @try{
            _IsFetching = YES;
            
			[[NSURLCache sharedURLCache] setMemoryCapacity:0];
			[[NSURLCache sharedURLCache] setDiskCapacity:0];
            
			_URLConnection = [[NSURLConnection alloc] initWithRequest:_urlRequest delegate:self];
		}
		@catch (NSException *exc){
			return;
		}
    }
}

#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // Access has failed two times...
    if ([challenge previousFailureCount] > 1)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Authentication Error" message:@"Too many unsuccessul login attempts." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
    }
    else
    {
        // Answer the challenge
        NSURLCredential *cred = [[NSURLCredential alloc] initWithUser:@""
                                                             password:@""
                                                          persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if(!_delegate) return;
	_ServerResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(!_delegate) return;
	
	if(!_Data){
		_Data = [data mutableCopy];
	}
	else {
		[(NSMutableData *)_Data appendData: data];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	if(!_delegate) return;
	
    _IsFetching = NO;
    
    [_delegate performSelectorOnMainThread:_onFailurer withObject:error waitUntilDone:YES];
    
    [self releaseInstances];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	
    if(!_delegate) return;
    _IsFetching = NO;
    
//    NSString *result = [[NSString alloc] initWithData:_Data encoding:NSUTF8StringEncoding];
//    
//    NSString *temp = result;
//    
//    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
//    temp = [temp stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
//    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@" "];

    NSError *error = nil;
   // NSData *jsonData = [temp dataUsingEncoding:NSASCIIStringEncoding];
    
    _Array = [NSJSONSerialization JSONObjectWithData:_Data options:kNilOptions error:&error];

    ParserResponse *resultObj = [self compileData:_Data withUrlResponse:_ServerResponse withArray:_Array];
    [_delegate performSelectorOnMainThread:_onSuccess withObject:resultObj waitUntilDone:YES];
    
    [self releaseInstances];
    
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse{
	return request;
}
+ (NSString *)encodeUrlString:(NSString *)string{
    NSString *encodedString = string;
    //encodedString = [encodedString urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"\"" withString:@"_dblQt"];
    
    return encodedString;
}
+ (NSString *)dencodeUrlString:(NSString *)string{
    
    NSString *dencodedString = string;
   
    dencodedString = [dencodedString stringByReplacingOccurrencesOfString:@"_dblQt" withString:@"\""];
    
    
    return dencodedString;
}
+ (NSString *)jsonSerialization:(NSMutableDictionary *)dict{
    
    NSError *error = nil;
     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
     NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end

