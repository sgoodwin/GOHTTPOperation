//
//  GOFakeHTTPProtocol.m
//  GOHTTPOperation
//
//  Created by Samuel Goodwin on 3/31/12.
//  Copyright (c) 2012 SNAP Interactive. All rights reserved.
//

#import "GOFakeHTTPProtocol.h"

@interface NSHTTPURLResponse(UndocumentedInitializer)
- (id)initWithURL:(NSURL*)URL statusCode:(NSInteger)statusCode headerFields:(NSDictionary*)headerFields requestTime:(double)requestTime;
@end

@implementation GOFakeHTTPProtocol

static NSInteger _statusCode = 200;
static NSData *_fakeData = nil;
static NSDictionary *_headers = nil;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    NSURL *url = [request URL];
    return [[url scheme] isEqualToString:@"http"];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    return request;
}

+ (void)setFakeStatusCode:(NSInteger)code{
    _statusCode = code;
}

+ (void)setFakeResponseData:(NSData *)data{
    _fakeData = [data copy];
}

+ (void)setFakeHeaders:(NSDictionary *)headers{
    _headers = [headers copy];
}

- (NSCachedURLResponse *)cachedResponse {
	return nil;
}

- (void)startLoading{
    id<NSURLProtocolClient> client = [self client];
    NSURLRequest *request = [self request];
    
    if(_fakeData){
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request URL] statusCode:_statusCode headerFields:_headers requestTime:0.0];
        
        [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocol:self didLoadData:_fakeData];
        [client URLProtocolDidFinishLoading:self];
    }else{
        NSError *error = [NSError errorWithDomain:@"com.goodwinlabs.httpError" code:12 userInfo:nil];
        [client URLProtocol:self didFailWithError:error];
    }
}

- (void)stopLoading{}

@end
