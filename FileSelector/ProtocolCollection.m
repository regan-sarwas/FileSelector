//
//  ProtocolCollection.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/18/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "ProtocolCollection.h"
#import "SProtocol.h"
#import "NSArray+map.h"
#import "NSURL+unique.h"

@interface ProtocolCollection()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSURL *documentsDirectory;
@property (nonatomic, strong) NSURL *protocolDirectory;
@property (nonatomic, strong) NSURL *inboxDirectory;
@property (nonatomic, strong) NSURL *cacheFile;
@end

@implementation ProtocolCollection

//FIXME - move these to a better location in the code
- (SProtocol *)localProtocolAtIndex:(NSUInteger)index
{
    return self.items[index];
}

- (SProtocol *)remoteProtocolAtIndex:(NSUInteger)index
{
    return self.items[index];
}

-(NSUInteger)numberOfLocalProtocols
{
    return self.items.count;
}

-(NSUInteger)numberOfRemoteProtocols
{
    return self.items.count;
}

#pragma mark - private properties

- (NSMutableArray *)items
{
    if (!_items) {
        _items = [NSMutableArray new];
    }
    return _items;
}

- (NSURL *)documentsDirectory
{
    if (!_documentsDirectory) {
        _documentsDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    }
    return _documentsDirectory;
}

- (NSURL *)protocolDirectory
{
    if (!_protocolDirectory) {
        _protocolDirectory = [self.documentsDirectory URLByAppendingPathComponent:PROTOCOL_DIR];
        if(![[NSFileManager defaultManager] fileExistsAtPath:[_protocolDirectory path]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[_protocolDirectory path]
                                      withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _protocolDirectory;
}

- (NSURL *)inboxDirectory
{
    if (!_inboxDirectory) {
        _inboxDirectory = [self.documentsDirectory URLByAppendingPathComponent:@"Inbox"];
    }
    return _inboxDirectory;
}

- (NSURL *)cacheFile
{
    if (!_cacheFile) {
        _cacheFile = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask][0];
        _cacheFile = [_cacheFile URLByAppendingPathComponent:@"protocol_list.cache"];
    }
    return _cacheFile;
}


#pragma mark - FSTableViewItemCollection

@synthesize selectedIndex;

-(id<FSTableViewItem>)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.items[indexPath.row];
}

- (id<FSTableViewItem>)selectedItem
{
    return [self itemAtIndexPath:[self selectedIndex]];
}

- (int)itemCount
{
    return self.items.count;
}

- (NSIndexPath *)addNewItem
{
    // method is required by FSTableViewItemCollection.h
    // but clients cannot add new Protocols (UI should enforce this)
    return nil;
}

- (void) moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSUInteger fromIndex = fromIndexPath.row;
    NSUInteger toIndex = toIndexPath.row;
    NSUInteger selected = self.selectedIndex.row;
    if (fromIndex == toIndex)
        return;
    if (self.items.count <= fromIndex || self.items.count <= toIndex)
        return;
    //adjust the selected Index
    if (fromIndex < selected && selected <= toIndex) {
        self.selectedIndex = [NSIndexPath indexPathForRow:(self.selectedIndex.row - 1)
                                                inSection:self.selectedIndex.section];
    }
    if (toIndex <= selected && selected < fromIndex) {
        self.selectedIndex = [NSIndexPath indexPathForRow:(self.selectedIndex.row + 1)
                                                inSection:self.selectedIndex.section];
    }
    //move the item
    id temp = self.items[fromIndex];
    [self.items removeObjectAtIndex:fromIndex];
    [self.items insertObject:temp atIndex:toIndex];
    [self saveCache];
}

-(void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
    SProtocol *item = [self.items objectAtIndex:indexPath.row];
    if (!item.isLocal) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtURL:item.url error:nil];
    [self.items removeObjectAtIndex:indexPath.row];
    [self saveCache];
    //update the selected index
    if (indexPath.row < self.selectedIndex.row) {
        self.selectedIndex = [NSIndexPath indexPathForRow:(self.selectedIndex.row - 1)
                                                inSection:self.selectedIndex.section];
    }
    if (self.items.count == 0) {
        self.selectedIndex = nil;
    }
}

#pragma mark - public methods


+ (BOOL) collectsURL:(NSURL *)url
{
    return [[url pathExtension] isEqualToString:PROTOCOL_EXT];
}

