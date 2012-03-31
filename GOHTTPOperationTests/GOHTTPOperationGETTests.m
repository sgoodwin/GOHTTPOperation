//
//  GOHTTPOperationGETTests.m
//  GOHTTPOperation
//
//  Created by Samuel Goodwin on 3/31/12.
//  Copyright (c) 2012 SNAP Interactive. All rights reserved.
//

#import "GOHTTPOperationGETTests.h"
#import "GOFakeHTTPProtocol.h"
#import "GOHTTPOperation.h"

@implementation GOHTTPOperationGETTests

- (void)setUp{
    [super setUp];
    [NSURLProtocol registerClass:[GOFakeHTTPProtocol class]];
    [GOFakeHTTPProtocol setFakeResponseData:nil];
    [GOFakeHTTPProtocol setFakeStatusCode:200];
    
    _semaphore = dispatch_semaphore_create(0);
}

- (void)tearDown{
    [NSURLProtocol unregisterClass:[GOFakeHTTPProtocol class]];
    [super tearDown];
}

- (void)waitUntilFinished:(NSTimeInterval)timeout{
    while(dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_NOW)){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

- (void)testBasicGET{
    [GOFakeHTTPProtocol setFakeResponseData:[@"hey sup?" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *url = [NSURL URLWithString:@"http://google.com"];
    GOHTTPOperation *operation = [GOHTTPOperation operationWithURL:url method:GOHTTPMethodGET];
    [operation addCompletion:^(NSData *data) {
        STAssertNotNil(data, @"Missing response data");
        
        dispatch_semaphore_signal(_semaphore);
    }];
    [operation addFailure:^(NSInteger statusCode, NSData *data){
        STFail(@"This should never be called");
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
    
    [self waitUntilFinished:10.0];
}

- (void)testBasicGETFailure{
    NSURL *url = [NSURL URLWithString:@"http://google.com"];
    GOHTTPOperation *operation = [GOHTTPOperation operationWithURL:url method:GOHTTPMethodGET];
    [operation addCompletion:^(NSData *data) {
        STFail(@"This should not happen");
    }];
    [operation addFailure:^(NSInteger statusCode, NSData *data){
        STAssertTrue(YES, @"Success");
        
        dispatch_semaphore_signal(_semaphore);
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
    
    [self waitUntilFinished:10.0];
}

- (void)test400StatusCode{
    NSInteger fakeCode = 404;
    [GOFakeHTTPProtocol setFakeStatusCode:fakeCode];
    [GOFakeHTTPProtocol setFakeResponseData:[@"hey sup?" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *url = [NSURL URLWithString:@"http://google.com"];
    GOHTTPOperation *operation = [GOHTTPOperation operationWithURL:url method:GOHTTPMethodGET];
    [operation addCompletion:^(NSData *data) {
        STFail(@"This should not happen");
    }];
    [operation addFailure:^(NSInteger statusCode, NSData *data){
        STAssertTrue(YES, @"Success");
        STAssertEquals(statusCode, fakeCode, @"%i == %i", statusCode, fakeCode);
        
        dispatch_semaphore_signal(_semaphore);
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
    
    [self waitUntilFinished:10.0];
}

@end
