//
//  Survey.h
//  FileSelector
//
//  Created by Regan Sarwas on 12/3/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTableViewItemCollection.h"
#import "SProtocol.h"

enum SurveyState {
    Created = 0,
    Modified = 1,
    Saved = 2
};

@interface Survey : NSObject <FSTableViewItem>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, readonly) enum SurveyState state;
@property (nonatomic, strong, readonly) NSDate *date;

@property (nonatomic, strong, readonly) NSString *subtitle;
@property (nonatomic, strong, readonly) UIImage *thumbnail;

//The following two methods will block the UI thread while IO is performed
//Use the open method first to initialize them on a background thread
@property (nonatomic, strong, readonly) SProtocol *protocol;
@property (nonatomic, strong, readonly) UIManagedDocument *document;

//Initializers
// init will always return nil
// This will return an unusable object (all properties will be null) until open is called.
+ (Survey *)surveyFromURL:(NSURL *)url withCompletionHandler:(void (^)(BOOL success))handler;
- (id)initWithProtocol:(SProtocol *)protcol;

//otheractions
- (void)syncWithCompletionHandler:(void (^)(NSError*))handler;
- (void)openWithCompletionHandler:(void (^)(NSError*))handler;
- (void)closeWithCompletionHandler:(void (^)(NSError*))handler;

@end
