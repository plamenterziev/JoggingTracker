//
//  PTModelController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTModelController.h"
#import "PTModelSyncStatus.h"
#import "PTApiCallsUtils.h"
#import "PTApiCallFetchJoggingEntries.h"
#import "PTApiCallCreateJoggingEntry.h"
#import "PTApiCallUpdateJoggingEntry.h"
#import "PTApiCallBatchOperations.h"
#import "PTApiCallBatchOperationConfiguration.h"
#import "PTUser.h"
#import "PTJoggingEntry.h"
#import "PTJoggingEntryRequestDetails.h"
#import "PTCreatedRemoteObjectResponseData.h"
#import "PTUpdatedRemoteObjectResponseData.h"
#import "PTPersistenceController.h"
#import "PTManagedJoggingEntry.h"
#import "PTManagedObjectSyncStatus.h"
#import "PTUserDefaultSettings.h"
#import "PTNotificator.h"
#import "PTModelSyncScheduler.h"

#import <RestKit.h>

@interface PTModelController () <PTModelSyncSchedulerDelegate>

@property (nonatomic, strong) RKObjectManager* objectManager;
@property (nonatomic) BOOL isSyncing;
@property (nonatomic, strong) PTModelSyncScheduler* modelSyncScheduler;
@property (nonatomic, strong) PTRemoteRequestHandler* fetchJoggingEntriesRequestHandler;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;

-(void) setup;
-(void) sync;
-(void) updateSyncStatus:(PTModelSyncStatus) syncStatus;
-(void) fetchNextJoggingEntries;
-(void) handleFetchedJoggingEntries:(NSArray*) joggingEntries;
-(void) uploadNextNotSyncedJoggingEntries;
-(void) handleUploadedResponsesData:(NSArray*) responsesData forNotSyncedJoggingEntries:(NSArray*) joggingEntries;

-(PTRemoteRequestHandler*) fetchNextUpdatedJoggingEntriesForUser:(PTUser*) user
                                                         success:(void (^)(PTRemoteRequestHandler* requestHandler,
                                                                           NSArray* joggingEntries)) success
                                                         failure:(PTRemoteRequestFailureBlock) failure;

-(PTRemoteRequestHandler*) createRemoteJoggingEntryFromLocal:(PTJoggingEntry*) joggingEntry;
-(PTRemoteRequestHandler*) updateRemoteJoggingEntryFromLocal:(PTJoggingEntry*) joggingEntry;
-(PTRemoteRequestHandler*) deleteRemoteJoggingEntryFromLocal:(PTJoggingEntry*) joggingEntry;

@end

@implementation PTModelController

static PTModelController* theController = nil;

+(instancetype) sharedController
{
    if(!theController)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            theController = [PTModelController new];
        });
    }
    
    return theController;
}

-(instancetype) init
{
    if((self = [super init]))
    {
        [self setup];
    }
    
    return self;
}

-(void) startSync
{
    if(!self.isSyncing)
    {
        [self updateSyncStatus:PTModelSyncStatusStarted];
        [self sync];
    }
}

-(void) stopSync
{
    if(self.isSyncing)
    {
        [self.fetchJoggingEntriesRequestHandler cancel];
        
        [self updateSyncStatus:PTModelSyncStatusStopped];
    }
}

-(NSArray*) fetchLocalJoggingEntriesWithFilter:(PTFilterOptions*) filterOptions
{
    return [[PTPersistenceController sharedController] fetchJoggingEntriesWithFilter:filterOptions];
}

