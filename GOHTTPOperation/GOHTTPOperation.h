//
//  GOHTTPOperation.h
//  GOImageCache
//
//  Created by Samuel Goodwin on 12/30/11.
//

#import <Foundation/Foundation.h>

typedef enum{
    GOHTTPMethodGET,
    GOHTTPMethodPOST
}GOHTTPMethod;

typedef void (^GODataBlock)(NSData* data);
typedef void (^GOFailureBlock)(NSInteger statusCode, NSData *data);

@interface GOHTTPOperation : NSOperation<NSURLConnectionDelegate, NSURLDownloadDelegate>
@property (assign, getter=isExecuting) BOOL executing;
@property (assign, getter=isFinished) BOOL finished;
@property (strong) NSMutableData *data;
@property (assign) NSInteger statusCode;

@property (retain) NSMutableArray *completions;
@property (retain) NSMutableArray *failures;
@property (strong) NSURLRequest *request;

+ (id)operationWithURL:(NSURL*)url method:(GOHTTPMethod)method;
- (void)addCompletion:(GODataBlock)block;
- (void)addFailure:(GOFailureBlock)block;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end
