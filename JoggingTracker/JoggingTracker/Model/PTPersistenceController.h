//
//  PTPersistenceController.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTManagedObjectSyncStatus.h"

@class PTUser;
@class PTJoggingEntry;
@class PTManagedJoggingEntry;
@class PTCreatedRemoteObjectResponseData;
@class PTUpdatedRemoteObjectResponseData;
@class PTSynchronisableObject;
@class PTManagedSynchronisableObject;
@class PTFilterOptions;

/**
 Controller for access to persisted data.
 */
@interface PTPersistenceController : NSObject

+(instancetype) sharedController;

/**
 * Save user as current logged in user. Can use user details later
 *
 * @param user User to save.
 * @return YES on succes, otherwise NO
 */
-(BOOL) saveCurrentUser:(PTUser*) user;
/**
 * @return YES on succes, otherwise NO
 */
-(BOOL) deleteCurrentUser;
/**
 * @return Current logged in user
 */
-(PTUser*) fetchCurrentUser;

/**
 * Create or update managed synchronisable object from transient synchronisable object. Can differe between
 * create or update using result syncStatus property (PTManagedObjectSyncStatusCreated for created object and
 * PTManagedObjectSyncStatusOutOfSync for updated object)
 *
 * @param synchronisableObject Transient synchronisable object to persist
 * @return Managed synchronisable object on success or 'nil' on failure
 */
-(PTManagedSynchronisableObject*) saveSynchronisableObject:(PTSynchronisableObject*) synchronisableObject;
/**
 * Update sync status for managed synchronisable object that matches the transient synchronisable object
 *
 * @param syncStatus Sync status to set
 * @param synchronisableObject Transient synchronisable object to use for managed object search
 * @return YES on success, otherwise NO
 */
-(BOOL) setSyncStatus:(PTManagedObjectSyncStatus) syncStatus
             ofObject:(PTSynchronisableObject*) synchronisableObject;
/**
 * Update sync status for managed synchronisable object
 *
 * @param syncStatus Sync status to set
 * @param synchronisableObject Managed synchronisable object
 * @return YES on success, otherwise NO
 */
-(BOOL) setSyncStatus:(PTManagedObjectSyncStatus) syncStatus
      ofManagedObject:(PTManagedSynchronisableObject*) managedSynchronisableObject;
/**
 * Update managed synchronisable object that matches the transient synchronisable object with the response data
 * when remote object is created
 *
 * @param responseData Remote object response data for created object
 * @param synchronisableObject Transient synchronisable object to use
 * @return YES on success, otherwise NO
 */
-(BOOL) updateWithCreatedRemoteObjectResponseData:(PTCreatedRemoteObjectResponseData*) responseData
                          forSynchronisableObject:(PTSynchronisableObject*) synchronisableObject;
/**
 * Update managed synchronisable object that matches the transient synchronisable object with the response data
 * when remote object is updated
 *
 * @param responseData Remote object response data for updated object
 * @param synchronisableObject Transient synchronisable object to use
 * @return YES on success, otherwise NO
 */
-(BOOL) updateWithUpdatedRemoteObjectResponseData:(PTUpdatedRemoteObjectResponseData*) responseData
                          forSynchronisableObject:(PTSynchronisableObject*) synchronisableObject;
/**
 * Fetch managed synchronisable object that matches the provided transient synchronisable object
 *
 * @param synchronisableObject Transient synchronisable object
 * @return Managed synchronisable object that matches the provided transient synchronisable object or 'nil' otherwise
 */
-(PTManagedSynchronisableObject*) fetchManagedSynchronisableObjectForSynchronisableObject:(PTSynchronisableObject*) synchronisableObject;

/**
 * Update store with fetched remote jogging entries. This is the first step of the synchronisation when the client gets
 * updated objects from the backend
 *
 * @param joggingEntries Created/Updated jogging entries on the backend that are newer than the last synchronisation
 * @return YES on success, otherwise NO
 */
-(BOOL) mergeWithJoggingEntries:(NSArray*) joggingEntries;
/**
 * Update store with response data for uploading local jogging entries to the backend. This is the second step of the synchronisation
 * when the client has sent its local objects to the backend and has received the response for that
 *
 * @param joggingEntries Local jogging entries that were uploaded
 * @param responsesData Responses data for all uploaded local jogging entries in this batch
 * @return YES on success, otherwise NO
 */
-(BOOL) updateJoggingEntries:(NSArray*) joggingEntries withBatchOperationsResponsesData:(NSArray*) responsesData;

/**
 * Fetch all jogging entries that matches the filter
 *
 * @param filterOptions Filter to use for fetching
 * @return All jogging entries matching the filter
 */
-(NSArray*) fetchJoggingEntriesWithFilter:(PTFilterOptions*) filterOptions;
/**
 * Fetch all not synced jogging entries (the ones with sync status different from PTManagedObjectSyncStatusSynced
 *
 * @return All not synced jogging entries
 */
-(NSArray*) fetchNotSyncedJoggingEntries;
/**
 * Fetch week report data for all jogging entries
 *
 * @return Array of PTJoggingEntryReportData
 */
-(NSArray*) fetchWeekReportDataForJoggingEntries;

/**
 * Deletes all synchronisable objects from the persistent store
 *
 * @return YES on success, NO otherwise
 */
-(BOOL) deleteAllSynchronisableObjects;

@end
