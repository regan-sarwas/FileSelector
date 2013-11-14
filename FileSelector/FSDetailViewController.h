//
//  FSDetailViewController.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/13/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTableViewItemCollection.h"

@interface FSDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id<FSTableViewItem> detailItem;

@end
