//
//  PTManagedObjectSyncStatus.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 8/28/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

typedef enum : NSUInteger {
    PTManagedObjectSyncStatusSynced = 0,
    PTManagedObjectSyncStatusOutOfSync,
    PTManagedObjectSyncStatusCreated,
    PTManagedObjectSyncStatusDeleted
} PTManagedObjectSyncStatus;
