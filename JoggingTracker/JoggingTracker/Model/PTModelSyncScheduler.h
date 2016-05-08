//
//  PTModelSyncScheduler.h
//  JoggingTracker
//
//  Created by Plamen Terziev on 9/2/14.
//  Copyright (c) 2014 Plamen Terziev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTModelSyncStatus.h"

@class PTModelSyncScheduler;

@protocol PTModelSyncSchedulerDelegate <NSObject>

-(void) modelSyncSchedulerDidRequestModelSync:(PTModelSyncScheduler*) sender;

@end

/**
 * Scheduler for the next automatic model sync operation
 */
@interface PTModelSyncScheduler : NSObject

@property (nonatomic, weak) id<PTModelSyncSchedulerDelegate> delegate;

-(void) updateWithSyncStatus:(PTModelSyncStatus) syncStatus;

@end
