//
//  PTPersistenceController.m
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/27/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import "PTPersistenceController.h"
#import "PTPersistenceController+TransientObjectsSupport.h"
#import "PTManagedUser.h"
#import "PTManagedJoggingEntry.h"
#import "PTManagedObjectSyncStatus.h"
#import "PTJoggingEntry.h"
#import "PTCreatedRemoteObjectResponseData.h"
#import "PTUpdatedRemoteObjectResponseData.h"
#import "PTErrorResponseData.h"
#import "PTFilterOptions.h"
#import "PTJoggingEntryReportData.h"

#import <RKCoreData.h>
#import <RKPathUtilities.h>

static NSString* const kManagedObjectModelFileName                  = @"JoggingTracker";
static NSString* const kPersistentStoreFileName                     = @"JoggingTracker.sqlite";
static NSString* const kManagedUserEntityName                       = @"PTManagedUser";
static NSString* const kManagedJoggingEntryEntityName               = @"PTManagedJoggingEntry";

@interface PTPersistenceController ()

@property (nonatomic, strong) NSURL* modelURL;
@property (nonatomic, strong) RKManagedObjectStore* managedObjectStore;

-(NSArray*) fetchObjectsWithEntityName:(NSString*) entityName
                            fetchLimit:(NSUInteger) fetchLimit
                             predicate:(NSPredicate*) predicate
                        sortDescriptor:(NSSortDescriptor*) sortDescriptor;
-(id) fetchSingleObjectWithEntityName:(NSString*) entityName;

-(BOOL) updateManagedSynchronisableObject:(PTManagedSynchronisableObject*) managedSynchronisableObject
      fromCreatedRemoteObjectResponseData:(PTCreatedRemoteObjectResponseData*) responseData
                                     save:(BOOL) save;
-(BOOL) updateManagedSynchronisableObject:(PTManagedSynchronisableObject*) managedSynchronisableObject
      fromUpdatedRemoteObjectResponseData:(PTUpdatedRemoteObjectResponseData*) responseData
                                     save:(BOOL) save;

-(BOOL) mergeWithSynchronisableObjects:(NSArray*) synchronisableObjects withManagedEntityName:(NSString*) entityName;
-(BOOL) updateSynchronisableObjects:(NSArray*) synchronisableObjects
                     withEntityName:(NSString*) entityName
   withBatchOperationsResponsesData:(NSArray*) responsesData;

-(NSString*) entityNameForSynchronisableObject:(PTSynchronisableObject*) object;

@end

@implementation PTPersistenceController

static PTPersistenceController* theController = nil;

+(instancetype) sharedController
{
    if(!theController)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            theController = [PTPersistenceController new];
        });
    }
    
    return theController;
}

-(BOOL) saveCurrentUser:(PTUser*) user
{
    PTManagedUser* managedUser = [[self fetchSingleObjectWithEntityName:kManagedUserEntityName] lastObject];
    if(!managedUser)
    {
        managedUser = [[self.managedObjectStore mainQueueManagedObjectContext] insertNewObjectForEntityForName:kManagedUserEntityName];
    }
    
    [self updateManagedUser:managedUser fromUser:user];
    
    NSError* error = nil;
    [[self.managedObjectStore mainQueueManagedObjectContext] saveToPersistentStore:&error];
    if(error)
    {
        NSLog(@"Unable to save current user. Error: %@", error);
    }
    
    return !error;
}

-(BOOL) deleteCurrentUser
{
    PTManagedUser* managedUser = [[self fetchSingleObjectWithEntityName:kManagedUserEntityName] lastObject];
    [[self.managedObjectStore mainQueueManagedObjectContext] deleteObject:managedUser];
    
    NSError* error = nil;
    [[self.managedObjectStore mainQueueManagedObjectContext] saveToPersistentStore:&error];
    if(error)
    {
        NSLog(@"Unable to delete current user. Error: %@", error);
    }
    
    return !error;
}

-(PTUser*) fetchCurrentUser
{
    PTManagedUser* managedUser = [[self fetchSingleObjectWithEntityName:kManagedUserEntityName] lastObject];
    
    PTUser* user = nil;
    if(managedUser)
    {
        user = [self createUserFromManagedUser:managedUser];
    }
    
    return user;
}

