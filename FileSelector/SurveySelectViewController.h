//
//  SurveySelectViewController.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/26/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKRTableViewItemCollection.h"
#import "ProtocolCollection.h"
#import "SurveyCollection.h"

@class FSDetailViewController;

@interface SurveySelectViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) FSDetailViewController *detailViewController;
@property (nonatomic, weak) SurveyCollection *items;
@property (nonatomic, weak) UIPopoverController *popover;
@property (copy) void (^popoverDismissedCallback)(void);

@end
