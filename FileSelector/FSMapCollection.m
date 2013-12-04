//
//  FSMapCollection.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSMapCollection.h"
#import "FSMap.h"

@interface FSMapCollection ()
@property (nonatomic, strong) NSMutableArray *items;
//@property (nonatomic, strong) NSIndexPath * selectedIndex;
@property (nonatomic) BOOL isLoaded;
@end
@implementation FSMapCollection

//maps, be sure to set the file attribute to do not backup.

@synthesize selectedIndex;

- (NSMutableArray *)items
{
    if (!_items) {
        _items = [NSMutableArray new];
    }
    return _items;
}

- (NSIndexPath *)addNewItem
{
    //insert at head
    //[self.items insertObject:[FSSurvey new] atIndex:0];
    //return [NSIndexPath indexPathForRow:0 inSection:0];
    //insert at end
    [self.items addObject:[FSMap new]];
    return [NSIndexPath indexPathForRow:(self.items.count-1) inSection:0];
}

-(id<FSTableViewItem>)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.items[indexPath.row];
}

- (id<FSTableViewItem>)selectedItem
{
    return [self itemAtIndexPath:[self selectedIndex]];
}

- (Survey *)selectedSurvey
{
    return self.items[self.selectedIndex.row];
}


- (NSIndexPath *)newSurveyWithProtocol:(SProtocol *)protocol {
    //insert at top of list
    [self.items insertObject:[[Survey alloc] initWithProtocol:protocol] atIndex:0];
    return [NSIndexPath indexPathForRow:0 inSection:0];
}


- (int)itemCount
{
    return self.items.count;
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
}

-(void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UI has already done all appropriate verification, honor the request as sent
    [self.items removeObjectAtIndex:indexPath.row];
    //TODO: delete the file
    if (indexPath.row < self.selectedIndex.row) {
        self.selectedIndex = [NSIndexPath indexPathForRow:(self.selectedIndex.row - 1)
                                                inSection:self.selectedIndex.section];
    }
    if ([indexPath isEqual:self.selectedIndex]) {
        self.selectedIndex = nil;
    }

}


- (BOOL)openURL:(NSURL *)url
{
    //FIXME: just do it
    return YES;
}

+ (BOOL) collectsURL:(NSURL *)url
{
    return [[url pathExtension] isEqualToString:MAP_EXT];
}

- (void)refreshWithCompletionHandler:(void (^)(BOOL))completionHandler;
{
    //FIXME: implement
}

- (void)openWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    if (self.isLoaded) {
        if (completionHandler) completionHandler(YES);
    } else {
        dispatch_async(dispatch_queue_create("gov.nps.akr.observer", DISPATCH_QUEUE_CONCURRENT), ^{
            self.items = [self getLocalMaps];
            BOOL success = self.items != nil;
            //TODO: open each survey item in the background?
            [self saveCache];
            self.isLoaded = YES;
            if (completionHandler) {
                completionHandler(success);
            }
        });
    }
}

- (NSMutableArray *)getLocalMaps
{
    return [NSMutableArray new];
}

- (void)saveCache
{

}

@end