-(PTManagedSynchronisableObject*) saveSynchronisableObject:(PTSynchronisableObject*) synchronisableObject;
{
    PTManagedSynchronisableObject* managedSynchronisableObject = [self fetchManagedSynchronisableObjectForSynchronisableObject:synchronisableObject];
    
    if(!managedSynchronisableObject)
    {
        managedSynchronisableObject = [[self.managedObjectStore mainQueueManagedObjectContext]
                                       insertNewObjectForEntityForName:[self entityNameForSynchronisableObject:synchronisableObject]];
        managedSynchronisableObject.syncStatus = @(PTManagedObjectSyncStatusCreated);
    }
    else
    {
        managedSynchronisableObject.syncStatus = @(PTManagedObjectSyncStatusOutOfSync);
    }
    
    [synchronisableObject exportToManagedObject:managedSynchronisableObject];
    
    NSError* error = nil;
    [[self.managedObjectStore mainQueueManagedObjectContext] saveToPersistentStore:&error];
    if(error)
    {
        NSLog(@"Unable to save synchronisable object: %@. Error: %@", synchronisableObject, error);
    }
    
    return (!error ? managedSynchronisableObject : nil);
}

-(BOOL) setSyncStatus:(PTManagedObjectSyncStatus) syncStatus
             ofObject:(PTSynchronisableObject*) synchronisableObject
{
    BOOL result = NO;
    
    PTManagedSynchronisableObject* managedSynchronisableObject = [self fetchManagedSynchronisableObjectForSynchronisableObject:synchronisableObject];
    if(managedSynchronisableObject)
    {
        result = [self setSyncStatus:syncStatus ofManagedObject:managedSynchronisableObject];
    }
    
    return result;
}

-(BOOL) setSyncStatus:(PTManagedObjectSyncStatus) syncStatus
      ofManagedObject:(PTManagedSynchronisableObject*) managedSynchronisableObject
{
    managedSynchronisableObject.syncStatus = @(syncStatus);
    
    NSError* error = nil;
    [[self.managedObjectStore mainQueueManagedObjectContext] saveToPersistentStore:&error];
    if(error)
    {
        NSLog(@"Unable to set sync status: %d to synchronisable object %@. Error: %@", syncStatus, managedSynchronisableObject, error);
    }
    
    return !error;
}

-(BOOL) updateWithCreatedRemoteObjectResponseData:(PTCreatedRemoteObjectResponseData*) responseData
                          forSynchronisableObject:(PTSynchronisableObject*) synchronisableObject
{
    BOOL result = NO;
    PTManagedSynchronisableObject* managedSynchronisableObject = [self fetchManagedSynchronisableObjectForSynchronisableObject:synchronisableObject];
    if(managedSynchronisableObject)
    {
        result = [self updateManagedSynchronisableObject:managedSynchronisableObject
                     fromCreatedRemoteObjectResponseData:responseData
                                                    save:YES];
    }
    
    return result;
}

-(BOOL) updateWithUpdatedRemoteObjectResponseData:(PTUpdatedRemoteObjectResponseData*) responseData
                          forSynchronisableObject:(PTSynchronisableObject*) synchronisableObject
{
    BOOL result = NO;
    PTManagedSynchronisableObject* managedSynchronisableObject = [self fetchManagedSynchronisableObjectForSynchronisableObject:synchronisableObject];
    if(managedSynchronisableObject)
    {
        result = [self updateManagedSynchronisableObject:managedSynchronisableObject
                     fromUpdatedRemoteObjectResponseData:responseData
                                                    save:YES];
    }
    
    return result;
}

-(PTManagedSynchronisableObject*) fetchManagedSynchronisableObjectForSynchronisableObject:(PTSynchronisableObject*) synchronisableObject
{
    PTManagedJoggingEntry* managedSynchronisableObject = nil;
    if(synchronisableObject.serverSideObjectID)
    {
        managedSynchronisableObject = [[self fetchObjectsWithEntityName:[self entityNameForSynchronisableObject:synchronisableObject]
                                                             fetchLimit:1
                                                              predicate:[NSPredicate predicateWithFormat:@"serverSideObjectID == %@", synchronisableObject.serverSideObjectID]
                                                         sortDescriptor:nil] lastObject];
    }
    else
    {
        NSAssert(synchronisableObject.clientSideObjectID, @"Synchronisable object: %@ has no server side id nor client side id", synchronisableObject);
        managedSynchronisableObject = [[self fetchObjectsWithEntityName:[self entityNameForSynchronisableObject:synchronisableObject]
                                                             fetchLimit:1
                                                              predicate:[NSPredicate predicateWithFormat:@"clientSideObjectID == %@", synchronisableObject.clientSideObjectID]
                                                         sortDescriptor:nil] lastObject];
    }
    
    return managedSynchronisableObject;
}

