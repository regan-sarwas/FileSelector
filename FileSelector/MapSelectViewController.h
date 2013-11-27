//
//  MapSelectViewController.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/26/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTableViewItemCollection.h"

@class FSDetailViewController;

@interface MapSelectViewController : UITableViewController

@property (strong, nonatomic) FSDetailViewController *detailViewController;
@property (nonatomic, weak) id<FSTableViewItemCollection> items;
@property (nonatomic, weak) ProtocolCollection *protocols;
@property (nonatomic, weak) UIPopoverController *popover;
@property (copy) void (^popoverDismissedCallback)(void);

@end
