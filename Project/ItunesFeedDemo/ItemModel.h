//
//  ItemModel.h
//  ItunesFeedDemo
//
//  Created by Mithlesh Jha on 12/08/17.
//  Copyright © 2017 Mithlesh Jha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ItemModel : NSObject

@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *iconURLString;

@property (nonatomic, strong) UIImage *icon;

@end