-(BOOL) mergeWithJoggingEntries:(NSArray*) joggingEntries
{
    return [self mergeWithSynchronisableObjects:joggingEntries withManagedEntityName:kManagedJoggingEntryEntityName];
}

-(BOOL) updateJoggingEntries:(NSArray*) joggingEntries withBatchOperationsResponsesData:(NSArray*) responsesData
{
    return [self updateSynchronisableObjects:joggingEntries
                              withEntityName:kManagedJoggingEntryEntityName
            withBatchOperationsResponsesData:responsesData];
}

-(NSArray*) fetchJoggingEntriesWithFilter:(PTFilterOptions*) filterOptions
{
    NSPredicate* predicate = nil;
    if(filterOptions)
    {
        predicate = [NSPredicate predicateWithFormat:@"(syncStatus != %d) AND (date >= %@) AND (date <= %@)",
                     PTManagedObjectSyncStatusDeleted, filterOptions.fromDate, filterOptions.toDate];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"syncStatus != %d", PTManagedObjectSyncStatusDeleted];
    }
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    
    return [self fetchObjectsWithEntityName:kManagedJoggingEntryEntityName
                                 fetchLimit:0
                                  predicate:predicate
                             sortDescriptor:sortDescriptor];
}

-(NSArray*) fetchNotSyncedJoggingEntries
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"syncStatus != %d", PTManagedObjectSyncStatusSynced];
    
    return [self fetchObjectsWithEntityName:kManagedJoggingEntryEntityName
                                 fetchLimit:kUploadObjectsBatchLimit
                                  predicate:predicate
                             sortDescriptor:nil];
}

-(NSArray*) fetchWeekReportDataForJoggingEntries
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kManagedJoggingEntryEntityName];
    
    NSExpressionDescription* timeExpressionDescription = [NSExpressionDescription new];
    [timeExpressionDescription setExpression:[NSExpression expressionWithFormat:@"@sum.time"]];
    [timeExpressionDescription setExpressionResultType:NSInteger32AttributeType];
    [timeExpressionDescription setName:@"timeSum"];
    
    NSExpressionDescription* distanceExpressionDescription = [NSExpressionDescription new];
    [distanceExpressionDescription setExpression:[NSExpression expressionWithFormat:@"@sum.distance"]];
    [distanceExpressionDescription setExpressionResultType:NSInteger32AttributeType];
    [distanceExpressionDescription setName:@"distanceSum"];
    
    [fetchRequest setPropertiesToFetch:@[@"weekDate", timeExpressionDescription, distanceExpressionDescription]];
    [fetchRequest setPropertiesToGroupBy:@[@"weekDate"]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"weekDate" ascending:NO]]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSError* error = nil;
    NSArray* results = [self.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest
                                                                                            error:&error];

    NSMutableArray* joggingEntriesReportData = nil;
    if(error)
    {
        NSLog(@"Error while fetching entities with name: %@. Error: %@", kManagedJoggingEntryEntityName, error);
    }
    else
    {
        joggingEntriesReportData = [NSMutableArray arrayWithCapacity:[results count]];
        for(NSDictionary* dictionary in results)
        {
            PTJoggingEntryReportData* reportData = [[PTJoggingEntryReportData alloc] initWithDictionary:dictionary];
            [joggingEntriesReportData addObject:reportData];
        }
    }
    
    return joggingEntriesReportData;
}

-(BOOL) deleteAllSynchronisableObjects
{
    NSArray* allManagedJoggingEntries = [self fetchObjectsWithEntityName:kManagedJoggingEntryEntityName
                                                              fetchLimit:0
                                                               predicate:nil
                                                          sortDescriptor:nil];
    for(NSManagedObject* managedObject in allManagedJoggingEntries)
    {
        [self.managedObjectStore.mainQueueManagedObjectContext deleteObject:managedObject];
    }
    
    NSError* error = nil;
    [[self.managedObjectStore mainQueueManagedObjectContext] saveToPersistentStore:&error];
    if(error)
    {
        NSLog(@"Unable to delete all synchronisable objects. Error: %@", error);
    }
    
    return !error;
}

