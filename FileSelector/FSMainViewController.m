//
//  FSMainViewController.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/13/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSMainViewController.h"
#import "SurveySelectViewController.h"
#import "MapSelectViewController.h"
//FIXME - this is only needed at the main VC for testing
#import "ProtocolSelectViewController.h"
#import "FSSurveyCollection.h"
#import "FSMapCollection.h"
#import "ProtocolCollection.h"


@interface FSMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *surveyLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapLabel;
//FIXME - change names
@property (strong, nonatomic) FSSurveyCollection* surveys;
@property (strong, nonatomic) FSMapCollection* maps;
@property (strong, nonatomic) ProtocolCollection* protocols;
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
    self.surveys = [[FSSurveyCollection alloc] init];
    [self.surveys openWithCompletionHandler:^(BOOL success) {
        //do any other background work;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateView];
        });
    }];
    self.maps = [[FSMapCollection alloc] init];
    [self.maps openWithCompletionHandler:^(BOOL success) {
        //do any other background work;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateView];
        });
    }];
    self.protocols = [[ProtocolCollection alloc] init];
    [self.protocols openWithCompletionHandler:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateView];
}

- (void) updateView
{
    if (self.surveys.selectedIndex) {
        self.surveyLabel.text = self.surveys.selectedItem.title;
    }
    if (self.maps.selectedIndex) {
        self.mapLabel.text = self.maps.selectedItem.title;
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Select Survey"]){
        SurveySelectViewController *vc = (SurveySelectViewController *)segue.destinationViewController;
        vc.title = segue.identifier;
        vc.items = self.surveys;
        vc.protocols = (id<FSTableViewItemCollection>)self.protocols;
        return;
    }

    if ([segue.identifier isEqualToString:@"Select Map"]) {
        MapSelectViewController *vc = (MapSelectViewController *)segue.destinationViewController;
        vc.title = segue.identifier;
        vc.items = self.maps;
        return;
    }
//    if ([segue.identifier isEqualToString:@"Select Protocol"]) {
//        ProtocolSelectViewController *vc = (ProtocolSelectViewController *)segue.destinationViewController;
//        vc.title = segue.identifier;
//        vc.items = (id<FSTableViewItemCollection>)self.protocols;
//    }
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
