//
//  SurveySelectViewController.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/26/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSDetailViewController.h"
#import "FSEntryCell.h"
#import "ProtocolSelectViewController.h"
#import "SurveySelectViewController.h"
#import "SProtocol.h"

@interface SurveySelectViewController ()
@property (nonatomic) BOOL isBackgroundRefreshing;
@property (strong, nonatomic) ProtocolCollection* protocols;
@end

@implementation SurveySelectViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[self.editButtonItem,spacer,addButton];

    self.detailViewController = (FSDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];

    addButton.enabled = NO;
    self.protocols = [ProtocolCollection sharedCollection];
    [self.protocols openWithCompletionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            addButton.enabled = YES;
        });
    }];
}

- (void) configureView
{
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:NO];
    [ProtocolCollection releaseSharedCollection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!self.items) {
        return;
    }
    //[self insertNewObject];
    [self performSegueWithIdentifier:@"Select Protocol" sender:sender];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items itemCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    id<FSTableViewItem> item = [self.items itemAtIndexPath:indexPath];
    cell.titleTextField.text = item.title;
    cell.detailsLabel.text = item.subtitle;
    cell.thumbnailImageView.image = item.thumbnail;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.items.selectedIndex = indexPath;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.popover dismissPopoverAnimated:YES];
        self.popoverDismissedCallback();
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // allow moving but not deleting the current (selected) survey
    return [indexPath isEqual:self.items.selectedIndex] ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.items moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //FIXME: check and alert if this survey has unsynced data.
        [self.items removeItemAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}





- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Show Detail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        id<FSTableViewItem> item = [self.items itemAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:item];
        //if we are in a popover, we want the new vc to stay the same size.
        [[segue destinationViewController] setPreferredContentSize:self.preferredContentSize];
    }
    if ([[segue identifier] isEqualToString:@"Select Protocol"]) {
        ProtocolSelectViewController *vc = (ProtocolSelectViewController *)segue.destinationViewController;
        vc.title = segue.identifier;
        vc.items = (id<FSTableViewItemCollection>)self.protocols;
        vc.rowSelectedCallback = ^(NSIndexPath *indexPath){
            [self newSurveyWithProtocol:[self.protocols localProtocolAtIndex:indexPath.row]];
        };
        //if we are in a popover, we want the new vc to stay the same size.
        [[segue destinationViewController] setPreferredContentSize:self.preferredContentSize];
    }
}

- (void) refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    self.isBackgroundRefreshing = YES;
    [self.items refreshWithCompletionHandler:^(BOOL success) {
        //on abackground thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.isBackgroundRefreshing = NO;
            if (success) {
                //to avoid a multi-threaded race condition, the delegate is not called during a refresh.  Therefore bulk reload is required.
                [self.tableView reloadData];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"I failed to refresh.  Try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        });
    }];
}


- (void) newSurveyWithProtocol:(SProtocol *)protocol
{
    NSLog(@"New survey with protocol %@", protocol.title);
    NSIndexPath *indexPath = [self.items newSurveyWithProtocol:protocol];
    if (indexPath) {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
