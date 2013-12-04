//
//  Survey.m
//  FileSelector
//
//  Created by Regan Sarwas on 12/3/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "Survey.h"
#import "NSURL+unique.h"
#import "NSDate+Formatting.h"

#define kCodingVersion    1
#define kCodingVersionKey @"codingversion"
#define kUrlKey           @"url"
#define kTitleKey         @"title"
#define kStateKey         @"state"
#define kDateKey          @"date"

#define kPropertiesFilename @"properties.plist"
#define kProtocolFilename   @"protocol.obsprot"
#define kThumbnailFilename  @"thumbnail.png"
#define kDocumentFilename   @"survey.coredata"

@interface Survey ()

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, readwrite) SurveyState state;
@property (nonatomic, strong, readwrite) NSDate *date;
@property (nonatomic, strong, readwrite) UIImage *thumbnail;
@property (nonatomic, strong, readwrite) SProtocol *protocol;
@property (nonatomic, strong, readwrite) UIManagedDocument *document;
@property (nonatomic, strong) NSURL *propertiesUrl;
@property (nonatomic, strong) NSURL *thumbnailUrl;
@property (nonatomic, strong) NSURL *protocolUrl;
@property (nonatomic, strong) NSURL *documentUrl;
@property (nonatomic) BOOL protocolIsLoaded;
@property (nonatomic) BOOL thumbnailIsLoaded;
@property (nonatomic) BOOL documentIsLoaded;

@end

@implementation Survey

#pragma mark - initializers

