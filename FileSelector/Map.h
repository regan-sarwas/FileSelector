//
//  Map.h
//  FileSelector
//
//  Created by Regan Sarwas on 12/5/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTableViewItemCollection.h"

@interface Map : NSObject <NSCoding, FSTableViewItem>

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSNumber *version;
@property (nonatomic, strong, readonly) NSString *versionString;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, strong, readonly) NSString *dateString;
@property (nonatomic, strong, readonly) NSString *details;

//FIXME: get correct type for tilecache and validate usage
@property (nonatomic, strong, readonly) id tileCache;

//YES if the Map is available locally, NO otherwise;
- (BOOL)isLocal;

//YES if two Maps are the same (same title, version and date)
//    do not compare urls, because the same Map will have either a local, or a server url
- (BOOL)isEqualtoMap:(Map *)Map;

//designated initializer
- (id)initWithURL:(NSURL *)url title:(id)title version:(id)version date:(id)date;
- (id)initWithURL:(NSURL *)url;
- (id) init __attribute__((unavailable("Must use initWithURL: instead.")));

// download the Map from the remote URL to a local file...
- (void)prepareToDownload;
- (BOOL)isDownloading;
- (BOOL)downloadToURL:(NSURL *)url;

@end
