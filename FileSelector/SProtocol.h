//
//  SProtocol.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/18/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTableViewItemCollection.h"

@interface SProtocol : NSObject <NSCoding, FSTableViewItem>

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSNumber *version;
@property (nonatomic, strong, readonly) NSString *versionString;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, strong, readonly) NSString *dateString;
@property (nonatomic, strong, readonly) NSString *details;

//@property (nonatomic, strong, readonly) NSString *date;
@property (nonatomic, strong, readonly) NSDictionary *values;

//YES if the protocol is available locally, NO otherwise;
- (BOOL)isLocal;

//YES if two protocols are the same (same title, version and date)
//    do not compare urls, because the same protocol will have either a local, or a server url
- (BOOL)isEqualtoProtocol:(Protocol *)protocol;

//designated initializer
- (id)initWithURL:(NSURL *)url title:(id)title version:(id)version date:(id)date;
- (id)initWithURL:(NSURL *)url;
- (id)init;  //will always return nil

// download the protocol from the remote URL to a local file...
- (void)prepareToDownload;
- (BOOL)downloadToURL:(NSURL *)url;

@end