#pragma mark -
#pragma mark Private methods

-(NSURL*) modelURL
{
    if(!_modelURL)
    {
        _modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:kManagedObjectModelFileName ofType:@"momd"]];
    }
    
    return _modelURL;
}

-(RKManagedObjectStore*) managedObjectStore
{
    if(!_managedObjectStore)
    {
        NSManagedObjectModel* managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL] mutableCopy];
        _managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
        NSError* error = nil;
        NSString* persistentStorePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:kPersistentStoreFileName];
        [_managedObjectStore addSQLitePersistentStoreAtPath:persistentStorePath
                                     fromSeedDatabaseAtPath:nil
                                          withConfiguration:nil
                                                    options:nil
                                                      error:&error];
        [_managedObjectStore createManagedObjectContexts];
        if(error)
        {
            NSLog(@"Unable to add SQLite persistent store at path: %@", persistentStorePath);
            _managedObjectStore = nil;
        }
    }
    
    return _managedObjectStore;
}

-(NSArray*) fetchObjectsWithEntityName:(NSString*) entityName
                            fetchLimit:(NSUInteger) fetchLimit
                             predicate:(NSPredicate*) predicate
                        sortDescriptor:(NSSortDescriptor*) sortDescriptor
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if(fetchLimit != 0)
    {
        [fetchRequest setFetchLimit:fetchLimit];
    }
    if(predicate)
    {
        [fetchRequest setPredicate:predicate];
    }
    if(sortDescriptor)
    {
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
    }
    
    NSError* error = nil;
    NSArray* results = [self.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest
                                                                                            error:&error];
    if(error)
    {
        NSLog(@"Error while fetching entities with name: %@. Error: %@", entityName, error);
    }
    
    return results;
}

-(id) fetchSingleObjectWithEntityName:(NSString*) entityName
{
    return [self fetchObjectsWithEntityName:entityName
                                 fetchLimit:1
                                  predicate:nil
                             sortDescriptor:nil];
}

-(BOOL) updateManagedSynchronisableObject:(PTManagedSynchronisableObject*) managedSynchronisableObject
      fromCreatedRemoteObjectResponseData:(PTCreatedRemoteObjectResponseData*) responseData
                                     save:(BOOL) save
{
    managedSynchronisableObject.serverSideObjectID = responseData.objectID;
    managedSynchronisableObject.dateCreated = responseData.dateCreated;
    managedSynchronisableObject.dateUpdated = responseData.dateCreated;
    
    if([managedSynchronisableObject.syncStatus integerValue] == PTManagedObjectSyncStatusCreated)
    {
        managedSynchronisableObject.syncStatus = @(PTManagedObjectSyncStatusSynced);
    }
    
    BOOL result = YES;
    if(save)
    {
        NSError* error = nil;
        [[self.managedObjectStore mainQueueManagedObjectContext] saveToPersistentStore:&error];
        if(error)
        {
            NSLog(@"Unable to save synchronisable object: %@. Error: %@", managedSynchronisableObject, error);
        }
        
        result = !error;
    }
    
    return result;
}

-(BOOL) updateManagedSynchronisableObject:(PTManagedSynchronisableObject*) managedSynchronisableObject
      fromUpdatedRemoteObjectResponseData:(PTUpdatedRemoteObjectResponseData*) responseData
                                     save:(BOOL) save
{
    managedSynchronisableObject.dateUpdated = responseData.dateUpdated;
    
    if([managedSynchronisableObject.syncStatus integerValue] == PTManagedObjectSyncStatusOutOfSync)
    {
        managedSynchronisableObject.syncStatus = @(PTManagedObjectSyncStatusSynced);
    }
    else if([managedSynchronisableObject.syncStatus integerValue] == PTManagedObjectSyncStatusDeleted)
    {
        [self.managedObjectStore.mainQueueManagedObjectContext deleteObject:managedSynchronisableObject];
    }
    
    BOOL result = YES;
    if(save)
    {
        NSError* error = nil;
        [[self.managedObjectStore mainQueueManagedObjectContext] saveToPersistentStore:&error];
        if(error)
        {
            NSLog(@"Unable to save synchronisable object: %@. Error: %@", managedSynchronisableObject, error);
        }
        
        result = !error;
    }
    
    return result;
}

