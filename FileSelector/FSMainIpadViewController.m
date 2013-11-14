//
//  FSMainIpadViewController.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSMainIpadViewController.h"
#import "FSMasterViewController.h"
#import "FSSurveyCollection.h"
#import "FSMapCollection.h"

@interface FSMainIpadViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barTitle;
@property (strong, nonatomic) FSSurveyCollection* surveys;
@property (strong, nonatomic) FSMapCollection* maps;

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
    //FIXME, get initial selection from NSDefaults
    self.surveys = [[FSSurveyCollection alloc] init];
    self.maps = [[FSMapCollection alloc] init];
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
    FSMasterViewController *vc = (FSMasterViewController *)nav.childViewControllers[0];
    vc.title = segue.identifier;
    if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
        vc.popover = ((UIStoryboardPopoverSegue *)segue).popoverController;
        vc.popover.delegate = self;
        vc.popoverDismissedCallback = ^{[self updateTitle];};
    }
    if ([segue.identifier isEqualToString:@"Select Survey"])
    {
        vc.items = self.surveys;
    } else {
        vc.items = self.maps;
    }
}

// not called when popover is dismissed programatically
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self updateTitle];
}

@end
