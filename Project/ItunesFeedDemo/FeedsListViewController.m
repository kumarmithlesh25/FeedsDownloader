//
//  FeedsListViewController.m
//  ItunesFeedDemo
//
//  Created by Mithlesh Jha on 11/08/17.
//  Copyright © 2017 Mithlesh Jha. All rights reserved.
//

#import "FeedsListViewController.h"
#import "FeedDownloader.h"
#import "ItemModel.h"
#import "FeedItemCell.h"
#import "ImageDownloader.h"

#define kFeedResponseKeyAlbum @"im:name"
#define kFeedResponseKeyArtist @"im:artist"
#define kFeedResponseKeyImages @"im:image"
#define kFeedResponseKeyIconUrlLabel @"label"

#define kRequestURL @"https://itunes.apple.com/us/rss/topalbums/limit=25/json"

@interface FeedsListViewController () {
    NSArray *_datasource;
    NSMutableDictionary *_imageDownloaders;
}

@end

@implementation FeedsListViewController

- (void) setDatasource:(NSArray*)datasource {
    _datasource = datasource;
}

- (void) dealloc {
    [self stopAllDownloads];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageDownloaders = [NSMutableDictionary new];
    
    NSURL *url = [NSURL URLWithString:kRequestURL];
    __weak typeof(self)weakSelf = self;
    
    [FeedDownloader fetchFeeds:url withCompletionHandler:^(NSError *error ,NSArray *entries){
        if (error == nil) {
            @try {
                NSMutableArray *items = [NSMutableArray new];
                for (NSDictionary *feedDictioanry in entries) {
                    NSString *album = feedDictioanry[kFeedResponseKeyAlbum][kFeedResponseKeyIconUrlLabel];
                    NSString *artist = feedDictioanry[kFeedResponseKeyArtist][kFeedResponseKeyIconUrlLabel];
                    NSString *iconLabel = [feedDictioanry[kFeedResponseKeyImages] firstObject][kFeedResponseKeyIconUrlLabel];
                    
                    ItemModel *model = [[ItemModel alloc] init];
                    model.albumName = album;
                    model.artistName = artist;
                    model.iconURLString = iconLabel;
                    
                    [items addObject:model];
                }
                
               [weakSelf setDatasource:items.copy];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        } else {
            // Handle error
        }
    }];
}

- (void) stopAllDownloads {
    NSArray *activeImageDownloaders = _imageDownloaders.allValues;
    [activeImageDownloaders makeObjectsPerformSelector:@selector(cancelDownload)];
    [_imageDownloaders removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self stopAllDownloads];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedItemCell *cell = (FeedItemCell*)[tableView dequeueReusableCellWithIdentifier:@"feedItemCell" forIndexPath:indexPath];
    ItemModel *model = _datasource[indexPath.row];
    cell.lblTitle.text = model.albumName;
    cell.lblSubtitle.text = model.artistName;
    
    if (model.icon == nil) {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
            [self downloadIconForModel:model atIndexPath:indexPath];
        }
    } else {
        cell.icon.image = model.icon;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    // Cancel icon download for the cell that goes offsecreen.
    ImageDownloader *imageDownloader = _imageDownloaders[indexPath];
    [imageDownloader cancelDownload];
}


#pragma mark - Table cell image support

- (void)downloadIconForModel:(ItemModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    ImageDownloader *imageDownloader = _imageDownloaders[indexPath];
    if (imageDownloader == nil) {
        imageDownloader = [[ImageDownloader alloc] init];
        imageDownloader.model = model;
        [imageDownloader setCompletionHandler:^{
            FeedItemCell *cell = (FeedItemCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.icon.image = model.icon;
            [_imageDownloaders removeObjectForKey:indexPath];
            
        }];
        (_imageDownloaders)[indexPath] = imageDownloader;
        [imageDownloader startDownload];
    }
}

- (void)loadImagesForOnscreenRows
{
    if (_datasource.count > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            ItemModel *model = (_datasource)[indexPath.row];
            
            if (!model.icon)
            {
#warning Possible improvement
                // Possible improvement. Check for if there was an attempt made to download the icon previously which results in error. Depending upon retry policy for the undelying error, we should either attempt to download again or bail out and show a placeholder icon.
                
                
                [self downloadIconForModel:model atIndexPath:indexPath];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}




@end
