//
//  FSMapCollection.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "SurveyCollection.h"
#import "FSTableViewItemCollection.h"

@interface FSMapCollection : NSObject <FSTableViewItemCollection>

//Does this collection manage the provided URL?
+ (BOOL) collectsURL:(NSURL *)url;

// builds the list, and current selection from the filesystem and user defaults
- (void)openWithCompletionHandler:(void (^)(BOOL success))completionHandler;

// opens a file from the App delegate
- (BOOL)openURL:(NSURL *)url;

@end
