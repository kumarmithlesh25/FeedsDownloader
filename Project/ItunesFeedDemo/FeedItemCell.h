//
//  FeedItemCell.h
//  ItunesFeedDemo
//
//  Created by Mithlesh Jha on 11/08/17.
//  Copyright © 2017 Mithlesh Jha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@end
