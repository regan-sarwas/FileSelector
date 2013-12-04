//
//  SurveyCollection.m
//  FileSelector
//
//  Created by Regan Sarwas on 12/3/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "SurveyCollection.h"
#import "Survey.h"

@interface SurveyCollection()
//FIXME:  The following should be private properties.
//They are public temporarily as a convenience for the subclass
//@property (strong,nonatomic) NSMutableArray *items;
//@property (strong, nonatomic) FSSurvey* selectedSurvey;
@end

@implementation SurveyCollection

- (NSMutableArray *)items
{
    if (!_items) {
        _items = [NSMutableArray new];
    }
    return _items;
}

-(id<FSTableViewItem>)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.items[indexPath.row];
}

-(void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UI has already done all appropriate verification, honor the request as sent
    [self.items removeObjectAtIndex:indexPath.row];

    if (indexPath.row < self.selectedIndex.row) {
        self.selectedIndex = [NSIndexPath indexPathForRow:(self.selectedIndex.row - 1)
                                                inSection:self.selectedIndex.section];
    }
    if ([indexPath isEqual:self.selectedIndex]) {
        self.selectedIndex = nil;
    }

}

//FIXME: remove (requires deleting adopted interface)
- (NSIndexPath *)addNewItem
{
    return nil;
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

- (id<FSTableViewItem>)selectedItem
{
    return [self itemAtIndexPath:[self selectedIndex]];
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

- (void)openWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    //TODO: implement openWithCompletionHandler
    //See protocol for an example.
    //read cache and initialize ordered object collection with cache, do not load UIDocuments

    //maps, be sure to set the file attribute to do not backup.
    BOOL success = YES;
    if (completionHandler) {
        completionHandler(success);
    }
}

- (BOOL)openURL:(NSURL *)url
{
    //FIXME: just do it
    return YES;
}

+ (BOOL) collectsURL:(NSURL *)url
{
    return [[url pathExtension] isEqualToString:SURVEY_EXT];
}

- (void)refreshWithCompletionHandler:(void (^)(BOOL))completionHandler;
{
    //FIXME: implement
}


@end
