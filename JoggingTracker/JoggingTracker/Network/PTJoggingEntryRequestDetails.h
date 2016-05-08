//
//  PTJoggingEntryRequestDetails.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/29/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTJoggingEntry;

@interface PTJoggingEntryRequestDetails : NSObject

@property (nonatomic, strong) PTJoggingEntry* joggingEntry;
@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) NSNumber* isDeleted;

@end
