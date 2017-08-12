//
//  FeedDownloader.h
//  ItunesFeedDemo
//
//  Created by Mithlesh Jha on 12/08/17.
//  Copyright © 2017 Mithlesh Jha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedDownloader : NSObject

+ (BOOL) fetchFeeds:(NSURL *)url withCompletionHandler:( void (^)(NSError *error, NSArray *feeds))completionHandler;

@end
