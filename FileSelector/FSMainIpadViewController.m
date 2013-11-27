//
//  FSMainIpadViewController.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSMainIpadViewController.h"
#import "ProtocolSelectViewController.h"
#import "SurveySelectViewController.h"
#import "MapSelectViewController.h"
#import "FSSurveyCollection.h"
#import "FSMapCollection.h"
#import "ProtocolCollection.h"

@interface FSMainIpadViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barTitle;
@property (strong, nonatomic) FSSurveyCollection* surveys;
@property (strong, nonatomic) FSMapCollection* maps;
@property (strong, nonatomic) ProtocolCollection* protocols;

@end

@implementation FSMainIpadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configureView];
}

- (void) configureView
{
    self.surveys = [[FSSurveyCollection alloc] init];
    [self.surveys openWithCompletionHandler:^(BOOL success) {
        //do any other background work;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateTitle];
        });
    }];
    self.maps = [[FSMapCollection alloc] init];
    [self.maps openWithCompletionHandler:^(BOOL success) {
        //do any other background work;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateTitle];
        });
    }];
    self.protocols = [[ProtocolCollection alloc] init];
    [self.protocols openWithCompletionHandler:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateTitle];
}


-(void) updateTitle
{
    self.barTitle.title = [NSString stringWithFormat:@"%@ - %@",
                           (self.surveys.selectedIndex ? self.surveys.selectedItem.title : @"Select Survey"),
                           (self.maps.selectedIndex ? self.maps.selectedItem.title : @"Select Map")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *nav = (UINavigationController *)segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"Select Survey"]){
        SurveySelectViewController *vc = (SurveySelectViewController *)nav.childViewControllers[0];
        vc.title = segue.identifier;
        vc.items = self.surveys;
        vc.protocols = (id<FSTableViewItemCollection>)self.protocols;
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            vc.popover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            vc.popover.delegate = self;
            vc.popoverDismissedCallback = ^{[self updateTitle];};
        }
        return;
    }
    if ([segue.identifier isEqualToString:@"Select Map"]) {
        MapSelectViewController *vc = (MapSelectViewController *)nav.childViewControllers[0];
        vc.title = segue.identifier;
        vc.items = self.maps;
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            vc.popover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            vc.popover.delegate = self;
            vc.popoverDismissedCallback = ^{[self updateTitle];};
        }
        return;
    }
//    if ([segue.identifier isEqualToString:@"Select Protocol"]) {
//        //ProtocolSelectViewController *vc = (ProtocolSelectViewController *)segue.destinationViewController;
//        ProtocolSelectViewController *vc = (ProtocolSelectViewController *)nav.childViewControllers[0];
//        vc.title = segue.identifier;
//        vc.items = (id<FSTableViewItemCollection>)self.protocols;
//        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
//            vc.popover = ((UIStoryboardPopoverSegue *)segue).popoverController;
//            vc.popover.delegate = self;
//            vc.rowSelectedCallback = ^(NSIndexPath *i){[self updateTitle];};
//        }
//    }
}

// not called when popover is dismissed programatically
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self updateTitle];
}


- (BOOL) openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL success = NO;
    if ([FSSurveyCollection collectsURL:url])
        success = [self.surveys openURL:url];
    if ([FSMapCollection collectsURL:url])
        success = [self.maps openURL:url];
    if ([ProtocolCollection collectsURL:url])
        success = [self.protocols openURL:url];
    if (!success) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't open file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Thanks" message:@"I should do something now." delegate:nil cancelButtonTitle:@"Do it later" otherButtonTitles:nil] show];
    }
    return success;
}


@end
