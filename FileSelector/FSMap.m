//
//  FSMap.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSMap.h"

@implementation FSMap

//FIXME: This is kinda lame.  will be better when we implement a new class without inheritance
-(NSString *)title
{
    static int counter;
    if ([super.title hasPrefix:@"Survey"]) {
        super.title = [NSString stringWithFormat:@"Map %i", ++counter];
    }
    return super.title;
}

@end
