//
//  FSMainIpadViewController.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//


//FIXME: merge this with FSMainViewController
#import "FSMainIpadViewController.h"
#import "ProtocolSelectViewController.h"
#import "SurveySelectViewController.h"
#import "MapSelectViewController.h"
#import "SurveyCollection.h"
#import "FSMapCollection.h"
#import "ProtocolCollection.h"

@interface FSMainIpadViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectSurveyButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectMapButton;
@property (strong, nonatomic) SurveyCollection* surveys;
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
    [self configureView];
}

- (void) configureView
{
    self.selectSurveyButton.enabled = NO;
    self.surveys = [[SurveyCollection alloc] init];
    [self.surveys openWithCompletionHandler:^(BOOL success) {
        //do any other background work;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectSurveyButton.enabled = YES;
            if (self.surveys.selectedSurvey) {
                self.barTitle.title = @"Loading Survey...";
                [self.surveys.selectedSurvey openDocumentWithCompletionHandler:^(BOOL success) {
                    //do any other background work;
                    dispatch_async(dispatch_get_main_queue(), ^{[self setupNewSurvey];});
                }];
            } else {
                [self updateView];
            }
        });
    }];

    self.selectMapButton.enabled = NO;
    self.maps = [[FSMapCollection alloc] init];
    [self.maps openWithCompletionHandler:^(BOOL success) {
        //do any other background work;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectMapButton.enabled = YES;
            [self updateView];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateView];
}

- (void)updateView
{
    [self updateTitle];
}

-(void) updateTitle
{
    self.barTitle.title = [NSString stringWithFormat:@"%@ - %@",
                           (self.surveys.selectedSurvey ? self.surveys.selectedSurvey.title : @"Select Survey"),
                           (self.maps.selectedIndex ? self.maps.selectedItem.title : @"Select Map")];
}

- (void)setupNewSurvey
{
    [self updateTitle];
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
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            vc.popover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            vc.popover.delegate = self;
            vc.popoverDismissedCallback = ^{
                self.barTitle.title = @"Loading Survey...";
                [self.surveys.selectedSurvey openDocumentWithCompletionHandler:^(BOOL success) {
                    //do any other background work;
                    dispatch_async(dispatch_get_main_queue(), ^{[self setupNewSurvey];});
                }];
            };
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
}

// not called when popover is dismissed programatically - use callbacks instead
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self updateTitle];
}


- (BOOL) openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL success = NO;
    if ([SurveyCollection collectsURL:url]) {
        success = [self.surveys openURL:url];
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't open file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            //FIXME: update UI for new survey)
            [[[UIAlertView alloc] initWithTitle:@"Thanks" message:@"I should do something now." delegate:nil cancelButtonTitle:@"Do it later" otherButtonTitles:nil] show];
        }
    }
    if ([FSMapCollection collectsURL:url]) {
        success = [self.maps openURL:url];
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't open file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            //FIXME: update UI for new map)
            [[[UIAlertView alloc] initWithTitle:@"Thanks" message:@"I should do something now." delegate:nil cancelButtonTitle:@"Do it later" otherButtonTitles:nil] show];
        }
    }

    //FIXME: this isn't working when the Protocol view is up
    //I need to make sure I am getting the protocol collection it is using, and make sure updates are going to the delegate.
    if ([ProtocolCollection collectsURL:url]) {
        ProtocolCollection *protocols = [ProtocolCollection sharedCollection];
        [protocols openWithCompletionHandler:^(BOOL success) {
            SProtocol *protocol = [protocols openURL:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (protocol) {
                    [[[UIAlertView alloc] initWithTitle:@"New Protocol" message:@"Do you want to create a new survey file with this protocol?" delegate:nil cancelButtonTitle:@"Maybe Later" otherButtonTitles:@"Yes", nil] show];
                    //FIXME: read the response, and acta accordingly
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't open file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            });
        }];
    }

    return success;
}


@end
