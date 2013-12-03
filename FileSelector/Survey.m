//
//  Survey.m
//  FileSelector
//
//  Created by Regan Sarwas on 12/3/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "Survey.h"

@interface Survey ()

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, readwrite) enum SurveyState state;
@property (nonatomic, strong, readwrite) NSDate *date;
@property (nonatomic, strong, readwrite) UIImage *thumbnail;
@property (nonatomic, strong, readwrite) SProtocol *protocol;
@property (nonatomic, strong, readwrite) UIManagedDocument *document;

@end

@implementation Survey

#pragma mark - initializers

+ (Survey *)surveyFromURL:(NSURL *)url
{
    //FIXME: implement open from URL
    return nil;
}


//FIXME: implement real creation
- (id)initWithProtocol:(SProtocol *)protcol
{
    if (self = [super init]) {
        self.date = [NSDate date];
    }
    return self;
}

//Do not allow creating a Survey without a protocol or URL
- (id)init
{
    return nil;
}


#pragma mark property accessors

- (UIImage *)thumbnail
{
    return nil;
}

- (NSString *)title
{
    static int counter;
    if (!_title) {
        _title = [NSString stringWithFormat:@"Survey %i", ++counter];
    }
    return _title;
}

- (NSString *)subtitle
{
    return self.date.description;
}


#pragma mark - public methods

- (void)openPropertiesWithCompletionHandler:(void (^)(NSError*))handler
{
    dispatch_async(dispatch_queue_create("gov.nps.akr.observer",DISPATCH_QUEUE_CONCURRENT), ^{
        NSError *error;
        [self openProperties:&error];
        if (handler) handler(error);
    });
}

- (void)openDocumentWithCompletionHandler:(void (^)(NSError*))handler
{

}

- (void)closeWithCompletionHandler:(void (^)(NSError*))handler
{

}

- (void)syncWithCompletionHandler:(void (^)(NSError*))handler
{

}


#pragma mark - private methods

- (BOOL)openProperties:(NSError **)error
{
    //FIXME: implement open from URL
    return YES;
}

- (BOOL)openDocument:(NSError **)error
{
    //FIXME: implement open from URL
    return YES;
}

@end
