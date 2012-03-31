//
//  GOHTTPOperation.m
//  GOImageCache
//
//  Created by Samuel Goodwin on 12/30/11.
//

#import "GOHTTPOperation.h"

@interface GOHTTPOperation()
- (void)finish;
- (void)requestOnMainThread;
@end

@implementation GOHTTPOperation
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize statusCode = _statusCode;
@synthesize completions = _completions;
@synthesize failures = _failures;
@synthesize request = _request;
@synthesize data = _data;

+ (id)operationWithURL:(NSURL*)url method:(GOHTTPMethod)method{
    GOHTTPOperation *operation = [[self alloc] init];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    switch(method){
        case GOHTTPMethodGET:
            [request setHTTPMethod:@"GET"];
            break;
        case GOHTTPMethodPOST:
            [request setHTTPMethod:@"POST"];
            break;
    }
    [request setTimeoutInterval:10.0];
    [operation setRequest:request];
    [operation setCompletions:[NSMutableArray array]];
    [operation setFailures:[NSMutableArray array]];
    return operation;
}

- (BOOL)isConcurrent{
    return YES;
}

- (void)start{
    if(self.isCancelled){
        [self finish];
        return; 
    }
    
    [self performSelectorOnMainThread:@selector(requestOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)requestOnMainThread{
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    if(connection){
        [connection start];
    }else{
        [self finish];
        return;
    }
}

- (void)finish{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)addCompletion:(GODataBlock)block{
    [self.completions addObject:[block copy]];
}

- (void)addFailure:(GOFailureBlock)block{
    [self.failures addObject:[block copy]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if(self.isCancelled){
        [connection cancel];
        [self finish];
        return;
    }
    self.statusCode = [(NSHTTPURLResponse*)response statusCode];
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(self.isCancelled){
        [connection cancel];
        [self finish];
        return;
    }
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.failures enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GOFailureBlock block = obj;
        block(self.statusCode, self.data);
    }];
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if(self.statusCode != 200){
        [self.failures enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            GOFailureBlock block  = obj;
            block(self.statusCode, self.data);
        }];
        return;
    }
    [self.completions enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        GODataBlock block = obj;
        block(self.data);
    }];
    [self finish];
}

@end
