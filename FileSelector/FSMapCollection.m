//
//  FSMapCollection.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSMapCollection.h"
#import "FSMap.h"

@implementation FSMapCollection

- (NSIndexPath *)addNewItem
{
    //insert at head
    //[self.items insertObject:[FSSurvey new] atIndex:0];
    //return [NSIndexPath indexPathForRow:0 inSection:0];
    //insert at end
    [self.items addObject:[FSMap new]];
    return [NSIndexPath indexPathForRow:(self.items.count-1) inSection:0];
}

@end
