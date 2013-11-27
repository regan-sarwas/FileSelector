//
//  MapSelectViewController.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/26/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSDetailViewController.h"
#import "FSEntryCell.h"
#import "ProtocolSelectViewController.h"
#import "MapSelectViewController.h"

@interface MapSelectViewController ()

@end

@implementation MapSelectViewController

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
	// Do any additional setup after loading the view, typically from a nib.

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[self.editButtonItem,spacer,addButton];

    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (FSDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];

}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:NO];
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
    [self insertNewObject];
    //[self performSegueWithIdentifier:@"Associate" sender:sender];
}

- (void)insertNewObject
{
    NSIndexPath *indexPath = [self.items addNewItem];
    if (indexPath) {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items itemCount]; //_objects.count;
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return ![indexPath isEqual:self.items.selectedIndex];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.items removeItemAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.items moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.items.selectedIndex = indexPath;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //id<FSTableViewItem> item = [self.items itemAtIndexPath:indexPath];
        //self.detailViewController.detailItem = item;
        [self.popover dismissPopoverAnimated:YES];
        self.popoverDismissedCallback();
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Show Detail"]) {
        // seque from selected row
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //seque from accessory
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        id<FSTableViewItem> item = [self.items itemAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:item];
        //if we are in a popover, we what the popover to stay the size.
        [[segue destinationViewController] setPreferredContentSize:self.preferredContentSize];

    }
}

- (void) refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    [self.items refreshWithCompletionHandler:^(BOOL success) {
        //on abackground thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            if (success) {
                //FIXME - get incremental updates with a delegate
                [self.tableView reloadData];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't connect to server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        });
    }];
}

@end
