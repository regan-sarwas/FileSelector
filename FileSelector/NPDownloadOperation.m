//
//  NPDownloadOperation.m
//  FileSelector
//
//  Created by Regan Sarwas on 12/8/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "NPDownloadOperation.h"

@interface NPDownloadOperation ()

@property (nonatomic, strong) NSURLSessionTask *downloadTask;

@end
@implementation NPDownloadOperation

- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *configuration;
        if (self.isBackground) {
            configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"gov.nps.observer.BackgroundDownloadSession"];
        } else {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        //FIXME: the background session is needs to be unique
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _session;
}

- (void) start
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.sourceURL];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
}

- (void) stop
{
    [self.downloadTask cancel];
    if (self.completionAction){
        self.completionAction(self.destinationURL, NO);
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    //TODO: implement method to support resume download (for pause or lost connection)
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (downloadTask == self.downloadTask && self.progressAction){
        self.progressAction((double)totalBytesWritten, (double)totalBytesExpectedToWrite);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!self.destinationURL) {
        NSURL *documentsDirectory = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
        NSURL *originalURL = downloadTask.originalRequest.URL;
        self.destinationURL = [documentsDirectory URLByAppendingPathComponent:originalURL.lastPathComponent];
    }
    if (self.canReplace) {
        [fileManager removeItemAtURL:self.destinationURL error:NULL];
    }
    BOOL success = [fileManager copyItemAtURL:location toURL:self.destinationURL error:nil];
    if (self.completionAction){
        self.completionAction(self.destinationURL, success);
    }
}

@end