-(BOOL) saveJoggingEntry:(PTJoggingEntry*) joggingEntry notificationSender:(id) sender
{
    PTManagedJoggingEntry* managedJoggingEntry = (PTManagedJoggingEntry*) [[PTPersistenceController sharedController] saveSynchronisableObject:joggingEntry];
    if(managedJoggingEntry)
    {
        if([managedJoggingEntry.syncStatus integerValue] == PTManagedObjectSyncStatusCreated)
        {
            [self createRemoteJoggingEntryFromLocal:joggingEntry];
            
            [[PTNotificator sharedNotificator] notifyDidAddSynchronisableObject:joggingEntry sender:sender];
        }
        else
        {
            NSAssert([managedJoggingEntry.syncStatus integerValue] == PTManagedObjectSyncStatusOutOfSync,
                     @"Invalid sync status for: %@", managedJoggingEntry);
            
            [self updateRemoteJoggingEntryFromLocal:joggingEntry];
            
            [[PTNotificator sharedNotificator] notifyDidUpdateSynchronisableObject:joggingEntry sender:sender];
        }
    }
    
    return !!managedJoggingEntry;
}

-(BOOL) deleteJoggingEntry:(PTJoggingEntry*) joggingEntry notificationSender:(id) sender
{
    BOOL result = YES;
    
    PTManagedJoggingEntry* managedJoggingEntry =
        (PTManagedJoggingEntry*) [[PTPersistenceController sharedController] fetchManagedSynchronisableObjectForSynchronisableObject:joggingEntry];
    if(managedJoggingEntry)
    {
        result = [[PTPersistenceController sharedController] setSyncStatus:PTManagedObjectSyncStatusDeleted
                                                           ofManagedObject:managedJoggingEntry];
        
        if(result)
        {
            [self deleteRemoteJoggingEntryFromLocal:joggingEntry];
            
            [[PTNotificator sharedNotificator] notifyDidDeleteSynchronisableObject:joggingEntry sender:sender];
        }
    }
    
    return result;
}

-(PTJoggingEntry*) fetchUpdatedJoggingEntryForJoggingEntry:(PTJoggingEntry*) joggingEntry
{
    PTManagedJoggingEntry* managedJoggingEntry =
        (PTManagedJoggingEntry*) [[PTPersistenceController sharedController] fetchManagedSynchronisableObjectForSynchronisableObject:joggingEntry];
    PTJoggingEntry* updatedJoggingEntry = nil;
    if(managedJoggingEntry)
    {
        updatedJoggingEntry = [[PTJoggingEntry alloc] initWithManagedObject:managedJoggingEntry];
    }
    
    return updatedJoggingEntry;
}

-(NSArray*) fetchWeekReportDataForJoggingEntries
{
    return [[PTPersistenceController sharedController] fetchWeekReportDataForJoggingEntries];
}

-(BOOL) cancelAllOperations
{
    [self.objectManager.operationQueue cancelAllOperations];
    
    return YES;
}

-(BOOL) deleteAllSynchronisableObjects
{
    BOOL result = [[PTPersistenceController sharedController] deleteAllSynchronisableObjects];
    if(result)
    {
        [PTUserDefaultsSettings sharedSettings].latestSyncedJoggingEntryDateUpdated = nil;
    }
    
    return result;
}

#pragma mark -
#pragma mark PTModelSyncScheduler methods

-(void) modelSyncSchedulerDidRequestModelSync:(PTModelSyncScheduler*) sender
{
    NSAssert(!self.isSyncing, @"Model is already syncing");
    
    [self startSync];
}

#pragma mark -
#pragma mark Private methods

-(void) setup
{
    self.objectManager = [PTApiCallsUtils createObjectManager];
    
    [self.objectManager addRequestDescriptorsFromArray:@[[PTApiCallCreateJoggingEntry requestDescriptor],
                                                         [PTApiCallUpdateJoggingEntry requestDescriptor],
                                                         [PTApiCallBatchOperations requestDescriptor]]];
    [self.objectManager addResponseDescriptorsFromArray:@[[PTApiCallFetchJoggingEntries responseDescriptor],
                                                          [PTApiCallCreateJoggingEntry responseDescriptor],
                                                          [PTApiCallUpdateJoggingEntry responseDescriptor],
                                                          [PTApiCallBatchOperations responseDescriptor]]];
    
    self.modelSyncScheduler = [PTModelSyncScheduler new];
    self.modelSyncScheduler.delegate = self;
    
    self.dateFormatter = [NSDateFormatter new];
    NSLocale* enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [self.dateFormatter setLocale:enUSPOSIXLocale];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
}

