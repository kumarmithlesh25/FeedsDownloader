//
//  ImageDownloader.m
//  ItunesFeedDemo
//
//  Created by Mithlesh Jha on 12/08/17.
//  Copyright © 2017 Mithlesh Jha. All rights reserved.
//

#import "ImageDownloader.h"
#import "ItemModel.h"

#define kIconSize 40

@interface ImageDownloader ()

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;


@end

@implementation ImageDownloader

- (void) startDownload {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.model.iconURLString]];
    self.dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        
        
        if (error == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                
                // This change is done on local branch. We'll now create a pull request and merge it back to master.
                
                // Set appIcon and clear temporary data/image
                UIImage *image = [[UIImage alloc] initWithData:data];
                
                if (image.size.width != kIconSize || image.size.height != kIconSize) {
                    CGSize itemSize = CGSizeMake(kIconSize, kIconSize);
                    UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                    [image drawInRect:imageRect];
                    self.model.icon = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else {
                    self.model.icon = image;
                }
                
                // call our completion handler to tell our client that our icon is ready for display
                if (self.completionHandler != nil) {
                    self.completionHandler();
                }
            }];
        }
    }];
    
    [self.dataTask resume];
}

- (void) cancelDownload {
    [self.dataTask cancel];
    self.dataTask = nil;
}

@end