-(BOOL) mergeWithSynchronisableObjects:(NSArray*) synchronisableObjects withManagedEntityName:(NSString*) entityName
{
    NSMutableDictionary* serverSideIDToObjectDict = [NSMutableDictionary dictionary];
    NSMutableDictionary* clientSideIDToObjectDict = [NSMutableDictionary dictionary];
    for(PTSynchronisableObject* synchronisableObject in synchronisableObjects)
    {
        if(synchronisableObject.serverSideObjectID)
        {
            serverSideIDToObjectDict[synchronisableObject.serverSideObjectID] = synchronisableObject;
        }
        if(synchronisableObject.clientSideObjectID)
        {
            clientSideIDToObjectDict[synchronisableObject.clientSideObjectID] = synchronisableObject;
        }
    }
    
    // Fetch local objects that are updated
    NSPredicate* predicate  = [NSPredicate predicateWithFormat:@"(serverSideObjectID IN %@) OR (clientSideObjectID IN %@)",
                               [serverSideIDToObjectDict allKeys], [clientSideIDToObjectDict allKeys]];
    NSArray* managedObjects = [self fetchObjectsWithEntityName:entityName
                                                    fetchLimit:0
                                                     predicate:predicate
                                                sortDescriptor:nil];
    
    // Iterate local objects that are updated on the backend and update them locally
    for(PTManagedSynchronisableObject* managedSynchronisableObject in managedObjects)
    {
        if(managedSynchronisableObject.serverSideObjectID)
        {
            PTSynchronisableObject* synchronisableObject = serverSideIDToObjectDict[managedSynchronisableObject.serverSideObjectID];
            if(synchronisableObject)
            {
                if(synchronisableObject.isDeleted)
                {
                    [self.managedObjectStore.mainQueueManagedObjectContext deleteObject:managedSynchronisableObject];
                }
                else if([managedSynchronisableObject.syncStatus integerValue] != PTManagedObjectSyncStatusDeleted)
                {
                    [synchronisableObject exportToManagedObject:managedSynchronisableObject];
                    managedSynchronisableObject.syncStatus = @(PTManagedObjectSyncStatusSynced);
                }
                
                [serverSideIDToObjectDict removeObjectForKey:managedSynchronisableObject.serverSideObjectID];
            }
        }
        else
        {
            PTSynchronisableObject* synchronisableObject = clientSideIDToObjectDict[managedSynchronisableObject.clientSideObjectID];
            if(synchronisableObject)
            {
                [synchronisableObject exportToManagedObject:managedSynchronisableObject];
                
                if(synchronisableObject.isDeleted)
                {
                    [self.managedObjectStore.mainQueueManagedObjectContext deleteObject:managedSynchronisableObject];
                }
                else if([managedSynchronisableObject.syncStatus integerValue] == PTManagedObjectSyncStatusCreated)
                {
                    managedSynchronisableObject.syncStatus = @(PTManagedObjectSyncStatusSynced);
                }
                
                [clientSideIDToObjectDict removeObjectForKey:managedSynchronisableObject.clientSideObjectID];
                [serverSideIDToObjectDict removeObjectForKey:synchronisableObject.serverSideObjectID];
            }
            else
            {
                NSLog(@"Unable to find synchronisable object with client side id: %@", managedSynchronisableObject.clientSideObjectID);
            }
        }
    }
    
    // Add the new objects
    [serverSideIDToObjectDict enumerateKeysAndObjectsUsingBlock:^(id key, PTSynchronisableObject* synchronisableObject, BOOL* stop) {
        if(!synchronisableObject.isDeleted)
        {
            PTManagedSynchronisableObject* managedSynchronisableObject =
                [[self.managedObjectStore mainQueueManagedObjectContext] insertNewObjectForEntityForName:entityName];
            [synchronisableObject exportToManagedObject:managedSynchronisableObject];
            managedSynchronisableObject.syncStatus = @(PTManagedObjectSyncStatusSynced);
        }
    }];
    
    NSError* error = nil;
    [[self.managedObjectStore mainQueueManagedObjectContext] saveToPersistentStore:&error];
    if(error)
    {
        NSLog(@"Unable to merge synchronisable objects: %@. Error: %@", synchronisableObjects, error);
    }
    
    return !error;
}