- (void)openWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    dispatch_async(dispatch_queue_create("gov.nps.akr.observer", DISPATCH_QUEUE_CONCURRENT), ^{
        [self loadCache];
        [self moveIncomingDocuments];
        [self syncWithFileSystem];
        [self saveCache];
        if (completionHandler) {
            completionHandler(YES);
        }
    });
}

- (BOOL)openURL:(NSURL *)url
{
    return [self openURL:url saveCache:YES];
}


- (void)refreshWithCompletionHandler:(void (^)(BOOL))completionHandler;
{
    //TODO update filesystem ?
    
    //FIXME - get URL from settings
    NSURL *url = [NSURL URLWithString:@"http://akrgis.nps.gov/observer/protocols/list.json"];
    [self refreshFromURL:url completionHandler:completionHandler];
}

-(void)prepareToDownloadSelectedItem:(NSIndexPath *)indexPath
{
    [self.items[indexPath.row] prepareToDownload];
}

- (void)downloadSelectedItemWithCompletionHandler:(void (^)(BOOL success))completionHandler
{
    dispatch_async(dispatch_queue_create("gov.nps.akr.observer", DISPATCH_QUEUE_CONCURRENT), ^{
        SProtocol *protocol = (SProtocol *)self.selectedItem;
        NSURL *newUrl = [self.protocolDirectory URLByAppendingPathComponent:protocol.url.lastPathComponent];
        newUrl = [newUrl URLByUniquingPath];
        BOOL success = [((SProtocol *)self.selectedItem) downloadToURL:newUrl];
        [self saveCache];
        if (completionHandler) {
            completionHandler(success);
        }
    });
}



#pragma mark - private methods

//TODO - consider NSDefaults as it does memeory mapping and defered writes
- (void) loadCache
{
    NSArray *plist = [NSArray arrayWithContentsOfURL:self.cacheFile];
    self.items = [plist mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:obj];
    }];
}

- (void) saveCache
{
    dispatch_async(dispatch_queue_create("gov.nps.akr.observer", DISPATCH_QUEUE_CONCURRENT), ^{
        NSArray *plist = [self.items mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            return [NSKeyedArchiver archivedDataWithRootObject:obj];
        }];
        [plist writeToURL:self.cacheFile atomically:YES];
    });
}

- (BOOL)openURL:(NSURL *)url saveCache:(BOOL)save
{
    NSURL *newUrl = [self.protocolDirectory URLByAppendingPathComponent:url.lastPathComponent];
    newUrl = [newUrl URLByUniquingPath];
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtURL:url toURL:newUrl error:&error];
    if (error) {
        NSLog(@"ProtocolCollection.openURL: Unable to copy %@ to %@; error: %@",url, newUrl, error);
        return NO;
    }
    SProtocol *protocol = [[SProtocol alloc] initWithURL:newUrl];
    if (!protocol.values) {
        NSLog(@"data in %@ was not a valid protocol object",url.lastPathComponent);
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:newUrl error:nil];
        return NO;
    }
    if ([self.items containsObject:protocol])
    {
        NSLog(@"We already have the protocol in %@.  Ignoring the duplicate.",url.lastPathComponent);
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:newUrl error:nil];
        return YES;
    }
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    [self.items insertObject:protocol atIndex:0];
    //FIXME - call delegate to update UI
    if (save) {
        [self saveCache];
    }
    return YES;
}


- (void) moveIncomingDocuments
{
    for (NSURL *directory in @[self.inboxDirectory, self.documentsDirectory]) {
        NSError *error = nil;
        NSArray *array = [[NSFileManager defaultManager]
                          contentsOfDirectoryAtURL:directory
                          includingPropertiesForKeys:nil
                          options:(NSDirectoryEnumerationSkipsHiddenFiles)
                          error:&error];
        if (array == nil) {
            NSLog(@"Unable to enumerate %@: %@",[directory lastPathComponent], error.localizedDescription);
        } else {
            for (NSURL *doc in array) {
                if ([doc.pathExtension isEqualToString:PROTOCOL_EXT]) {
                    [self openURL:doc saveCache:NO];
                }
            }
        }
    }
}

