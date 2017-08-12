//
//  ImageDownloader.h
//  ItunesFeedDemo
//
//  Created by Mithlesh Jha on 12/08/17.
//  Copyright © 2017 Mithlesh Jha. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ItemModel;

@interface ImageDownloader : NSObject

@property (nonatomic, strong) ItemModel *model;
@property (nonatomic, copy) void(^completionHandler)(void);

- (void) startDownload;
- (void) cancelDownload;

@end
