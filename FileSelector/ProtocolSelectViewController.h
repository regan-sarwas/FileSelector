//
//  ProtocolSelectViewController.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/20/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTableViewItemCollection.h"
#import "ProtocolCollection.h"

@class FSDetailViewController;

@interface ProtocolSelectViewController : UITableViewController

@property (strong, nonatomic) FSDetailViewController *detailViewController;
@property (nonatomic, weak) ProtocolCollection *items;
@property (nonatomic) BOOL showRemoteItems;
@property (nonatomic, weak) UIPopoverController *popover;
//@property (copy) void (^popoverDismissedCallback)(void);
@property (copy) void (^rowSelectedCallback)(NSIndexPath *indexPath);

@end
