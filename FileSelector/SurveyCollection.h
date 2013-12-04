//
//  SurveyCollection.h
//  FileSelector
//
//  Created by Regan Sarwas on 12/3/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTableViewItemCollection.h"
#import "SProtocol.h"
#import "Survey.h"

@interface SurveyCollection : NSObject

//<FSTableViewItemCollection>
//@property (nonatomic, strong) NSIndexPath * selectedIndex;
//@property (nonatomic, strong, readonly) Survey *selectedSurvey;

//Does this collection manage the provided URL?
+ (BOOL) collectsURL:(NSURL *)url;

// builds the list, and current selection from the filesystem and user defaults
- (void)openWithCompletionHandler:(void (^)(BOOL success))completionHandler;

// opens a file from the App delegate
- (BOOL)openURL:(NSURL *)url;

- (NSInteger)newSurveyWithProtocol:(SProtocol *)protcol;


// UITableView DataSource Support
- (NSUInteger) numberOfSurveys;
- (Survey *) surveyAtIndex:(NSUInteger)index;
- (void) removeSurveyAtIndex:(NSUInteger)index;
- (void) moveSurveyAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void) setSelectedSurvey:(NSUInteger)index;
- (Survey *)selectedSurvey;

@end
