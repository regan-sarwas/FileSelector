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


-(UIImage *)thumbnail
{
    return nil;
}

-(NSString *)title
{
    static int counter;
    if (!_title) {
        _title = [NSString stringWithFormat:@"Survey %i", ++counter];
    }
    return _title;
}

-(NSString *)subtitle
{
    return self.date.description;
}

@end
