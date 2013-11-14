//
//  FSSurveyCollection.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTableViewItemCollection.h"

@interface FSSurveyCollection : NSObject <FSTableViewItemCollection>
@property (nonatomic, strong) NSIndexPath * selectedIndex;
//FIXME - this should be private, it is public temporarily as a convenience for the subclass
@property (strong,nonatomic) NSMutableArray *items;

@end
