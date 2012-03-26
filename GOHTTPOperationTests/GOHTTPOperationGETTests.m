//
//  GOHTTPOperationTests.m
//  GOHTTPOperationTests
//
//  Created by Samuel Goodwin on 3/26/12.
//  Copyright (c) 2012 SNAP Interactive. All rights reserved.
//

#import "GOHTTPOperationGETTests.h"
#import "GOHTTPOperation.h"

@implementation GOHTTPOperationGETTests

- (void)setUp{
    [super setUp];
    NSURL *url = [NSURL URLWithString:@"http://google.com"];
    _operation = [GOHTTPOperation operationWithURL:url method:GOHTTPMethodGET];
}

- (void)tearDown{
    [super tearDown];
}

- (void)testProperSetup{
    STAssertNotNil([_operation request], @"Better have a legit request");
    STAssertEqualObjects(@"GET", [[_operation request] HTTPMethod], @"Better be using the right http method");
}

- (void)testDidRecieveResponse{
    [_operation connection:nil didReceiveResponse:nil];
    STAssertTrue([[_operation data] length] == 0, @"Better start with empty data");
}

- (void)testDidReceiveData{
    NSData *data = [@"Hey sup?" dataUsingEncoding:NSUTF8StringEncoding];
    [_operation connection:nil didReceiveData:data];
    STAssertTrue([data length] == [[_operation data] length], @"Better hold onto the data we've received (%i vs %i)", [data length], [[_operation data] length]);
    STAssertTrue([data isEqualToData:[_operation data]], @"Better hold the data accurately");
}

- (void)testDidFailWithError{
    [_operation connection:nil didFailWithError:nil];
    STAssertTrue([_operation isFinished], @"Better finish if things fail");
    STAssertFalse([_operation isExecuting], @"Better finish if things fail");
}

- (void)testDidFinishLoading:(NSURLConnection *)connection{
    [_operation connectionDidFinishLoading:nil];
    STAssertTrue([_operation isFinished], @"Better finish if things finish");
    STAssertFalse([_operation isExecuting], @"Better finish if things finish");
}



@end
