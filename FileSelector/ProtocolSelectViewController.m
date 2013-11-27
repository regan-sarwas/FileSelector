//
//  ProtocolSelectViewController.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/20/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "ProtocolSelectViewController.h"
#import "ProtocolDetailViewController.h"
#import "ProtocolTableViewCell.h"
#import "SProtocol.h"

@interface ProtocolSelectViewController ()
@property (nonatomic) BOOL showAllItems;
@property (nonatomic, strong) UITableViewCell *showAllCell;
@property (nonatomic, strong) UIButton *showAllButton;
@end

@implementation ProtocolSelectViewController

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

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[self.editButtonItem]; //,spacer,addButton];

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


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.items.numberOfLocalProtocols;
    }
    if (section == 1 && self.showRemoteItems) {
        return self.items.numberOfRemoteProtocols;
    }
    if (section == 2) {
        return 1;
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"On this device";
    }
    if (section == 1 && self.showRemoteItems ) {
        return @"In the cloud";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProtocolButtonCell" forIndexPath:indexPath];
        cell.textLabel.textColor = cell.tintColor;
        cell.textLabel.text = self.showRemoteItems ? @"Show Only Downloaded Protocols" : @"Show All Protocols";
        return cell;
    } else {
        SProtocol *item = (indexPath.section == 0) ? [self.items localProtocolAtIndex:indexPath.row] : [self.items remoteProtocolAtIndex:indexPath.row];
        NSString *identifier = (indexPath.section == 0) ? @"LocalProtocolCell" : @"RemoteProtocolCell";
        ProtocolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.titleLabel.text = item.title;
        cell.subtitleLabel.text = item.subtitle;
        //cell.downloadImageView.hidden = item.isLocal;  //FIXME hide if downloading
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        self.showRemoteItems = ! self.showRemoteItems;
        [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:YES];
        return;
    }

    if (indexPath.section == 1) {
        [self downloadItem:indexPath];
        return;
    }

    [self.items setSelectedProtocol:indexPath.row];
    //SProtocol *item = (SProtocol*)[self.items itemAtIndexPath:indexPath];
    //if (!item.isLocal) {
    //    [self downloadItem:indexPath];
    //} else {
        if (self.popover) {
            [self.popover dismissPopoverAnimated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (self.rowSelectedCallback) {
            self.rowSelectedCallback(indexPath);
        }
    //}
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section < 2;
    //if (indexPath.row >= self.items.itemCount) return NO;
    //SProtocol *item = (SProtocol *)[self.items itemAtIndexPath:indexPath];
    //return item.isLocal;
    //return indexPath.row < self.items.itemCount;  //allow all rows to be re-ordered (except the button at end).
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section < 2;
    //if (indexPath.row >= self.items.itemCount) return NO;
    //SProtocol *item = (SProtocol *)[self.items itemAtIndexPath:indexPath];
    //return item.isLocal;
    //return indexPath.row < self.items.itemCount;  //allow all rows to be re-ordered (except the button at end).
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return (proposedDestinationIndexPath.section == sourceIndexPath.section) ? proposedDestinationIndexPath : sourceIndexPath;

    //    if (proposedDestinationIndexPath.section == sourceIndexPath.section) {
    //        return proposedDestinationIndexPath;
    //    } else {
    //        return sourceIndexPath;
    //    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0  ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;

    //SProtocol *item = (SProtocol *)[self.items itemAtIndexPath:indexPath];
//    if (indexPath.section == 0) {
//        return UITableViewCellEditingStyleDelete;
//    } else {
//        return UITableViewCellEditingStyleNone;
//    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.items moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.items removeItemAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}





- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Protocol Details"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        SProtocol *item = (SProtocol *)[self.items itemAtIndexPath:indexPath];
        ProtocolDetailViewController *vc = (ProtocolDetailViewController *)[segue destinationViewController];
        vc.title = segue.identifier;
        vc.protocol =item;
        //if we are in a popover, we want the popover to stay the same size.
        [vc setPreferredContentSize:self.preferredContentSize];
    }
}

//if called by a button, not the built in editing controls
//- (void) delete:(NSIndexPath *)indexPath
//{
//    [self.items removeItemAtIndexPath:indexPath];
//    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//}

- (void) refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    self.showRemoteItems = YES;
    UITableView *tableView = self.tableView;
    [self.items refreshWithCompletionHandler:^(BOOL success) {
        //on abackground thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            if (success) {
                //FIXME - get incremental updates with a delegate
                [tableView reloadData];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't connect to server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        });
    }];
}

- (void) downloadItem:(NSIndexPath *)indexPath
{
    [self.items prepareToDownloadSelectedItem:indexPath];
    UITableView *tableView = self.tableView;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //ProtocolTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProtocolCell" forIndexPath:indexPath];
    //cell.downloadImageView.hidden = YES;
    //cell.subtitleLabel.text = @"Downloading...";
    //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    [self.items downloadSelectedItemWithCompletionHandler:^(BOOL success) {
        //on background thread
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
               [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't download protocol" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
    }];
}


//- (void) toggleShowAll:(UIButton *)sender
//{
//    self.showAllItems = !self.showAllItems;
//    [self.showAllButton setTitle:(self.showAllItems ? @"Show Only Downloaded Protocols" : @"Show All Protocols") forState:UIControlStateNormal];
//    self.showAllButton.frame = self.showAllCell.contentView.bounds;
//    //FIXME get and save in NSDefaults
//}
//
//- (UIButton *) showAllButton
//{
//    if (!_showAllButton)
//    {
//        _showAllButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [_showAllButton setTitle:(self.showAllItems ? @"Show Only Downloaded Protocols" : @"Show All Protocols") forState:UIControlStateNormal];
//        [_showAllButton addTarget:self action:@selector(toggleShowAll:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _showAllButton;
//}
//
////FIXME - cell is not resized with change in orientation.
//- (UITableViewCell *) showAllCell
//{
//    if (!_showAllCell) {
//        _showAllCell = [[UITableViewCell alloc] init];
//        self.showAllButton.frame = _showAllCell.contentView.bounds;
//        [_showAllCell.contentView addSubview:self.showAllButton];
//        /*
//        NSDictionary *views = @{@"button":self.showAllButton};
//        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[button]-0-|" options:0 metrics:nil views:views];
//        [_showAllCell.contentView addConstraints:constraints];
//        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[button]-0-|" options:0 metrics:nil views:views];
//        [_showAllCell.contentView addConstraints:constraints];
//         */
//    }
//    return _showAllCell;
//}

@end