-(void) sync
{
    [self fetchNextJoggingEntries];
}

-(void) updateSyncStatus:(PTModelSyncStatus) syncStatus
{
    switch (syncStatus)
    {
        case PTModelSyncStatusStarted:
            self.isSyncing = YES;
            break;
        case PTModelSyncStatusFailed:
        case PTModelSyncStatusFinished:
        case PTModelSyncStatusStopped:
            self.isSyncing = NO;
            break;
        default:
            break;
    }
    
    [self.modelSyncScheduler updateWithSyncStatus:syncStatus];
    
    [[PTNotificator sharedNotificator] notifyModelSyncDidUpdateStatus:syncStatus sender:self];
}

-(void) fetchNextJoggingEntries
{
    __weak typeof(self) weakSelf = self;
    self.fetchJoggingEntriesRequestHandler = [self fetchNextUpdatedJoggingEntriesForUser:self.user
                                                                                 success:^(PTRemoteRequestHandler* requestHandler,
                                                                                           NSArray* joggingEntries)
    {
        [weakSelf handleFetchedJoggingEntries:joggingEntries];
    }
                                                                                 failure:^(PTRemoteRequestHandler* requestHandler,
                                                                                           NSError* error)
    {
        [weakSelf updateSyncStatus:PTModelSyncStatusFailed];
    }];
}

-(void) handleFetchedJoggingEntries:(NSArray*) joggingEntries
{
    if([joggingEntries count] == 0)
    {
        [self uploadNextNotSyncedJoggingEntries];
    }
    else
    {
        BOOL result = [[PTPersistenceController sharedController] mergeWithJoggingEntries:joggingEntries];
        if(result)
        {
            [PTUserDefaultsSettings sharedSettings].latestSyncedJoggingEntryDateUpdated = ((PTJoggingEntry*)[joggingEntries lastObject]).dateUpdated;
            if([joggingEntries count] < kRemoteObjectsFetchLimit)
            {
                [self uploadNextNotSyncedJoggingEntries];
            }
            else
            {
                NSLog(@"Successfully merge with fetched jogging entries. Start fetching next jogging entries");
                [self fetchNextJoggingEntries];
            }
        }
        else
        {
            NSLog(@"Unable to merge with fetched jogging entries");
            [self updateSyncStatus:PTModelSyncStatusFailed];
        }
    }
}

