//
//  FSSurvey.h
//  FileSelector
//
//  Created by Regan Sarwas on 11/14/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTableViewItemCollection.h"
#import "SProtocol.h"

@interface FSSurvey : NSObject <FSTableViewItem>
@property (nonatomic, strong) NSString *title;

//@protperties
// title (name -editable)
//subtitle - description of dates
//url
//creation date,
//modified date,
//UIManagedDocument
//protocol ??
//thumbnail ??
//BOOL hasUnSyncedChanges

//Actions
//new from cache (url, title, subtitle,
//new from protocol (autocreate URL)
//open (wrapper for UIManagedDocument)
//sync

- (id)initWithProtocol:(SProtocol *)protcol;

@end
