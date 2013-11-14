//
//  FSMainViewController.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/13/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSMainViewController.h"
#import "FSMasterViewController.h"
#import "FSSurveyCollection.h"
#import "FSMapCollection.h"


@interface FSMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *surveyLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapLabel;
@property (strong, nonatomic) FSSurveyCollection* surveys;
@property (strong, nonatomic) FSMapCollection* maps;
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
    //FIXME, get initial selection from NSDefaults
    self.surveys = [[FSSurveyCollection alloc] init];
    self.maps = [[FSMapCollection alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
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
    FSMasterViewController *vc = (FSMasterViewController *)segue.destinationViewController;
    vc.title = segue.identifier;
    if ([segue.identifier isEqualToString:@"Select Survey"])
    {
        vc.items = self.surveys;
    } else {
        vc.items = self.maps;
    }
}

@end