-(void) uploadNextNotSyncedJoggingEntries
{
    NSArray* pendingSyncJoggingEntries = [[PTPersistenceController sharedController] fetchNotSyncedJoggingEntries];
    
    if([pendingSyncJoggingEntries count] == 0)
    {
        [self updateSyncStatus:PTModelSyncStatusFinished];
    }
    else
    {
        NSMutableArray* batchOperationsConfigurations = [NSMutableArray arrayWithCapacity:[pendingSyncJoggingEntries count]];
        NSMutableArray* joggingEntries = [NSMutableArray arrayWithCapacity:[pendingSyncJoggingEntries count]];
        for(PTManagedJoggingEntry* managedJoggingEntry in pendingSyncJoggingEntries)
        {
            PTApiCallBatchOperationConfiguration* configuration = [PTApiCallBatchOperationConfiguration new];
            PTJoggingEntryRequestDetails* joggingEntryRequestDetails = [PTJoggingEntryRequestDetails new];
            joggingEntryRequestDetails.joggingEntry = [[PTJoggingEntry alloc] initWithManagedObject:managedJoggingEntry];
            joggingEntryRequestDetails.userID = self.user.userID;
            joggingEntryRequestDetails.isDeleted = @NO;
            
            PTManagedObjectSyncStatus syncStatus = [managedJoggingEntry.syncStatus integerValue];
            switch (syncStatus)
            {
                case PTManagedObjectSyncStatusCreated:
                {
                    configuration.apiCallClass = [PTApiCallCreateJoggingEntry class];
                }
                    break;
                case PTManagedObjectSyncStatusDeleted:
                {
                    if([joggingEntryRequestDetails.joggingEntry.serverSideObjectID length] > 0)
                    {
                        configuration.apiCallClass = [PTApiCallUpdateJoggingEntry class];
                        configuration.objectsForPath = @[joggingEntryRequestDetails.joggingEntry];
                        joggingEntryRequestDetails.isDeleted = @YES;
                    }
                    else
                    {
                        configuration.apiCallClass = [PTApiCallCreateJoggingEntry class];
                    }
                }
                    break;
                case PTManagedObjectSyncStatusOutOfSync:
                {
                    if([joggingEntryRequestDetails.joggingEntry.serverSideObjectID length] > 0)
                    {
                        configuration.apiCallClass = [PTApiCallUpdateJoggingEntry class];
                        configuration.objectsForPath = @[joggingEntryRequestDetails.joggingEntry];
                    }
                    else
                    {
                        configuration.apiCallClass = [PTApiCallCreateJoggingEntry class];
                    }
                }
                    break;
                default:
                    NSAssert(NO, @"Invalid sync status: %d", syncStatus);
                    break;
            }
            
            configuration.payloadObject = joggingEntryRequestDetails;
            
            [batchOperationsConfigurations addObject:configuration];
            [joggingEntries addObject:joggingEntryRequestDetails.joggingEntry];
        }
        
        id payloadObject = [PTApiCallBatchOperations requestPayloadObjectForConfigurations:batchOperationsConfigurations];
        if(payloadObject)
        {
            __weak typeof(self) weakSelf = self;
            PTApiCallBatchOperations* apiCall = [PTApiCallBatchOperations new];
            apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
            {
                [weakSelf handleUploadedResponsesData:result.objects forNotSyncedJoggingEntries:joggingEntries];
            };
            apiCall.failureBlock = ^(PTRemoteRequestHandler* requestHandler, NSError* error)
            {
                [self updateSyncStatus:PTModelSyncStatusFailed];
            };
            
            [apiCall executeWithManager:self.objectManager withPayloadObject:payloadObject pathUsingObjects:nil];
        }
        else
        {
            [self updateSyncStatus:PTModelSyncStatusFailed];
        }
    }
}

-(void) handleUploadedResponsesData:(NSArray*) responsesData forNotSyncedJoggingEntries:(NSArray*) joggingEntries
{
    BOOL result = [[PTPersistenceController sharedController] updateJoggingEntries:joggingEntries
                                                  withBatchOperationsResponsesData:responsesData];
    if(result)
    {
        [self uploadNextNotSyncedJoggingEntries];
    }
    else
    {
        NSLog(@"Unable to update not synced jogging entries with responses data");
        [self updateSyncStatus:PTModelSyncStatusFailed];
    }
}

-(PTRemoteRequestHandler*) fetchNextUpdatedJoggingEntriesForUser:(PTUser*) user
                                                         success:(void (^)(PTRemoteRequestHandler* requestHandler,
                                                                           NSArray* joggingEntries)) success
                                                         failure:(PTRemoteRequestFailureBlock) failure
{
    PTApiCallFetchJoggingEntries* apiCall = [PTApiCallFetchJoggingEntries new];
    apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
    {
        if(success)
        {
            success(requestHandler, result.objects);
        }
    };
    apiCall.failureBlock = failure;
    NSDate* latestSyncedJoggingEntryDateUpdated = [PTUserDefaultsSettings sharedSettings].latestSyncedJoggingEntryDateUpdated;
    NSString* whereClause = nil;
    if(latestSyncedJoggingEntryDateUpdated)
    {
        whereClause = [NSString stringWithFormat:@"{\"userId\":\"%@\", \"updatedAt\":{\"$gt\":{\"__type\":\"Date\",\"iso\":\"%@\"}}}",
                       user.userID, [self.dateFormatter stringFromDate:latestSyncedJoggingEntryDateUpdated]];
    }
    else
    {
        whereClause = [NSString stringWithFormat:@"{\"userId\":\"%@\"}", user.userID];
    }
    apiCall.parameters = @{@"limit" : @(kRemoteObjectsFetchLimit),
                           @"where" : whereClause,
                           @"order" : @"updatedAt"};
    return [apiCall executeWithManager:self.objectManager pathUsingObjects:nil];
}

