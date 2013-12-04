//
//  FSSurveyCollection.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTableViewItemCollection.h"
#import "SProtocol.h"

@interface FSSurveyCollection : NSObject <FSTableViewItemCollection>
@property (nonatomic, strong) NSIndexPath * selectedIndex;

//FIXME - this should be private, it is public temporarily as a convenience for the subclass
@property (strong,nonatomic) NSMutableArray *items;

//Does this collection manage the provided URL?
+ (BOOL) collectsURL:(NSURL *)url;

// builds the list, and current selection from the filesystem and user defaults
- (void)openWithCompletionHandler:(void (^)(BOOL success))completionHandler;

// opens a file from the App delegate
- (BOOL)openURL:(NSURL *)url;

- (NSIndexPath *)newSurveyWithProtocol:(SProtocol *)protcol;

@end