- (void)syncWithFileSystem
{
    //urls in the protocols directory
    NSMutableArray *urls = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager]
                                                    contentsOfDirectoryAtURL:self.protocolDirectory
                                                    includingPropertiesForKeys:nil
                                                    options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                    error:nil]];
    //remove cache items not in filesystem
    NSMutableIndexSet *itemsToRemove = [NSMutableIndexSet new];
    for (int i = 0; i < self.items.count; i++) {
        SProtocol *p = self.items[i];
        if (p.isLocal) {
            NSUInteger index = [urls indexOfObject:p.url];
            if (index == NSNotFound) {
                [itemsToRemove addIndex:i];
            } else {
                [urls removeObjectAtIndex:index];
            }
        }
    }
    [self.items removeObjectsAtIndexes:itemsToRemove];
    //FIXME - call delegate to update UI

    //add filesystem urls not in cache
    for (NSURL *url in urls) {
        SProtocol *protocol = [[SProtocol alloc] initWithURL:url];
        if (!protocol.values) {
            NSLog(@"data at %@ was not a valid protocol object",url);
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        }
        //[self.items addObject:protocol];
        [self.items insertObject:protocol atIndex:0];
        //FIXME - call delegate to update UI
    }
    [self checkAndFixSelectedIndex];
}

- (void)refreshFromURL:(NSURL *)url completionHandler:(void (^)(BOOL))completionHandler;
{
    dispatch_async(dispatch_queue_create("gov.nps.akr.observer", DISPATCH_QUEUE_CONCURRENT), ^{
        BOOL success = NO;
        NSMutableArray *serverProtocols = [self fetchProtocolListFromURL:url];
        if (serverProtocols) {
            [self syncCacheWithServerProtocols:serverProtocols];
            success = YES;
        }
        if (completionHandler) {
            completionHandler(success);
        }
    });
}

- (NSMutableArray *)fetchProtocolListFromURL:(NSURL *)url
{
    NSMutableArray *protocols = nil;
    //TODO - does this work with a remote URL?
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([json isKindOfClass:[NSArray class]])
        {
            protocols = [NSMutableArray new];
            NSArray *items = json;
            for (id jsonItem in items) {
                if ([jsonItem isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *item = jsonItem;
                    SProtocol *protocol = [[SProtocol alloc] initWithURL:[NSURL URLWithString:item[@"url"]]
                                                                     title:item[@"name"]
                                                                   version:item[@"version"]
                                                                      date:item[@"date"]];
                    if (protocol) {
                        [protocols addObject:protocol];
                    }
                }
            }
        }
    }
    return protocols;
}

-  (void)syncCacheWithServerProtocols:(NSMutableArray *)serverProtocols
{
    // we need to remove cached items not on the server,
    // we need to add items on the server not in the cache,
    // Do not add server items that match local items in the cache.
    // a cached item (on the server) might have an updated URL
    // option1 - remove all server protocols, and add new ones - simple, however all UI items would need to be reloaded
    // option2 - do incremental per item update (only update UI as necessary)
    // FIXME - currently I have implemented option2, but the UI does a bulk update, since it doesn't know what has updated 
    
    BOOL cacheNeedsResave = NO;

    //remove cached server items not the server
    NSMutableIndexSet *itemsToRemove = [NSMutableIndexSet new];
    for (int i = 0; i < self.items.count; i++) {
        SProtocol *p = self.items[i];
        if (!p.isLocal) {
            NSUInteger index = [serverProtocols indexOfObject:p];
            if (index == NSNotFound) {
                [itemsToRemove addIndex:i];
                cacheNeedsResave = YES;
            } else {
                //update the url of cached server objects
                SProtocol *serverProtocol = serverProtocols[index];
                if (![p.url isEqual:serverProtocol.url]) {
                    self.items[i] = serverProtocol;
                }
                [serverProtocols removeObjectAtIndex:index];
            }
        }
    }
    [self.items removeObjectsAtIndexes:itemsToRemove];
    //FIXME - call delegate to update UI

    //add server protocols not in cache (local or server)
    for (Protocol *protocol in serverProtocols) {
        if (![self.items containsObject:protocol]) {
            [self.items addObject:protocol];
            //FIXME - call delegate to update UI
            cacheNeedsResave = YES;
        }
    }
    [self checkAndFixSelectedIndex];
    if (cacheNeedsResave) {
        [self saveCache];
    }
}

- (void) checkAndFixSelectedIndex
{
    if (self.itemCount <= self.selectedIndex.row) {
        if (self.items.count == 0) {
            self.selectedIndex = nil;
        } else {
            self.selectedIndex = [NSIndexPath indexPathForRow:(self.itemCount - 1)
                                                    inSection:self.selectedIndex.section];
        }
    }
}


@end
