//
//  MapDetailViewController.m
//  FileSelector
//
//  Created by Regan Sarwas on 12/5/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "MapDetailViewController.h"

@interface MapDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation MapDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //FIXME: Autolayout bug? - title height in landscape is set by title height in portrait
    self.nameLabel.text = self.map.version ? [NSString stringWithFormat:@"%@, v. %@", self.map.title, self.map.version] : self.map.title;
    self.dateLabel.text = self.map.dateString;
    //FIXME: AutoLayout issue - details not taking all available space in popover
    self.descriptionLabel.text = self.map.isLocal ? self.map.details : @"Download the protocol for more details.";
}

@end
