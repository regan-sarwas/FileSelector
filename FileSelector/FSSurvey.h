//
//  FSSurvey.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTableViewItemCollection.h"

@interface FSSurvey : NSObject <FSTableViewItem>
@property (nonatomic, strong) NSString *title;
@end
