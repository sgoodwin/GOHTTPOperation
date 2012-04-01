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
}

- (void)tearDown{
    [NSURLProtocol unregisterClass:[GOFakeHTTPProtocol class]];
    [super tearDown];
}

- (void)waitUntilFinished:(dispatch_semaphore_t)semaphor withTimeout:(NSTimeInterval)timeout{
    while(dispatch_semaphore_wait(semaphor, DISPATCH_TIME_NOW)){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeout]];
    }
}

- (void)testBasicGET{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [GOFakeHTTPProtocol setFakeStatusCode:200];
    [GOFakeHTTPProtocol setFakeResponseData:[@"hey sup?" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *url = [NSURL URLWithString:@"http://google.com/basicGET"];
    GOHTTPOperation *operation = [GOHTTPOperation operationWithURL:url method:GOHTTPMethodGET];
    [operation addCompletion:^(NSData *data) {
        STAssertNotNil(data, @"Missing response data");        
        dispatch_semaphore_signal(semaphore);
    }];
    [operation addFailure:^(NSInteger statusCode, NSData *data){
        STFail(@"This should never be called");
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
    
    [self waitUntilFinished:semaphore withTimeout:10.0];
}

- (void)testBasicGETFailure{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURL *url = [NSURL URLWithString:@"http://google.com"];
    GOHTTPOperation *operation = [GOHTTPOperation operationWithURL:url method:GOHTTPMethodGET];
    [operation addCompletion:^(NSData *data) {
        STFail(@"This should not happen");
    }];
    [operation addFailure:^(NSInteger statusCode, NSData *data){
        STAssertTrue(YES, @"Success");
        
        dispatch_semaphore_signal(semaphore);
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
    
    [self waitUntilFinished:semaphore withTimeout:10.0];
}

- (void)test400StatusCode{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
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
        
        dispatch_semaphore_signal(semaphore);
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
    
    [self waitUntilFinished:semaphore withTimeout:10.0];
}

@end