- (id)initWithURL:(NSURL *)url title:(NSString *)title state:(SurveyState)state date:(NSDate *)date
{
    if (self = [super init]) {
        self.url = url;
        self.title = title;
        self.state = state;
        self.date = date;
        self.protocolIsLoaded = NO;
        self.thumbnailIsLoaded = NO;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    return [self initWithURL:url title:nil state:0 date:[NSDate date]];
}

//Do not allow creating a Survey without a protocol or URL
- (id)init
{
    return nil;
}

- (id)initWithProtocol:(SProtocol *)protocol
{
    //verify the input - reading protocol values may cause protocol to load from filesystem
    if (!protocol.values) {
        return nil;
    }
    //find a suitable URL (reads filesystem)
    NSURL *documentsDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSString *filename = [NSString stringWithFormat:@"%@.%@", protocol.title, SURVEY_EXT];
    NSURL *url = [[documentsDirectory URLByAppendingPathComponent:filename] URLByUniquingPath];
    self = [self initWithURL:url title:[[url lastPathComponent] stringByDeletingPathExtension] state:kCreated date:[NSDate date]];
    if (![[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil]) {
        return nil;
    };
    if (![protocol saveCopyToURL:self.protocolUrl]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        return nil;
    }
    self.protocolIsLoaded = YES;
    [self saveProperties];
    return self;
}


#pragma mark property accessors

@synthesize title = _title;

- (NSString *)title
{
    if (self.state == kUnborn) {
        [self loadProperties];
    }
    return _title;
}

- (void)setTitle:(NSString *)title
{
    if (_title != title) {
        _title = title;
        [self saveProperties];
    }
}

- (NSDate *)date
{
    if (self.state == kUnborn) {
        [self loadProperties];
    }
    return _date;
}

- (NSString *)subtitle
{
    NSString *status = nil;
    switch (self.state) {
        case kUnborn:
            status = @"Unborn";
            break;
        case kCorrupt:
            status = @"Corrupt";
            break;
        case kCreated:
            status = @"Created";
            break;
        case kModified:
            status = @"Modified";
            break;
        case kSaved:
            status = @"Saved";
            break;
        default:
            status = @"Unknown State";
            break;
    }
    return [NSString stringWithFormat:@"%@: %@",status, [self.date stringWithMediumDateTimeFormat]];
}

- (UIImage *)thumbnail
{
    if (!_thumbnail && !self.thumbnailIsLoaded) {
        [self loadThumbnail];
    }
    return _thumbnail;
}

- (SProtocol *)protocol
{
    if (!_protocol && !self.protocolIsLoaded) {
        [self loadProtocol];
    }
    return _protocol;
}

- (UIManagedDocument *)document
{
    if (!_document && !self.documentIsLoaded) {
        [self openDocument:nil];
    }
    return _document;
}

- (NSURL *)propertiesUrl
{
    if (!_propertiesUrl) {
        _propertiesUrl = [self.url URLByAppendingPathComponent:kPropertiesFilename];
    }
    return _propertiesUrl;
}

- (NSURL *)thumbnailUrl
{
    if (!_thumbnailUrl) {
        _thumbnailUrl = [self.url URLByAppendingPathComponent:kThumbnailFilename];
    }
    return _thumbnailUrl;
}

- (NSURL *)protocolUrl
{
    if (!_protocolUrl) {
        _protocolUrl = [self.url URLByAppendingPathComponent:kProtocolFilename];
    }
    return _protocolUrl;
}

- (NSURL *)documentUrl
{
    if (!_documentUrl) {
        _documentUrl = [self.url URLByAppendingPathComponent:kDocumentFilename];
    }
    return _documentUrl;
}

#pragma mark - public methods

//TODO: figure out error handling.
- (void)readPropertiesWithCompletionHandler:(void (^)(NSError*))handler
{
    dispatch_async(dispatch_queue_create("gov.nps.akr.observer",DISPATCH_QUEUE_CONCURRENT), ^{
        NSError *error;
        [self loadProperties];
        [self loadProtocol];
        [self loadThumbnail];
        if (handler) handler(error);
    });
}

- (void)openDocumentWithCompletionHandler:(void (^)(NSError*))handler
{
    //TODO: Implement
}

- (void)closeWithCompletionHandler:(void (^)(NSError*))handler
{
    //TODO: Implement
}

- (void)syncWithCompletionHandler:(void (^)(NSError*))handler
{
    //TODO: Implement
}


#pragma mark - private methods

- (BOOL)loadProperties
{
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfURL:self.propertiesUrl];
    NSInteger version = [plist[kCodingVersionKey] integerValue];
    switch (version) {
        case 1:
            self.title = plist[kTitleKey];
            self.State = [plist[kStateKey] integerValue];
            self.date = plist[kDateKey];
            return YES;
        default:
            return NO;
    }
}

- (BOOL)loadProtocol
{
    self.protocolIsLoaded = YES;
    _protocol = [[SProtocol alloc] initWithURL:self.protocolUrl];
    if (!_protocol.values) {
        self.state = kCorrupt;
        _protocol = nil;
        return NO;
    }
    return YES;
}

- (BOOL)loadThumbnail
{
    self.thumbnailIsLoaded = YES;
    _thumbnail = [[UIImage alloc] initWithContentsOfFile:[self.thumbnailUrl path]];
    return !_thumbnail;
}

- (BOOL)openDocument:(NSError **)error
{
    if (self.state == kCorrupt) {
        return NO;
    }
    //TODO: Implement
    //open UIManagedDocument at self.documentURL
    //signup to receive saved notifications to update state/date
    //FIXME: there is a threading issue here, need to wait on the background thread opening UIManagedDocument
    return YES;
}

- (void)documentChanged:(id)sender {
    self.state = kModified;
    self.date = [NSDate date];
    [self saveProperties];
    //TODO: build new thumbnail and save;
}

- (BOOL)saveProperties {
    NSDictionary *plist = @{kCodingVersionKey:@kCodingVersion,
                            kTitleKey:self.title,
                            kStateKey:@(self.state),
                            kDateKey:self.date};
    return [plist writeToURL:self.propertiesUrl atomically:YES];
}

- (BOOL)saveThumbnail
{
    return [UIImagePNGRepresentation(self.thumbnail) writeToFile:[self.thumbnailUrl path] atomically:YES];
}

@end
