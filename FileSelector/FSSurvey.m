//
//  FSSurvey.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSSurvey.h"

@interface FSSurvey()
@property (nonatomic, strong) NSDate *creationDate;
@end

@implementation FSSurvey

- (id)init
{
    return [self init];
}

//FIXME: implement real creation
- (id)initWithProtocol:(SProtocol *)protcol
{
    if (self = [super init]) {
        self.creationDate = [NSDate date];
    }
    return self;
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
    return self.creationDate.description;
}

@end
