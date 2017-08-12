//
//  FeedDownloader.m
//  ItunesFeedDemo
//
//  Created by Mithlesh Jha on 12/08/17.
//  Copyright © 2017 Mithlesh Jha. All rights reserved.
//

#import "FeedDownloader.h"

@implementation FeedDownloader

+ (void) callHandler:(void (^)(NSError *error, NSArray *feeds))completionHandler withFeeds:(NSArray*)feeds error:(NSError*)error {
    if (completionHandler) {
        completionHandler (error, feeds);
    }
}

+ (BOOL) fetchFeeds:(NSURL *)url withCompletionHandler:( void (^)(NSError *error, NSArray *feeds))completionHandler {
    
    // Check network and return NO if no network.
    // Check valid url else return NO
    if (!url) {
        return NO;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSURLResponse *response = nil;
        NSError *error = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        
        if (httpResponse && httpResponse.statusCode / 100 == 2) {
            if (data.length > 0) {
                NSDictionary *responseDictionary = nil;
                @try {
                    responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                } @catch (NSException *exception) {
                    error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"An error occurred in parsing the response"}];
                    NSLog(@"Can't parse data");
                } @finally {
                    NSArray *entries = responseDictionary[@"feed"][@"entry"];
                    [FeedDownloader callHandler:completionHandler withFeeds:entries error:error];
                }
            } else {
                if (error == nil) {
                    error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"Could not read data"}];
                }
                [FeedDownloader callHandler:completionHandler withFeeds:nil error:error];
            }
        } else {
            if (error == nil) {
                error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Network connection failed with respose status %ld", (long)httpResponse.statusCode]}];
            }
            [FeedDownloader callHandler:completionHandler withFeeds:nil error:error];
        }
    });
    
    return YES;
}

@end
