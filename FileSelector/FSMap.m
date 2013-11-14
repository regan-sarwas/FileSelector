//
//  FSMap.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSMap.h"

@interface FSMap() {
NSString * _maptitle;
}
@end
@implementation FSMap


-(NSString *)title
{
    static int counter;
    if (!_maptitle) {
        _maptitle = [NSString stringWithFormat:@"Map %i", ++counter];
    }
    return _maptitle;
}

@end
