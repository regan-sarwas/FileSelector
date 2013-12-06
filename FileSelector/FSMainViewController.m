//
//  FSMainViewController.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/13/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

//FIXME: merge this with FSMainIpadViewController

#import "FSMainViewController.h"
#import "SurveySelectViewController.h"
#import "MapSelectViewController.h"
//FIXME: this is only needed at the main VC for testing
#import "ProtocolSelectViewController.h"
#import "SurveyCollection.h"
#import "MapCollection.h"
#import "ProtocolCollection.h"


@interface FSMainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *selectSurveyButton;
@property (weak, nonatomic) IBOutlet UIButton *selectMapButton;
@property (weak, nonatomic) IBOutlet UILabel *surveyLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapLabel;
@property (strong, nonatomic) SurveyCollection* surveys;
//FIXME: change names
@property (strong, nonatomic) MapCollection* maps;
@end

@implementation FSMainViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configureView
{
    self.selectSurveyButton.enabled = NO;
    self.surveys = [[SurveyCollection alloc] init];
    [self.surveys openWithCompletionHandler:^(BOOL success) {
        //do any other background work;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectSurveyButton.enabled = YES;
            [self updateView];
        });
    }];

    self.selectMapButton.enabled = NO;
    self.maps = [[MapCollection alloc] init];
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

- (void) updateView
{
    if (self.surveys.selectedSurvey) {
        self.surveyLabel.text = self.surveys.selectedSurvey.title;
    }
    if (self.maps.selectedLocalMap) {
        self.mapLabel.text = self.maps.selectedLocalMap.title;
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Select Survey"]){
        SurveySelectViewController *vc = (SurveySelectViewController *)segue.destinationViewController;
        vc.title = segue.identifier;
        vc.items = self.surveys;
        return;
    }

    if ([segue.identifier isEqualToString:@"Select Map"]) {
        MapSelectViewController *vc = (MapSelectViewController *)segue.destinationViewController;
        vc.title = segue.identifier;
        vc.items = self.maps;
        return;
    }
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
    if ([MapCollection collectsURL:url]) {
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
