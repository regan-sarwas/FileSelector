//
//  FSTableViewObjectCollection.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSTableViewItem <NSObject>
@property (nonatomic, strong) NSString *title;
- (NSString *) description;
- (UIImage *) thumbnail;
@end

@protocol FSTableViewItemCollection <NSObject>
- (NSIndexPath *) addNewItem;
- (int) itemCount;
- (void) removeItemAtIndexPath:(NSIndexPath *)indexPath;
- (void) moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (id<FSTableViewItem>) itemAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, strong) NSIndexPath * selectedIndex;
- (id<FSTableViewItem>) selectedItem;
@end