-(BOOL) updateSynchronisableObjects:(NSArray*) synchronisableObjects
                     withEntityName:(NSString*) entityName
   withBatchOperationsResponsesData:(NSArray*) responsesData
{
    NSMutableSet* serverSideIDs = [NSMutableSet set];
    NSMutableSet* clientSideIDs = [NSMutableSet set];
    for(PTSynchronisableObject* synchronisableObject in synchronisableObjects)
    {
        if(synchronisableObject.serverSideObjectID)
        {
            [serverSideIDs addObject:synchronisableObject.serverSideObjectID];
        }
        if(synchronisableObject.clientSideObjectID)
        {
            [clientSideIDs addObject:synchronisableObject.clientSideObjectID];
        }
    }
    
    // Fetch local objects that are updated
    NSPredicate* predicate  = [NSPredicate predicateWithFormat:@"(serverSideObjectID IN %@) OR (clientSideObjectID IN %@)",
                               serverSideIDs, clientSideIDs];
    NSArray* managedObjects = [self fetchObjectsWithEntityName:entityName
                                                    fetchLimit:0
                                                     predicate:predicate
                                                sortDescriptor:nil];
    
    NSMutableDictionary* serverSideIDToObjectDict = [NSMutableDictionary dictionary];
    NSMutableDictionary* clientSideIDToObjectDict = [NSMutableDictionary dictionary];
    for(PTManagedSynchronisableObject* managedSynchronisableObject in managedObjects)
    {
        if(managedSynchronisableObject.serverSideObjectID)
        {
            serverSideIDToObjectDict[managedSynchronisableObject.serverSideObjectID] = managedSynchronisableObject;
        }
        if(managedSynchronisableObject.clientSideObjectID)
        {
            clientSideIDToObjectDict[managedSynchronisableObject.clientSideObjectID] = managedSynchronisableObject;
        }
    }
    
    BOOL foundErrorInResponses = NO;
    for(NSInteger i = 0; i < [synchronisableObjects count]; ++i)
    {
        id responseData = responsesData[i];
        PTSynchronisableObject* synchronisableObject = synchronisableObjects[i];
        
        PTManagedSynchronisableObject* managedSynchronisableObject = serverSideIDToObjectDict[synchronisableObject.serverSideObjectID];
        if(!managedSynchronisableObject)
        {
            managedSynchronisableObject = clientSideIDToObjectDict[synchronisableObject.clientSideObjectID];
        }
        
        NSAssert(managedSynchronisableObject, @"Unable to find managed synchronisable object for %@", synchronisableObject);
        if([responseData isKindOfClass:[PTCreatedRemoteObjectResponseData class]])
        {
            [self updateManagedSynchronisableObject:managedSynchronisableObject
                fromCreatedRemoteObjectResponseData:responseData
                                               save:NO];
        }
        else if([responseData isKindOfClass:[PTUpdatedRemoteObjectResponseData class]])
        {
            [self updateManagedSynchronisableObject:managedSynchronisableObject
                fromUpdatedRemoteObjectResponseData:responseData
                                               save:NO];
        }
        else if([responseData isKindOfClass:[PTErrorResponseData class]])
        {
            foundErrorInResponses = YES;
        }
    }

    NSError* error = nil;
    [[self.managedObjectStore mainQueueManagedObjectContext] saveToPersistentStore:&error];
    if(error)
    {
        NSLog(@"Unable to update synchronisable objects: %@. Error: %@", synchronisableObjects, error);
    }
    
    return (foundErrorInResponses ? NO : !error);
}

-(NSString*) entityNameForSynchronisableObject:(PTSynchronisableObject*) object
{
    NSString* entityName = nil;
    if([object isMemberOfClass:[PTJoggingEntry class]])
    {
        entityName = kManagedJoggingEntryEntityName;
    }
    else
    {
        NSAssert(NO, @"Invalid object: %@", object);
    }
    
    return entityName;
}

@end
