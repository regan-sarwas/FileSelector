//
//  Map.m
//  FileSelector
//
//  Created by Regan Sarwas on 12/5/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "Map.h"
#import "NSDate+Formatting.h"

#define kCodingVersion    1
#define kCodingVersionKey @"codingversion"
#define kUrlKey           @"url"
#define kTitleKey         @"title"
#define kAuthorKey        @"author"
#define kDateKey          @"date"
#define kJsonDateFormat   @""


@interface Map()
@property (nonatomic) BOOL downloading;
@property (nonatomic, strong, readwrite) UIImage *thumbnail;
@property (nonatomic, strong, readwrite) id tileCache;
@property (nonatomic, strong) NSURL *thumbnailUrl;
@property (nonatomic) BOOL thumbnailIsLoaded;
@property (nonatomic) BOOL tileCacheIsLoaded;
@end

@implementation Map


- (id) initWithURL:(NSURL *)url title:(id)title author:(id)author date:(id)date
{
    if (!url) {
        return nil;
    }
    if (self = [super init]) {
        _url = url;
        _title = ([title isKindOfClass:[NSString class]] ? title : nil);
        _date = [date isKindOfClass:[NSDate class]] ? date : ([date isKindOfClass:[NSString class]] ? [self dateFromString:date] : nil);
        _author = ([author isKindOfClass:[NSString class]] ? author : nil);
        _tileCacheIsLoaded = NO;
        _thumbnailIsLoaded = NO;
    }
    return self;
}


- (id) initWithURL:(NSURL *)url
{
    return [self initWithURL:url
                       title:url.lastPathComponent
                      author:nil
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
                             author:[aDecoder decodeObjectForKey:kAuthorKey]
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
    [aCoder encodeObject:_author forKey:kAuthorKey];
    [aCoder encodeObject:_date forKey:kDateKey];
}


#pragma mark - FSTableViewItem

@synthesize title = _title;

- (NSString *)title
{
    return _title ? _title : @"No Title";
}

- (NSString *)subtitle
{
    if (self.downloading) {
        return @"Downloading...";
    } else {
        return [NSString stringWithFormat:@"Author: %@, Date: %@", self.author, [self.date stringWithMediumDateFormat]];
    }
}

- (NSString *)subtitle2
{
    if (self.downloading) {
        return @"Downloading...";
    } else {
        return [NSString stringWithFormat:@"Size: %@", (self.isLocal ? self.arealSizeString : self.byteSizeString)];
    }
}

- (UIImage *)thumbnail
{
    if (!_thumbnail && !self.thumbnailIsLoaded) {
        [self loadThumbnail];
    }
    return _thumbnail;
}

- (id)tileCache
{
    if (!_tileCache && !self.tileCacheIsLoaded) {
        [self loadTileCache];
    }
    return _tileCache;
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
    ((self.author == other.author) || [self.author isEqual:other.author]) &&
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

- (NSString *)details
{
    return @"get details from the tilecache";
}

- (NSString *)byteSizeString
{
    if (self.byteCount == 0) {
        return @"Unknown";
    } else if (self.byteCount < 1024) {
        return [NSString stringWithFormat:@"%d Bytes", self.byteCount];
    } else if (self.byteCount < 1024*1024) {
        return [NSString stringWithFormat:@"%d KB", self.byteCount / 1024];
    } else if (self.byteCount < 1024*1024*1024) {
        return [NSString stringWithFormat:@"%d MB", self.byteCount / 1024 / 1024];
    } else {
        return [NSString stringWithFormat:@"%f2 GB", self.byteCount / 1024.0 / 1024 / 1024];
    }
}

- (NSString *)arealSizeString
{
    if (self.extents.size.height == 0 || self.extents.size.width == 0) {
        return @"Unknown";
    }
    return [NSString stringWithFormat:@"%f0 square miles", self.extents.size.height * self.extents.size.width];
}



- (BOOL)loadThumbnail
{
    self.thumbnailIsLoaded = YES;
    _thumbnail = [[UIImage alloc] initWithContentsOfFile:[self.thumbnailUrl path]];
    if (!_thumbnail)
        _thumbnail = [UIImage imageNamed:@"TilePackage"];
    return !_thumbnail;
}

- (BOOL)loadTileCache
{
    self.tileCacheIsLoaded = YES;
    _tileCache = nil; //FIXME: Get tilecache when linked to ArcGIS
    return !_tileCache;
}

@end
