//
//  PTModelController.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTRemoteRequestHandler.h"

@class PTUser;
@class PTJoggingEntry;
@class PTFilterOptions;

/**
 * Main controller for access to the model. Supports working offline and syncing with the backend
 */
@interface PTModelController : NSObject

/**
 * User to use for API calls
 */
@property (nonatomic, strong) PTUser* user;
/**
 * Status of the sync operation
 */
@property (nonatomic, readonly) BOOL isSyncing;

+(instancetype) sharedController;

/**
 * Start sync process if not yet started
 */
-(void) startSync;
/**
 * Stop sync process if is started
 */
-(void) stopSync;

/**
 * Fetch not deleted local jogging entries for the provided filter
 *
 * @param filterOptions Filter to use
 * @return Array of PTJoggingEntry-s matching the filter
 */
-(NSArray*) fetchLocalJoggingEntriesWithFilter:(PTFilterOptions*) filterOptions;
/**
 * Save the jogging entry to the persistent store and send global notification on success
 *
 * @param joggingEntry Jogging entry to save
 * @param sender Sender of the global notification on success @see PTNotificator
 * @return YES on success, otherwise NO
 */
-(BOOL) saveJoggingEntry:(PTJoggingEntry*) joggingEntry notificationSender:(id) sender;
/**
 * Mark jogging entry as deleted and send global notification on success. @see fetchLocalJoggingEntriesWithFilter
 *
 * @param joggingEntry Jogging entry to mark as deleted
 * @param sender Sender of the global notification on success @see PTNotificator
 * @return YES on success, otherwise NO
 */
-(BOOL) deleteJoggingEntry:(PTJoggingEntry*) joggingEntry notificationSender:(id) sender;
/**
 * Fetch updated jogging entry (i.e. the one after the sync is finished) matching the provided jogging entry
 *
 * @param joggingEntry Jogging entry to use for matching
 * @return Updated jogging entry that matches the provided one, or 'nil' otherwise
 */
-(PTJoggingEntry*) fetchUpdatedJoggingEntryForJoggingEntry:(PTJoggingEntry*) joggingEntry;

/**
 * Fetch week report data for all jogging entries
 *
 * @return Array of PTJoggingEntryReportData
 */
-(NSArray*) fetchWeekReportDataForJoggingEntries;

/**
 * Cancel all remote operations
 *
 * @param YES on success, otherwise NO
 */
-(BOOL) cancelAllOperations;
/**
 * Deletes all synchronisable objects from the persistent store
 *
 * @param YES on success, otherwise NO
 */
-(BOOL) deleteAllSynchronisableObjects;

@end
