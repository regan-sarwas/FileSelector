//
//  FSMasterViewController.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/13/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSDetailViewController;

@interface FSMasterViewController : UITableViewController

@property (strong, nonatomic) FSDetailViewController *detailViewController;

@end
