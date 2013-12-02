//
//  ProtocolCollection.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/18/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

@class ProtocolCollection;


//Note that the data model will be changed on the background thread, as changes are made to the collections
//that are referenced by the table view, I must do the insert/delete/change on the mainthread with the call
//to update the UI, otherwise, I will get an internal inconsistency error

//FIXME: this should be a singleton, multiple instances will clash when saving state to the cache.

//FIXME: move protocol to a separate file
@protocol CollectionChanged <NSObject>
- (void) collection:(id)collection addedLocalItemsAtIndexes:(NSIndexSet *)indexSet;
- (void) collection:(id)collection addedRemoteItemsAtIndexes:(NSIndexSet *)indexSet;
- (void) collection:(id)collection removedLocalItemsAtIndexes:(NSIndexSet *)indexSet;
- (void) collection:(id)collection removedRemoteItemsAtIndexes:(NSIndexSet *)indexSet;
- (void) collection:(id)collection changedLocalItemsAtIndexes:(NSIndexSet *)indexSet;
- (void) collection:(id)collection changedRemoteItemsAtIndexes:(NSIndexSet *)indexSet;
@end

#import <Foundation/Foundation.h>
#import "FSTableViewItemCollection.h"
#import "SProtocol.h"

#define PROTOCOL_EXT @"obsprot"
#define PROTOCOL_DIR @"protocols"

@interface ProtocolCollection : NSObject //<FSTableViewItemCollection>

@property (nonatomic, weak) id<CollectionChanged> delegate;

// Does this collection manage the provided URL?
+ (BOOL) collectsURL:(NSURL *)url;

// builds the list, and current selection from the filesystem and user defaults
// This method does NOT send messsages to the delegate when items are added to the lists.
// so the UI should be updated in the completionHandler;
- (void)openWithCompletionHandler:(void (^)(BOOL success))completionHandler;

// Opens a file from Mail/Safari (via the App delegate)
// nil return indicates the URL could not be opened or is not valid.
// Will return an existing protocol if it already exists in the local collection.
// If the protocol exists in the remote list, it will be added to the local list and removed from the remote list.
// Will send messages to the delegate when/if the changes to the model occur.
- (SProtocol *)openURL:(NSURL *)url;

// UITableView DataSource Support
- (NSUInteger) numberOfLocalProtocols;
- (NSUInteger) numberOfRemoteProtocols;
- (SProtocol *) localProtocolAtIndex:(NSUInteger)index;
- (SProtocol *) remoteProtocolAtIndex:(NSUInteger)index;
- (void) removeLocalProtocolAtIndex:(NSUInteger)index;
- (void) moveLocalProtocolAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void) moveRemoteProtocolAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void) setSelectedLocalProtocol:(NSUInteger)index;
- (SProtocol *)selectedLocalProtocol;

// Download a Protocol from the server
- (void)prepareToDownloadProtocolAtIndex:(NSUInteger)index;
// On success, the delegate will be sent two messages, one to remove the remote item, the other to add the new local item.
// The completion handler is used only to signal success/failure
- (void)downloadProtocolAtIndex:(NSUInteger)index WithCompletionHandler:(void (^)(BOOL success))completionHandler;

// Refresh the list of remote protocols
// Will send message to the delegate as items are added/removed from the local/remote lists
// The completion handler is used only to signal success/failure
- (void) refreshWithCompletionHandler:(void (^)(BOOL success))completionHandler;

@end