-(PTRemoteRequestHandler*) createRemoteJoggingEntryFromLocal:(PTJoggingEntry*) joggingEntry
{
    __weak typeof(self) weakSelf = self;
    PTApiCallCreateJoggingEntry* apiCall = [PTApiCallCreateJoggingEntry new];
    apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
    {
        PTCreatedRemoteObjectResponseData* responseData = [result.objects lastObject];
        [[PTPersistenceController sharedController] updateWithCreatedRemoteObjectResponseData:responseData
                                                                      forSynchronisableObject:joggingEntry];
    };
    apiCall.failureBlock = ^(PTRemoteRequestHandler* requestHandler, NSError* error)
    {
        if(!weakSelf.isSyncing)
        {
            [weakSelf.modelSyncScheduler updateWithSyncStatus:PTModelSyncStatusFailed];
        }
    };
    
    PTJoggingEntryRequestDetails* requestDetails = [PTJoggingEntryRequestDetails new];
    requestDetails.joggingEntry = joggingEntry;
    requestDetails.userID = self.user.userID;
    requestDetails.isDeleted = @NO;
    
    return [apiCall executeWithManager:self.objectManager withPayloadObject:requestDetails pathUsingObjects:nil];
}

-(PTRemoteRequestHandler*) updateRemoteJoggingEntryFromLocal:(PTJoggingEntry*) joggingEntry
{
    __weak typeof(self) weakSelf = self;
    PTApiCallUpdateJoggingEntry* apiCall = [PTApiCallUpdateJoggingEntry new];
    apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
    {
        PTUpdatedRemoteObjectResponseData* responseData = [result.objects lastObject];
        [[PTPersistenceController sharedController] updateWithUpdatedRemoteObjectResponseData:responseData
                                                                      forSynchronisableObject:joggingEntry];
    };
    apiCall.failureBlock = ^(PTRemoteRequestHandler* requestHandler, NSError* error)
    {
        if(!weakSelf.isSyncing)
        {
            [weakSelf.modelSyncScheduler updateWithSyncStatus:PTModelSyncStatusFailed];
        }
    };
    
    PTJoggingEntryRequestDetails* requestDetails = [PTJoggingEntryRequestDetails new];
    requestDetails.joggingEntry = joggingEntry;
    requestDetails.userID = self.user.userID;
    requestDetails.isDeleted = @NO;
    
    return [apiCall executeWithManager:self.objectManager withPayloadObject:requestDetails pathUsingObjects:@[joggingEntry]];
}

-(PTRemoteRequestHandler*) deleteRemoteJoggingEntryFromLocal:(PTJoggingEntry*) joggingEntry
{
    __weak typeof(self) weakSelf = self;
    PTApiCallUpdateJoggingEntry* apiCall = [PTApiCallUpdateJoggingEntry new];
    apiCall.successBlock = ^(PTRemoteRequestHandler* requestHandler, PTApiCallResponseResult* result)
    {
        PTUpdatedRemoteObjectResponseData* responseData = [result.objects lastObject];
        [[PTPersistenceController sharedController] updateWithUpdatedRemoteObjectResponseData:responseData
                                                                      forSynchronisableObject:joggingEntry];
    };
    apiCall.failureBlock = ^(PTRemoteRequestHandler* requestHandler, NSError* error)
    {
        if(!weakSelf.isSyncing)
        {
            [weakSelf.modelSyncScheduler updateWithSyncStatus:PTModelSyncStatusFailed];
        }
    };
    
    PTJoggingEntryRequestDetails* requestDetails = [PTJoggingEntryRequestDetails new];
    requestDetails.joggingEntry = joggingEntry;
    requestDetails.userID = self.user.userID;
    requestDetails.isDeleted = @YES;
    
    return [apiCall executeWithManager:self.objectManager withPayloadObject:requestDetails pathUsingObjects:@[joggingEntry]];
}

@end
