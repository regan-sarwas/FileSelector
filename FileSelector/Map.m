//
//  Map.m
//  FileSelector
//
//  Created by Regan Sarwas on 12/5/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "Map.h"

#define kCodingVersion    1
#define kCodingVersionKey @"codingversion"
#define kUrlKey           @"url"
#define kTitleKey         @"title"
#define kVersionKey       @"version"
#define kDateKey          @"date"
#define kJsonDateFormat   @""


@interface Map() {
    NSString *_title;  //interface properties cannot be synthesized
}
@property (nonatomic) BOOL downloading;
@end

@implementation Map


- (id) initWithURL:(NSURL *)url title:(id)title version:(id)version date:(id)date
{
    if (!url) {
        return nil;
    }
    if (self = [super init]) {
        _url = url;
        _title = ([title isKindOfClass:[NSString class]] ? title : nil);
        _version = ([version isKindOfClass:[NSNumber class]] ? version : nil);
        _date = [date isKindOfClass:[NSDate class]] ? date : ([date isKindOfClass:[NSString class]] ? [self dateFromString:date] : nil);
    }
    return self;
}


- (id) initWithURL:(NSURL *)url
{
    return [self initWithURL:url
                       title:url.lastPathComponent
                     version:nil
                        date:nil];
}


#pragma mark - Lazy property initiallizers

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    int version = [aDecoder decodeIntForKey:kCodingVersionKey];
    switch (version) {
        case 1:
            return [self initWithURL:[aDecoder decodeObjectForKey:kUrlKey]
                               title:[aDecoder decodeObjectForKey:kTitleKey]
                             version:[aDecoder decodeObjectForKey:kVersionKey]
                                date:[aDecoder decodeObjectForKey:kDateKey]];
        default:
            return nil;
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:kCodingVersion forKey:kCodingVersionKey];
    [aCoder encodeObject:_url forKey:kUrlKey];
    [aCoder encodeObject:_title forKey:kTitleKey];
    [aCoder encodeObject:_version forKey:kVersionKey];
    [aCoder encodeObject:_date forKey:kDateKey];
}


#pragma mark - FSTableViewItem

- (NSString *)title
{
    return _title ? _title : @"No Title";
}

- (NSString *)subtitle
{
    if (self.downloading) {
        return @"Downloading...";
    } else {
        return [NSString stringWithFormat:@"Version: %@, Date: %@", self.versionString, self.dateString];
    }
}

- (UIImage *)thumbnail
{
    return nil;
}


#pragma mark - public methods

- (BOOL)isLocal
{
    return self.url.isFileURL;
}

// I do not override isEqual to use this method, because title,version and date could change
// when the values are accessed.  This would cause the hash value to change which can cause
// all kinds of problems if the object is used in a dictionary or set.
- (BOOL)isEqualtoMap:(Map *)other
{
    // need to be careful with null properties.
    // without the == check, two null properties will be not equal
    return ((self.title == other.title) || [self.title isEqualToString:other.title]) &&
    ((self.version == other.version) || [self.version isEqual:other.version]) &&
    ((self.date == other.date) || [self.date isEqual:other.date]);
}

- (void)prepareToDownload
{
    self.downloading = YES;
}

- (BOOL)isDownloading
{
    return self.downloading;
}


- (BOOL)downloadToURL:(NSURL *)url
{
    //FIXME: use NSURLSession, and use delegate to provide progress indication
    BOOL success = NO;
    if (!self.isLocal && self.tileCache) {
        if ([self saveCopyToURL:url]) {
            _url = url;
            success = YES;
        } else {
            NSLog(@"Map.downloadToURL:  Got data but write to %@ failed",url);
        }
    } else {
        NSLog(@"Map.downloadToURL: Unable to get data at %@", self.url);
    }
    self.downloading = NO;
    return success;
}

- (BOOL)saveCopyToURL:(NSURL *)url
{
    NSOutputStream *stream = [NSOutputStream outputStreamWithURL:url append:NO];
    [stream open];
    NSInteger numberOfBytesWritten = 0; //FIXME: get tilecache at remote URL and write to stream
    [stream close];
    return numberOfBytesWritten > 0;
}


#pragma mark - date formatters

//cached date formatters per xcdoc://ios/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html
//TODO: subscribe to the NSCurrentLocaleDidChangeNotification notification and update cached objects when the current locale changes

- (NSDate *) dateFromString:(NSString *)date
{
    if (!date) {
        return nil;
    }
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd"];
        [dateFormatter setLenient:YES];
    }
    return [dateFormatter dateFromString:date];
}

- (NSString *) stringFromDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter)
    {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return [dateFormatter stringFromDate:date];
}

- (NSString *)details
{
    return @"get details from the tilecache";
}

- (NSString *)dateString
{
    return self.date ? [self stringFromDate:self.date] : @"Unknown";
}

- (NSString *)versionString
{
    return self.version ? [self.version stringValue] : @"Unknown";
}

@end
