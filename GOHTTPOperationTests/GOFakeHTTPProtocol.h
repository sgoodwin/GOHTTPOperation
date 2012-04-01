//
//  GOFakeHTTPProtocol.h
//  GOHTTPOperation
//
//  Created by Samuel Goodwin on 3/31/12.
//  Copyright (c) 2012 SNAP Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOFakeHTTPProtocol : NSURLProtocol

+ (void)setFakeStatusCode:(NSInteger)code;
+ (void)setFakeResponseData:(NSData *)data;
+ (void)setFakeHeaders:(NSDictionary *)headers;

@end
