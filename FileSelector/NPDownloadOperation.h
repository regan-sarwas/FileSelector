//
//  NPDownloadOperation.h
//  FileSelector
//
//  Created by Regan Sarwas on 12/8/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NPDownloadOperation : NSOperation <NSURLSessionDownloadDelegate> //, NSURLSessionTaskDelegate>

@property (nonatomic) BOOL isBackground;
@property (nonatomic) BOOL canReplace;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURL *sourceURL;
@property (nonatomic, strong) NSURL *destinationURL;
@property (nonatomic, copy) void(^progressAction)(double bytesWritten, double bytesExpected);
@property (nonatomic, copy) void(^completionAction)(NSURL *imageUrl, BOOL success);

@end
