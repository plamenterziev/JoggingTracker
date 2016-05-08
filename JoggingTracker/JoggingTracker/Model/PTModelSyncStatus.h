//
//  PTModelSyncStatus.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/1/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

typedef NS_ENUM(NSUInteger, PTModelSyncStatus) {
    PTModelSyncStatusStarted = 0,
    PTModelSyncStatusFinished,
    PTModelSyncStatusFailed,
    PTModelSyncStatusStopped
};
